#include <iostream>
#include <windows.h>
#include <psapi.h>
#include <tlhelp32.h>
#include <vector>
#include <string>
#include <iomanip>
#include <algorithm>
#include <thread>
#include <chrono>

#pragma comment(lib, "psapi.lib")

struct ProcessInfo {
    DWORD pid;
    std::wstring name;
    SIZE_T workingSetSize;      // Current memory usage
    SIZE_T peakWorkingSetSize;  // Peak memory usage
    SIZE_T privateUsage;        // Private bytes
    SIZE_T virtualSize;         // Virtual memory size
};

class MemoryMonitor {
private:
    void clearScreen() {
        system("cls");
    }

    std::string formatBytes(SIZE_T bytes) {
        const char* units[] = { "B", "KB", "MB", "GB", "TB" };
        int unitIndex = 0;
        double size = static_cast<double>(bytes);

        while (size >= 1024 && unitIndex < 4) {
            size /= 1024;
            unitIndex++;
        }

        char buffer[50];
        snprintf(buffer, sizeof(buffer), "%.2f %s", size, units[unitIndex]);
        return std::string(buffer);
    }

    std::vector<ProcessInfo> getAllProcesses() {
        std::vector<ProcessInfo> processes;

        HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
        if (snapshot == INVALID_HANDLE_VALUE) {
            return processes;
        }

        PROCESSENTRY32W pe32;
        pe32.dwSize = sizeof(pe32);

        if (Process32FirstW(snapshot, &pe32)) {
            do {
                ProcessInfo info;
                info.pid = pe32.th32ProcessID;
                info.name = pe32.szExeFile;

                // Open process to get memory info
                HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pe32.th32ProcessID);
                if (hProcess != NULL) {
                    PROCESS_MEMORY_COUNTERS_EX pmc;
                    if (GetProcessMemoryInfo(hProcess, (PROCESS_MEMORY_COUNTERS*)&pmc, sizeof(pmc))) {
                        info.workingSetSize = pmc.WorkingSetSize;
                        info.peakWorkingSetSize = pmc.PeakWorkingSetSize;
                        info.privateUsage = pmc.PrivateUsage;
                    }

                    // Get virtual memory size
                    MEMORY_BASIC_INFORMATION mbi;
                    SIZE_T totalVirtual = 0;
                    SIZE_T address = 0;
                    while (VirtualQueryEx(hProcess, (LPCVOID)address, &mbi, sizeof(mbi)) == sizeof(mbi)) {
                        if (mbi.State == MEM_COMMIT) {
                            totalVirtual += mbi.RegionSize;
                        }
                        address = (SIZE_T)mbi.BaseAddress + mbi.RegionSize;
                        if (address >= 0x7FFFFFFF) break; // Prevent overflow
                    }
                    info.virtualSize = totalVirtual;

                    CloseHandle(hProcess);
                    processes.push_back(info);
                }
            } while (Process32NextW(snapshot, &pe32));
        }

        CloseHandle(snapshot);
        return processes;
    }

    void displaySystemMemory() {
        MEMORYSTATUSEX memInfo;
        memInfo.dwLength = sizeof(MEMORYSTATUSEX);
        GlobalMemoryStatusEx(&memInfo);

        DWORDLONG totalPhysMem = memInfo.ullTotalPhys;
        DWORDLONG physMemUsed = memInfo.ullTotalPhys - memInfo.ullAvailPhys;
        DWORDLONG totalVirtualMem = memInfo.ullTotalVirtual;
        DWORDLONG virtualMemUsed = memInfo.ullTotalVirtual - memInfo.ullAvailVirtual;

        std::cout << "╔════════════════════════════════════════════════════════════════════════╗\n";
        std::cout << "║                        SYSTEM MEMORY STATUS                            ║\n";
        std::cout << "╚════════════════════════════════════════════════════════════════════════╝\n\n";

        std::cout << "Physical Memory:\n";
        std::cout << "  Total:      " << formatBytes(totalPhysMem) << "\n";
        std::cout << "  Used:       " << formatBytes(physMemUsed) << "\n";
        std::cout << "  Available:  " << formatBytes(memInfo.ullAvailPhys) << "\n";
        std::cout << "  Usage:      " << memInfo.dwMemoryLoad << "%\n";
        std::cout << "\n";

        std::cout << "Virtual Memory:\n";
        std::cout << "  Total:      " << formatBytes(totalVirtualMem) << "\n";
        std::cout << "  Used:       " << formatBytes(virtualMemUsed) << "\n";
        std::cout << "  Available:  " << formatBytes(memInfo.ullAvailVirtual) << "\n";
        std::cout << "\n";

        // Draw progress bar for physical memory
        int barWidth = 50;
        int filledWidth = static_cast<int>(memInfo.dwMemoryLoad * barWidth / 100);
        std::cout << "  [";
        for (int i = 0; i < barWidth; i++) {
            if (i < filledWidth) std::cout << "█";
            else std::cout << "░";
        }
        std::cout << "] " << memInfo.dwMemoryLoad << "%\n\n";
    }

    void displayTopProcesses(std::vector<ProcessInfo>& processes, int count = 10) {
        // Sort by working set size (current memory usage)
        std::sort(processes.begin(), processes.end(),
            [](const ProcessInfo& a, const ProcessInfo& b) {
                return a.workingSetSize > b.workingSetSize;
            });

        std::cout << "╔════════════════════════════════════════════════════════════════════════╗\n";
        std::cout << "║                      TOP MEMORY CONSUMING PROCESSES                    ║\n";
        std::cout << "╚════════════════════════════════════════════════════════════════════════╝\n\n";

        std::cout << std::left << std::setw(8) << "PID"
                  << std::setw(30) << "Process Name"
                  << std::setw(15) << "Memory (MB)"
                  << std::setw(15) << "Peak (MB)"
                  << "\n";
        std::cout << std::string(70, '-') << "\n";

        int displayed = 0;
        for (const auto& proc : processes) {
            if (displayed >= count) break;

            std::wcout << std::left << std::setw(8) << proc.pid
                       << std::setw(30);
            std::wcout.write(proc.name.c_str(), std::min((int)proc.name.length(), 28));
            std::cout << "  "
                      << std::setw(15) << (proc.workingSetSize / (1024 * 1024))
                      << std::setw(15) << (proc.peakWorkingSetSize / (1024 * 1024))
                      << "\n";
            displayed++;
        }
        std::cout << "\n";
    }

    void displayProcessDetails(const ProcessInfo& proc) {
        clearScreen();
        std::cout << "╔════════════════════════════════════════════════════════════════════════╗\n";
        std::cout << "║                        PROCESS DETAILS                                 ║\n";
        std::cout << "╚════════════════════════════════════════════════════════════════════════╝\n\n";

        std::wcout << L"Process Name:        " << proc.name << "\n";
        std::cout << "Process ID (PID):    " << proc.pid << "\n\n";

        std::cout << "Memory Usage:\n";
        std::cout << "  Working Set:       " << formatBytes(proc.workingSetSize) << "\n";
        std::cout << "  Peak Working Set:  " << formatBytes(proc.peakWorkingSetSize) << "\n";
        std::cout << "  Private Bytes:     " << formatBytes(proc.privateUsage) << "\n";
        std::cout << "  Virtual Size:      " << formatBytes(proc.virtualSize) << "\n\n";

        // Get additional info
        HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION, FALSE, proc.pid);
        if (hProcess != NULL) {
            FILETIME ftCreation, ftExit, ftKernel, ftUser;
            if (GetProcessTimes(hProcess, &ftCreation, &ftExit, &ftKernel, &ftUser)) {
                ULARGE_INTEGER kernelTime, userTime;
                kernelTime.LowPart = ftKernel.dwLowDateTime;
                kernelTime.HighPart = ftKernel.dwHighDateTime;
                userTime.LowPart = ftUser.dwLowDateTime;
                userTime.HighPart = ftUser.dwHighDateTime;

                double totalCPUTime = (kernelTime.QuadPart + userTime.QuadPart) / 10000000.0; // Convert to seconds

                std::cout << "CPU Time:            " << std::fixed << std::setprecision(2)
                          << totalCPUTime << " seconds\n";
            }

            DWORD handleCount = 0;
            GetProcessHandleCount(hProcess, &handleCount);
            std::cout << "Handle Count:        " << handleCount << "\n";

            CloseHandle(hProcess);
        }

        std::cout << "\nPress any key to return to main menu...";
        std::cin.ignore();
        std::cin.get();
    }

public:
    void runInteractive() {
        bool running = true;

        while (running) {
            clearScreen();
            displaySystemMemory();

            auto processes = getAllProcesses();
            displayTopProcesses(processes, 15);

            std::cout << "╔════════════════════════════════════════════════════════════════════════╗\n";
            std::cout << "║                              OPTIONS                                   ║\n";
            std::cout << "╚════════════════════════════════════════════════════════════════════════╝\n\n";
            std::cout << "  1. Refresh\n";
            std::cout << "  2. View process details (enter PID)\n";
            std::cout << "  3. Monitor specific process\n";
            std::cout << "  4. Exit\n\n";
            std::cout << "Choice: ";

            int choice;
            std::cin >> choice;

            switch (choice) {
                case 1:
                    // Just refresh (loop continues)
                    break;

                case 2: {
                    std::cout << "Enter Process ID (PID): ";
                    DWORD pid;
                    std::cin >> pid;

                    auto it = std::find_if(processes.begin(), processes.end(),
                        [pid](const ProcessInfo& p) { return p.pid == pid; });

                    if (it != processes.end()) {
                        displayProcessDetails(*it);
                    } else {
                        std::cout << "Process not found!\n";
                        std::this_thread::sleep_for(std::chrono::seconds(2));
                    }
                    break;
                }

                case 3: {
                    std::cout << "Enter Process ID (PID) to monitor: ";
                    DWORD pid;
                    std::cin >> pid;
                    monitorProcess(pid);
                    break;
                }

                case 4:
                    running = false;
                    break;

                default:
                    std::cout << "Invalid choice!\n";
                    std::this_thread::sleep_for(std::chrono::seconds(1));
            }
        }
    }

    void monitorProcess(DWORD pid) {
        clearScreen();
        std::cout << "Monitoring Process ID: " << pid << "\n";
        std::cout << "Press Ctrl+C to stop...\n\n";

        while (true) {
            HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pid);
            if (hProcess == NULL) {
                std::cout << "Process terminated or access denied.\n";
                break;
            }

            PROCESS_MEMORY_COUNTERS_EX pmc;
            if (GetProcessMemoryInfo(hProcess, (PROCESS_MEMORY_COUNTERS*)&pmc, sizeof(pmc))) {
                // Clear previous line
                std::cout << "\r";
                std::cout << "Working Set: " << std::setw(12) << formatBytes(pmc.WorkingSetSize)
                          << " | Private: " << std::setw(12) << formatBytes(pmc.PrivateUsage)
                          << " | Peak: " << std::setw(12) << formatBytes(pmc.PeakWorkingSetSize)
                          << std::flush;
            }

            CloseHandle(hProcess);
            std::this_thread::sleep_for(std::chrono::milliseconds(500));
        }

        std::cout << "\n\nPress Enter to return to menu...";
        std::cin.ignore();
        std::cin.get();
    }

    void showHelp() {
        std::cout << "\n";
        std::cout << "╔════════════════════════════════════════════════════════════════════════╗\n";
        std::cout << "║                           MEMORY MONITOR                               ║\n";
        std::cout << "╚════════════════════════════════════════════════════════════════════════╝\n";
        std::cout << "\nUsage:\n";
        std::cout << "  memory_monitor                  Run in interactive mode\n";
        std::cout << "  memory_monitor -p <PID>         Monitor specific process\n";
        std::cout << "  memory_monitor -h               Show this help\n";
        std::cout << "\nFeatures:\n";
        std::cout << "  • System memory overview\n";
        std::cout << "  • Top memory-consuming processes\n";
        std::cout << "  • Detailed process information\n";
        std::cout << "  • Real-time process monitoring\n";
        std::cout << "\n";
    }
};

int main(int argc, char* argv[]) {
    MemoryMonitor monitor;

    if (argc == 1) {
        // Interactive mode
        monitor.runInteractive();
    } else if (argc == 2 && (std::string(argv[1]) == "-h" || std::string(argv[1]) == "--help")) {
        monitor.showHelp();
    } else if (argc == 3 && std::string(argv[1]) == "-p") {
        // Monitor specific process
        DWORD pid = std::stoul(argv[2]);
        monitor.monitorProcess(pid);
    } else {
        std::cerr << "Invalid arguments. Use -h for help.\n";
        return 1;
    }

    return 0;
}
