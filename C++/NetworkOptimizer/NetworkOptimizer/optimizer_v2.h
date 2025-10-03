#pragma once
#include <windows.h>
#include <string>
#include <vector>

struct OptimizationResult {
    bool success;
    std::wstring message;
    int appliedCount;
    int totalCount;
};

struct PingResult {
    int minPing;
    int maxPing;
    int avgPing;
    int packetLoss;
};

struct NetworkTweak {
    std::wstring name;
    std::wstring description;
    HKEY rootKey;
    std::wstring subKey;
    std::wstring valueName;
    DWORD value;
    bool isPerInterface;
};

class NetworkOptimizer {
public:
    static OptimizationResult ApplyOptimizations(HWND progressBar = NULL);
    static OptimizationResult RestoreDefaults(HWND progressBar = NULL);
    static PingResult TestPing(const std::wstring& host);
    static bool IsAdministrator();
    static std::vector<NetworkTweak> GetTweaksList();
    static int GetTweaksCount();

private:
    static OptimizationResult ApplyTweak(const NetworkTweak& tweak);
    static OptimizationResult RestoreTweak(const NetworkTweak& tweak);
    static std::wstring GetAllNetworkInterfaces();
};
