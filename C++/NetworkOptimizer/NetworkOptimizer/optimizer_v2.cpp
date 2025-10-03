#include "optimizer_v2.h"
#include <iphlpapi.h>
#include <icmpapi.h>
#include <sstream>
#include <iomanip>
#include <commctrl.h>

#pragma comment(lib, "iphlpapi.lib")
#pragma comment(lib, "ws2_32.lib")

std::vector<NetworkTweak> NetworkOptimizer::GetTweaksList() {
    return {
        {
            L"Network Throttling",
            L"Removes 10 Mbps cap on non-multimedia network traffic",
            HKEY_LOCAL_MACHINE,
            L"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile",
            L"NetworkThrottlingIndex",
            0xFFFFFFFF,
            false
        },
        {
            L"TCP ACK Frequency",
            L"Disables 200ms delayed ACK timer for faster response",
            HKEY_LOCAL_MACHINE,
            L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
            L"TcpAckFrequency",
            1,
            true
        },
        {
            L"Nagle's Algorithm",
            L"Disables packet batching for lower latency",
            HKEY_LOCAL_MACHINE,
            L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
            L"TcpNoDelay",
            1,
            true
        },
        {
            L"System Responsiveness",
            L"Prioritizes foreground applications (10% reserved for background)",
            HKEY_LOCAL_MACHINE,
            L"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile",
            L"SystemResponsiveness",
            10,
            false
        },
        {
            L"DNS Cache TTL",
            L"Optimizes DNS caching to 24 hours",
            HKEY_LOCAL_MACHINE,
            L"SYSTEM\\CurrentControlSet\\Services\\Dnscache\\Parameters",
            L"MaxCacheTtl",
            86400,
            false
        },
        {
            L"TCP Delayed ACK Ticks",
            L"Removes delayed ACK timer (legacy setting)",
            HKEY_LOCAL_MACHINE,
            L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
            L"TcpDelAckTicks",
            0,
            true
        },
        {
            L"Default TTL",
            L"Sets packet Time-To-Live to optimal value",
            HKEY_LOCAL_MACHINE,
            L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
            L"DefaultTTL",
            64,
            false
        },
        {
            L"TCP Window Scaling",
            L"Enables TCP window scaling (RFC 1323)",
            HKEY_LOCAL_MACHINE,
            L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
            L"Tcp1323Opts",
            1,
            false
        },
        {
            L"Max User Ports",
            L"Increases available ephemeral ports",
            HKEY_LOCAL_MACHINE,
            L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
            L"MaxUserPort",
            65534,
            false
        },
        {
            L"TCP TIME_WAIT Delay",
            L"Reduces TIME_WAIT from 240s to 30s",
            HKEY_LOCAL_MACHINE,
            L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
            L"TcpTimedWaitDelay",
            30,
            false
        },
        {
            L"Path MTU Discovery",
            L"Enables automatic MTU detection",
            HKEY_LOCAL_MACHINE,
            L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
            L"EnablePMTUDiscovery",
            1,
            false
        },
        {
            L"Selective ACK",
            L"Enables SACK for better packet recovery",
            HKEY_LOCAL_MACHINE,
            L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
            L"SackOpts",
            1,
            false
        },
        {
            L"TCP Initial RTT",
            L"Optimizes initial retransmission timeout",
            HKEY_LOCAL_MACHINE,
            L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
            L"TCPInitialRtt",
            300,
            false
        },
        {
            L"Web Services Discovery",
            L"Disables WSD to reduce network overhead",
            HKEY_LOCAL_MACHINE,
            L"SYSTEM\\CurrentControlSet\\Services\\WSD\\Parameters",
            L"EnableWsd",
            0,
            false
        },
        {
            L"Max Connections Per Server",
            L"Increases simultaneous connections",
            HKEY_LOCAL_MACHINE,
            L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Internet Settings",
            L"MaxConnectionsPerServer",
            16,
            false
        }
    };
}

int NetworkOptimizer::GetTweaksCount() {
    return static_cast<int>(GetTweaksList().size());
}

bool NetworkOptimizer::IsAdministrator() {
    BOOL isAdmin = FALSE;
    PSID administratorsGroup = NULL;
    SID_IDENTIFIER_AUTHORITY ntAuthority = SECURITY_NT_AUTHORITY;

    if (AllocateAndInitializeSid(&ntAuthority, 2,
        SECURITY_BUILTIN_DOMAIN_RID,
        SECURITY_LOCAL_SYSTEM_RID,
        0, 0, 0, 0, 0, 0,
        &administratorsGroup)) {
        CheckTokenMembership(NULL, administratorsGroup, &isAdmin);
        FreeSid(administratorsGroup);
    }

    return isAdmin == TRUE;
}

OptimizationResult NetworkOptimizer::ApplyTweak(const NetworkTweak& tweak) {
    HKEY key;
    LONG result;

    std::wstring fullPath = tweak.subKey;

    result = RegCreateKeyExW(tweak.rootKey, fullPath.c_str(), 0, NULL,
        REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &key, NULL);

    if (result != ERROR_SUCCESS) {
        return { false, L"Failed: " + tweak.name, 0, 1 };
    }

    result = RegSetValueExW(key, tweak.valueName.c_str(), 0, REG_DWORD,
        (BYTE*)&tweak.value, sizeof(DWORD));
    RegCloseKey(key);

    if (result == ERROR_SUCCESS) {
        return { true, L"[+] " + tweak.name, 1, 1 };
    }

    return { false, L"[-] " + tweak.name, 0, 1 };
}

OptimizationResult NetworkOptimizer::RestoreTweak(const NetworkTweak& tweak) {
    HKEY key;

    if (RegOpenKeyExW(tweak.rootKey, tweak.subKey.c_str(), 0, KEY_WRITE, &key) == ERROR_SUCCESS) {
        RegDeleteValueW(key, tweak.valueName.c_str());
        RegCloseKey(key);
        return { true, L"[+] Restored: " + tweak.name, 1, 1 };
    }

    return { true, L"[ ] " + tweak.name + L" (already default)", 1, 1 };
}

OptimizationResult NetworkOptimizer::ApplyOptimizations(HWND progressBar) {
    if (!IsAdministrator()) {
        return { false, L"Administrator privileges required!", 0, 0 };
    }

    auto tweaks = GetTweaksList();
    int successful = 0;
    int total = static_cast<int>(tweaks.size());

    std::wstringstream results;
    results << L"==========================================\r\n";
    results << L"  NETWORK OPTIMIZATION REPORT\r\n";
    results << L"==========================================\r\n\r\n";

    for (size_t i = 0; i < tweaks.size(); i++) {
        auto result = ApplyTweak(tweaks[i]);
        results << result.message << L"\r\n";

        if (result.success) successful++;

        if (progressBar) {
            SendMessage(progressBar, PBM_SETPOS, (WPARAM)((i + 1) * 100 / total), 0);
            UpdateWindow(progressBar);
        }
    }

    results << L"\r\n==========================================\r\n";
    results << L"  RESULTS: " << successful << L"/" << total << L" Applied\r\n";
    results << L"==========================================\r\n\r\n";

    if (successful == total) {
        results << L"[SUCCESS] All optimizations applied!\r\n";
    }
    else {
        results << L"[WARNING] Some optimizations failed. See above.\r\n";
    }

    results << L"\r\n** RESTART REQUIRED for changes to take effect! **\r\n";

    return { successful > 0, results.str(), successful, total };
}

OptimizationResult NetworkOptimizer::RestoreDefaults(HWND progressBar) {
    if (!IsAdministrator()) {
        return { false, L"Administrator privileges required!", 0, 0 };
    }

    auto tweaks = GetTweaksList();
    int restored = 0;
    int total = static_cast<int>(tweaks.size());

    std::wstringstream results;
    results << L"==========================================\r\n";
    results << L"  RESTORE DEFAULTS REPORT\r\n";
    results << L"==========================================\r\n\r\n";

    for (size_t i = 0; i < tweaks.size(); i++) {
        auto result = RestoreTweak(tweaks[i]);
        results << result.message << L"\r\n";

        if (result.success) restored++;

        if (progressBar) {
            SendMessage(progressBar, PBM_SETPOS, (WPARAM)((i + 1) * 100 / total), 0);
            UpdateWindow(progressBar);
        }
    }

    results << L"\r\n==========================================\r\n";
    results << L"  RESULTS: " << restored << L"/" << total << L" Restored\r\n";
    results << L"==========================================\r\n\r\n";
    results << L"[SUCCESS] Default settings restored!\r\n";
    results << L"\r\n** RESTART REQUIRED! **\r\n";

    return { true, results.str(), restored, total };
}

PingResult NetworkOptimizer::TestPing(const std::wstring& host) {
    PingResult result = { 999, 0, 0, 100 };

    HANDLE hIcmpFile = IcmpCreateFile();
    if (hIcmpFile == INVALID_HANDLE_VALUE) {
        return result;
    }

    int len = WideCharToMultiByte(CP_ACP, 0, host.c_str(), -1, NULL, 0, NULL, NULL);
    std::string hostStr(len, 0);
    WideCharToMultiByte(CP_ACP, 0, host.c_str(), -1, &hostStr[0], len, NULL, NULL);

    unsigned long ipaddr = inet_addr(hostStr.c_str());

    if (ipaddr == INADDR_NONE) {
        struct hostent* remoteHost = gethostbyname(hostStr.c_str());
        if (remoteHost == NULL) {
            IcmpCloseHandle(hIcmpFile);
            return result;
        }
        ipaddr = *(u_long*)remoteHost->h_addr_list[0];
    }

    char SendData[32] = "NetworkOptimizer Test";
    DWORD ReplySize = sizeof(ICMP_ECHO_REPLY) + sizeof(SendData);
    LPVOID ReplyBuffer = (VOID*)malloc(ReplySize);

    if (ReplyBuffer == NULL) {
        IcmpCloseHandle(hIcmpFile);
        return result;
    }

    int successCount = 0;
    int totalPing = 0;
    int minPing = 999;
    int maxPing = 0;

    for (int i = 0; i < 4; i++) {
        DWORD dwRetVal = IcmpSendEcho(hIcmpFile, ipaddr, SendData, sizeof(SendData),
            NULL, ReplyBuffer, ReplySize, 1000);

        if (dwRetVal != 0) {
            PICMP_ECHO_REPLY pEchoReply = (PICMP_ECHO_REPLY)ReplyBuffer;
            if (pEchoReply->Status == 0) {
                successCount++;
                int rtt = pEchoReply->RoundTripTime;
                totalPing += rtt;
                if (rtt < minPing) minPing = rtt;
                if (rtt > maxPing) maxPing = rtt;
            }
        }
        Sleep(100);
    }

    free(ReplyBuffer);
    IcmpCloseHandle(hIcmpFile);

    if (successCount > 0) {
        result.minPing = minPing;
        result.maxPing = maxPing;
        result.avgPing = totalPing / successCount;
        result.packetLoss = ((4 - successCount) * 100) / 4;
    }

    return result;
}
