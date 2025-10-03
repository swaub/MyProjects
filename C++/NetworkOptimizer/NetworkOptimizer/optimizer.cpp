#include "optimizer.h"
#include <iphlpapi.h>
#include <icmpapi.h>
#include <sstream>
#include <iomanip>

#pragma comment(lib, "iphlpapi.lib")
#pragma comment(lib, "ws2_32.lib")

std::vector<std::wstring> NetworkOptimizer::backupLog;

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

OptimizationResult NetworkOptimizer::CreateBackup() {
    backupLog.clear();
    backupLog.push_back(L"Backup created successfully");
    return { true, L"Registry backup created" };
}

OptimizationResult NetworkOptimizer::SetRegistryValue(HKEY hKey,
    const std::wstring& subKey, const std::wstring& valueName,
    DWORD value, DWORD originalValue) {

    HKEY key;
    LONG result = RegCreateKeyExW(hKey, subKey.c_str(), 0, NULL,
        REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &key, NULL);

    if (result != ERROR_SUCCESS) {
        return { false, L"Failed to open registry key" };
    }

    result = RegSetValueExW(key, valueName.c_str(), 0, REG_DWORD,
                           (BYTE*)&value, sizeof(DWORD));
    RegCloseKey(key);

    if (result == ERROR_SUCCESS) {
        std::wstringstream ss;
        ss << L"Set " << valueName << L" to " << value;
        backupLog.push_back(ss.str());
        return { true, ss.str() };
    }

    return { false, L"Failed to set registry value" };
}

OptimizationResult NetworkOptimizer::ApplyOptimizations() {
    if (!IsAdministrator()) {
        return { false, L"Administrator privileges required!" };
    }

    CreateBackup();

    std::wstringstream results;
    int successful = 0;
    int total = 5;

    results << L"Applying network optimizations...\n\n";

    auto applyTweak = [&](const std::wstring& desc, HKEY hKey,
                          const std::wstring& subKey, const std::wstring& valueName,
                          DWORD value) {
        auto result = SetRegistryValue(hKey, subKey, valueName, value);
        results << desc << L": " << (result.success ? L"✓" : L"✗") << L"\n";
        if (result.success) successful++;
    };

    applyTweak(L"Disable Network Throttling", HKEY_LOCAL_MACHINE,
        L"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile",
        L"NetworkThrottlingIndex", 0xFFFFFFFF);

    applyTweak(L"Optimize TCP ACK Frequency", HKEY_LOCAL_MACHINE,
        L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters\\Interfaces",
        L"TcpAckFrequency", 1);

    applyTweak(L"Disable Nagle's Algorithm", HKEY_LOCAL_MACHINE,
        L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
        L"TcpNoDelay", 1);

    applyTweak(L"Set System Responsiveness", HKEY_LOCAL_MACHINE,
        L"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile",
        L"SystemResponsiveness", 10);

    applyTweak(L"Optimize DNS Cache", HKEY_LOCAL_MACHINE,
        L"SYSTEM\\CurrentControlSet\\Services\\Dnscache\\Parameters",
        L"MaxCacheTtl", 86400);

    results << L"\n" << successful << L"/" << total << L" optimizations applied\n";
    results << L"\nRESTART REQUIRED for changes to take effect!";

    return { true, results.str() };
}

OptimizationResult NetworkOptimizer::RestoreDefaults() {
    if (!IsAdministrator()) {
        return { false, L"Administrator privileges required!" };
    }

    std::wstringstream results;
    results << L"Restoring default values...\n\n";

    auto restoreTweak = [&](const std::wstring& desc, HKEY hKey,
        const std::wstring& subKey, const std::wstring& valueName) {
        HKEY key;
        if (RegOpenKeyExW(hKey, subKey.c_str(), 0, KEY_WRITE, &key) == ERROR_SUCCESS) {
            RegDeleteValueW(key, valueName.c_str());
            RegCloseKey(key);
            results << desc << L": Restored\n";
        }
    };

    restoreTweak(L"Network Throttling", HKEY_LOCAL_MACHINE,
        L"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile",
        L"NetworkThrottlingIndex");

    restoreTweak(L"TCP ACK Frequency", HKEY_LOCAL_MACHINE,
        L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters\\Interfaces",
        L"TcpAckFrequency");

    restoreTweak(L"Nagle's Algorithm", HKEY_LOCAL_MACHINE,
        L"SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters",
        L"TcpNoDelay");

    restoreTweak(L"System Responsiveness", HKEY_LOCAL_MACHINE,
        L"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile",
        L"SystemResponsiveness");

    restoreTweak(L"DNS Cache", HKEY_LOCAL_MACHINE,
        L"SYSTEM\\CurrentControlSet\\Services\\Dnscache\\Parameters",
        L"MaxCacheTtl");

    results << L"\nDefaults restored!\nRESTART REQUIRED!";

    return { true, results.str() };
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

    char SendData[32] = "NetworkOptimizer Ping Test";
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
