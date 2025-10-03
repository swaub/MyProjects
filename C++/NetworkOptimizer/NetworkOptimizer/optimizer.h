#pragma once
#include <windows.h>
#include <string>
#include <vector>

struct OptimizationResult {
    bool success;
    std::wstring message;
};

struct PingResult {
    int minPing;
    int maxPing;
    int avgPing;
    int packetLoss;
};

class NetworkOptimizer {
public:
    static OptimizationResult ApplyOptimizations();
    static OptimizationResult RestoreDefaults();
    static OptimizationResult CreateBackup();
    static PingResult TestPing(const std::wstring& host);
    static bool IsAdministrator();

private:
    static OptimizationResult SetRegistryValue(HKEY hKey, const std::wstring& subKey,
        const std::wstring& valueName, DWORD value, DWORD originalValue = 0);
    static std::vector<std::wstring> backupLog;
};
