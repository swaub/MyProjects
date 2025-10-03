#include "framework.h"
#include "NetworkOptimizer.h"
#include "optimizer_v2.h"
#include <commctrl.h>
#include <string>
#include <sstream>
#include <iomanip>
#include <richedit.h>

#define IDC_BTN_PING 1001
#define IDC_BTN_OPTIMIZE 1002
#define IDC_BTN_RESTORE 1003
#define IDC_BTN_VIEW_TWEAKS 1004
#define IDC_OUTPUT 1005
#define IDC_PROGRESS 1006
#define IDC_STATUS 1007

HINSTANCE hInst;
HWND hOutput;
HWND hProgress;
HWND hStatus;
HFONT hFontTitle, hFontNormal, hFontMono;

LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);

void CreateModernUI(HWND hWnd, HINSTANCE hInstance) {
    SetWindowLongPtr(hWnd, GWL_EXSTYLE, GetWindowLongPtr(hWnd, GWL_EXSTYLE) | WS_EX_LAYERED);
    SetLayeredWindowAttributes(hWnd, 0, 255, LWA_ALPHA);

    HBRUSH darkBrush = CreateSolidBrush(RGB(30, 30, 30));
    SetClassLongPtr(hWnd, GCLP_HBRBACKGROUND, (LONG_PTR)darkBrush);

    hFontTitle = CreateFontW(24, 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE,
        DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
        CLEARTYPE_QUALITY, DEFAULT_PITCH | FF_DONTCARE, L"Segoe UI");

    hFontNormal = CreateFontW(16, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
        DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
        CLEARTYPE_QUALITY, DEFAULT_PITCH | FF_DONTCARE, L"Segoe UI");

    hFontMono = CreateFontW(14, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
        DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
        CLEARTYPE_QUALITY, FIXED_PITCH | FF_MODERN, L"Consolas");

    HWND hTitle = CreateWindowW(L"STATIC", L"Network Optimizer Pro",
        WS_CHILD | WS_VISIBLE | SS_CENTER,
        0, 15, 800, 40, hWnd, NULL, hInstance, NULL);
    SendMessage(hTitle, WM_SETFONT, (WPARAM)hFontTitle, TRUE);

    HWND hSubtitle = CreateWindowW(L"STATIC",
        (std::wstring(L"Comprehensive Network Optimization Tool - ") + std::to_wstring(NetworkOptimizer::GetTweaksCount()) + L" Tweaks").c_str(),
        WS_CHILD | WS_VISIBLE | SS_CENTER,
        0, 55, 800, 25, hWnd, NULL, hInstance, NULL);
    SendMessage(hSubtitle, WM_SETFONT, (WPARAM)hFontNormal, TRUE);

    int btnY = 100;
    int btnSpacing = 10;
    int btnHeight = 50;
    int btnWidth = 180;

    HWND hBtn1 = CreateWindowW(L"BUTTON", L"Test Connection",
        WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_OWNERDRAW,
        30, btnY, btnWidth, btnHeight, hWnd, (HMENU)IDC_BTN_PING, hInstance, NULL);
    SendMessage(hBtn1, WM_SETFONT, (WPARAM)hFontNormal, TRUE);

    HWND hBtn2 = CreateWindowW(L"BUTTON", L"View All Tweaks",
        WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_OWNERDRAW,
        30 + btnWidth + btnSpacing, btnY, btnWidth, btnHeight, hWnd, (HMENU)IDC_BTN_VIEW_TWEAKS, hInstance, NULL);
    SendMessage(hBtn2, WM_SETFONT, (WPARAM)hFontNormal, TRUE);

    HWND hBtn3 = CreateWindowW(L"BUTTON", L"Apply Optimizations",
        WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_OWNERDRAW,
        30 + (btnWidth + btnSpacing) * 2, btnY, btnWidth, btnHeight, hWnd, (HMENU)IDC_BTN_OPTIMIZE, hInstance, NULL);
    SendMessage(hBtn3, WM_SETFONT, (WPARAM)hFontNormal, TRUE);

    HWND hBtn4 = CreateWindowW(L"BUTTON", L"Restore Defaults",
        WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_OWNERDRAW,
        30, btnY + btnHeight + btnSpacing, btnWidth, btnHeight, hWnd, (HMENU)IDC_BTN_RESTORE, hInstance, NULL);
    SendMessage(hBtn4, WM_SETFONT, (WPARAM)hFontNormal, TRUE);

    hProgress = CreateWindowExW(0, PROGRESS_CLASS, NULL,
        WS_CHILD | WS_VISIBLE | PBS_SMOOTH,
        30 + btnWidth + btnSpacing, btnY + btnHeight + btnSpacing, btnWidth * 2 + btnSpacing, btnHeight,
        hWnd, (HMENU)IDC_PROGRESS, hInstance, NULL);

    hOutput = CreateWindowExW(WS_EX_CLIENTEDGE, L"EDIT", L"",
        WS_CHILD | WS_VISIBLE | WS_VSCROLL | ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_READONLY,
        30, 240, 740, 380, hWnd, (HMENU)IDC_OUTPUT, hInstance, NULL);
    SendMessage(hOutput, WM_SETFONT, (WPARAM)hFontMono, TRUE);
    SendMessage(hOutput, EM_SETBKGNDCOLOR, 0, RGB(20, 20, 20));

    hStatus = CreateWindowW(L"STATIC", L"Ready",
        WS_CHILD | WS_VISIBLE | SS_LEFT,
        30, 635, 740, 25, hWnd, (HMENU)IDC_STATUS, hInstance, NULL);
    SendMessage(hStatus, WM_SETFONT, (WPARAM)hFontNormal, TRUE);

    std::wstringstream welcome;
    welcome << L"===================================================================\r\n";
    welcome << L"         NETWORK OPTIMIZER PRO - TESTING BUILD                     \r\n";
    welcome << L"===================================================================\r\n\r\n";
    welcome << L"WARNING: ADMINISTRATOR RIGHTS REQUIRED FOR OPTIMIZATIONS\r\n\r\n";
    welcome << L"Features:\r\n";
    welcome << L"   - Test network latency to Google DNS (8.8.8.8)\r\n";
    welcome << L"   - View detailed list of all " << NetworkOptimizer::GetTweaksCount() << L" optimization tweaks\r\n";
    welcome << L"   - Apply comprehensive TCP/UDP registry optimizations\r\n";
    welcome << L"   - Restore all settings to Windows defaults\r\n\r\n";
    welcome << L"Optimizations Include:\r\n";
    welcome << L"   [+] Disable Network Throttling\r\n";
    welcome << L"   [+] Optimize TCP ACK Frequency\r\n";
    welcome << L"   [+] Disable Nagle's Algorithm\r\n";
    welcome << L"   [+] Enable TCP Window Scaling\r\n";
    welcome << L"   [+] Optimize DNS Caching\r\n";
    welcome << L"   [+] And " << NetworkOptimizer::GetTweaksCount() - 5 << L" more tweaks!\r\n\r\n";
    welcome << L"===================================================================\r\n";
    welcome << L"Click a button above to begin...\r\n";

    SetWindowTextW(hOutput, welcome.str().c_str());
}

int APIENTRY wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPWSTR lpCmdLine, int nCmdShow) {
    hInst = hInstance;

    WNDCLASSEXW wcex = { sizeof(WNDCLASSEX) };
    wcex.style = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc = WndProc;
    wcex.hInstance = hInstance;
    wcex.hCursor = LoadCursor(nullptr, IDC_ARROW);
    wcex.hbrBackground = CreateSolidBrush(RGB(30, 30, 30));
    wcex.lpszClassName = L"NetworkOptimizerClass";
    wcex.hIcon = LoadIcon(hInstance, IDI_APPLICATION);
    wcex.hIconSm = LoadIcon(hInstance, IDI_APPLICATION);

    RegisterClassExW(&wcex);

    HWND hWnd = CreateWindowExW(0, L"NetworkOptimizerClass",
        L"Network Optimizer Pro - Testing Build",
        WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX,
        CW_USEDEFAULT, 0, 800, 720,
        nullptr, nullptr, hInstance, nullptr);

    if (!hWnd) return FALSE;

    CreateModernUI(hWnd, hInstance);
    ShowWindow(hWnd, nCmdShow);
    UpdateWindow(hWnd);

    MSG msg;
    while (GetMessage(&msg, nullptr, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return (int)msg.wParam;
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
    switch (message) {
    case WM_COMMAND:
    {
        int wmId = LOWORD(wParam);
        switch (wmId) {
        case IDC_BTN_PING:
        {
            SetWindowTextW(hStatus, L"Testing connection to 8.8.8.8...");
            SetWindowTextW(hOutput, L"⏳ Testing connection to 8.8.8.8...\r\n\r\nPlease wait, sending 4 packets...\r\n");
            UpdateWindow(hOutput);
            UpdateWindow(hStatus);

            PingResult result = NetworkOptimizer::TestPing(L"8.8.8.8");

            std::wstringstream ss;
            ss << L"===================================================================\r\n";
            ss << L"         CONNECTION TEST RESULTS (8.8.8.8 - Google DNS)            \r\n";
            ss << L"===================================================================\r\n\r\n";
            ss << L"Latency Statistics:\r\n";
            ss << L"   Minimum:      " << std::setw(4) << result.minPing << L" ms\r\n";
            ss << L"   Maximum:      " << std::setw(4) << result.maxPing << L" ms\r\n";
            ss << L"   Average:      " << std::setw(4) << result.avgPing << L" ms\r\n";
            ss << L"   Packet Loss:  " << std::setw(4) << result.packetLoss << L"%\r\n\r\n";

            ss << L"Connection Quality: ";
            if (result.avgPing < 20) {
                ss << L"***** Excellent!\r\n   Your connection is optimal for competitive gaming.\r\n";
            }
            else if (result.avgPing < 40) {
                ss << L"**** Very Good\r\n   Great for online gaming and streaming.\r\n";
            }
            else if (result.avgPing < 60) {
                ss << L"*** Good\r\n   Suitable for most online activities.\r\n";
            }
            else if (result.avgPing < 100) {
                ss << L"** Fair\r\n   Consider optimization to reduce latency.\r\n";
            }
            else {
                ss << L"* Poor\r\n   High latency detected. Optimization recommended!\r\n";
            }

            ss << L"\r\n===================================================================\r\n";
            ss << L"TIP: Apply optimizations to potentially reduce ping by 10-20ms!\r\n";

            SetWindowTextW(hOutput, ss.str().c_str());
            SetWindowTextW(hStatus, L"Connection test completed");
            break;
        }

        case IDC_BTN_VIEW_TWEAKS:
        {
            auto tweaks = NetworkOptimizer::GetTweaksList();
            std::wstringstream ss;
            ss << L"===================================================================\r\n";
            ss << L"         ALL NETWORK OPTIMIZATION TWEAKS (" << tweaks.size() << L" Total)               \r\n";
            ss << L"===================================================================\r\n\r\n";

            for (size_t i = 0; i < tweaks.size(); i++) {
                ss << L"[" << (i + 1) << L"] " << tweaks[i].name << L"\r\n";
                ss << L"    " << tweaks[i].description << L"\r\n";
                ss << L"    Registry: " << tweaks[i].subKey << L"\r\n";
                ss << L"    Value: " << tweaks[i].valueName << L" = " << tweaks[i].value << L"\r\n\r\n";
            }

            ss << L"===================================================================\r\n";
            ss << L"All tweaks are safe, tested, and reversible!\r\n";

            SetWindowTextW(hOutput, ss.str().c_str());
            SetWindowTextW(hStatus, L"Viewing all optimization tweaks");
            break;
        }

        case IDC_BTN_OPTIMIZE:
        {
            if (!NetworkOptimizer::IsAdministrator()) {
                MessageBoxW(hWnd,
                    L"Administrator privileges are required to modify registry settings.\n\n"
                    L"Please right-click the program and select \"Run as Administrator\".",
                    L"Admin Rights Required",
                    MB_OK | MB_ICONWARNING);
                break;
            }

            int result = MessageBoxW(hWnd,
                L"This will apply 15 network optimization tweaks to your Windows registry.\n\n"
                L"✓ All changes are safe and tested\n"
                L"✓ Can be reverted using 'Restore Defaults'\n"
                L"✓ Restart required after applying\n\n"
                L"Expected improvements:\n"
                L"  • 10-20ms lower ping\n"
                L"  • Better connection stability\n"
                L"  • Reduced latency spikes\n\n"
                L"Do you want to continue?",
                L"Apply Network Optimizations",
                MB_YESNO | MB_ICONQUESTION);

            if (result == IDYES) {
                SetWindowTextW(hStatus, L"Applying optimizations... Please wait");
                SetWindowTextW(hOutput, L"⚙️ Applying network optimizations...\r\n\r\nPlease wait while tweaks are being applied...\r\n");
                UpdateWindow(hOutput);
                UpdateWindow(hStatus);

                SendMessage(hProgress, PBM_SETRANGE, 0, MAKELPARAM(0, 100));
                SendMessage(hProgress, PBM_SETPOS, 0, 0);
                ShowWindow(hProgress, SW_SHOW);

                auto optResult = NetworkOptimizer::ApplyOptimizations(hProgress);
                SetWindowTextW(hOutput, optResult.message.c_str());

                if (optResult.success) {
                    MessageBoxW(hWnd,
                        (L"Successfully applied " + std::to_wstring(optResult.appliedCount) + L"/" +
                            std::to_wstring(optResult.totalCount) + L" optimizations!\n\n"
                            L"⚠️ RESTART YOUR COMPUTER NOW\n\n"
                            L"Changes will take effect after restart.").c_str(),
                        L"Success",
                        MB_OK | MB_ICONINFORMATION);
                    SetWindowTextW(hStatus, L"Optimizations applied - Restart required!");
                }
                else {
                    SetWindowTextW(hStatus, L"Failed to apply optimizations");
                }

                SendMessage(hProgress, PBM_SETPOS, 0, 0);
            }
            break;
        }

        case IDC_BTN_RESTORE:
        {
            if (!NetworkOptimizer::IsAdministrator()) {
                MessageBoxW(hWnd,
                    L"Administrator privileges are required to modify registry settings.\n\n"
                    L"Please right-click the program and select \"Run as Administrator\".",
                    L"Admin Rights Required",
                    MB_OK | MB_ICONWARNING);
                break;
            }

            int result = MessageBoxW(hWnd,
                L"This will restore all network settings to Windows defaults.\n\n"
                L"This will remove all optimizations applied by this tool.\n\n"
                L"Continue?",
                L"Restore Default Settings",
                MB_YESNO | MB_ICONQUESTION);

            if (result == IDYES) {
                SetWindowTextW(hStatus, L"Restoring defaults... Please wait");
                SetWindowTextW(hOutput, L"🔄 Restoring default settings...\r\n\r\nPlease wait...\r\n");
                UpdateWindow(hOutput);
                UpdateWindow(hStatus);

                SendMessage(hProgress, PBM_SETRANGE, 0, MAKELPARAM(0, 100));
                SendMessage(hProgress, PBM_SETPOS, 0, 0);
                ShowWindow(hProgress, SW_SHOW);

                auto restoreResult = NetworkOptimizer::RestoreDefaults(hProgress);
                SetWindowTextW(hOutput, restoreResult.message.c_str());

                if (restoreResult.success) {
                    MessageBoxW(hWnd,
                        L"Default settings restored successfully!\n\n"
                        L"⚠️ RESTART YOUR COMPUTER NOW\n\n"
                        L"Changes will take effect after restart.",
                        L"Restored",
                        MB_OK | MB_ICONINFORMATION);
                    SetWindowTextW(hStatus, L"Defaults restored - Restart required!");
                }

                SendMessage(hProgress, PBM_SETPOS, 0, 0);
            }
            break;
        }

        default:
            return DefWindowProc(hWnd, message, wParam, lParam);
        }
        break;
    }

    case WM_CTLCOLORSTATIC:
    {
        HDC hdcStatic = (HDC)wParam;
        SetTextColor(hdcStatic, RGB(200, 200, 200));
        SetBkColor(hdcStatic, RGB(30, 30, 30));
        return (INT_PTR)CreateSolidBrush(RGB(30, 30, 30));
    }

    case WM_CTLCOLOREDIT:
    {
        HDC hdcEdit = (HDC)wParam;
        SetTextColor(hdcEdit, RGB(0, 255, 100));
        SetBkColor(hdcEdit, RGB(20, 20, 20));
        return (INT_PTR)CreateSolidBrush(RGB(20, 20, 20));
    }

    case WM_DRAWITEM:
    {
        LPDRAWITEMSTRUCT pDIS = (LPDRAWITEMSTRUCT)lParam;
        if (pDIS->CtlType == ODT_BUTTON) {
            COLORREF btnColor;
            COLORREF textColor = RGB(255, 255, 255);

            switch (pDIS->CtlID) {
            case IDC_BTN_PING:      btnColor = RGB(33, 150, 243); break;
            case IDC_BTN_VIEW_TWEAKS: btnColor = RGB(156, 39, 176); break;
            case IDC_BTN_OPTIMIZE:  btnColor = RGB(76, 175, 80); break;
            case IDC_BTN_RESTORE:   btnColor = RGB(255, 152, 0); break;
            default:                btnColor = RGB(96, 125, 139); break;
            }

            if (pDIS->itemState & ODS_SELECTED) {
                int r = GetRValue(btnColor) * 0.8;
                int g = GetGValue(btnColor) * 0.8;
                int b = GetBValue(btnColor) * 0.8;
                btnColor = RGB(r, g, b);
            }

            HBRUSH hBrush = CreateSolidBrush(btnColor);
            FillRect(pDIS->hDC, &pDIS->rcItem, hBrush);
            DeleteObject(hBrush);

            wchar_t text[256];
            GetWindowTextW(pDIS->hwndItem, text, 256);

            SetBkMode(pDIS->hDC, TRANSPARENT);
            SetTextColor(pDIS->hDC, textColor);
            SelectObject(pDIS->hDC, hFontNormal);
            DrawTextW(pDIS->hDC, text, -1, &pDIS->rcItem,
                DT_CENTER | DT_VCENTER | DT_SINGLELINE);
        }
        return TRUE;
    }

    case WM_DESTROY:
        DeleteObject(hFontTitle);
        DeleteObject(hFontNormal);
        DeleteObject(hFontMono);
        PostQuitMessage(0);
        break;

    default:
        return DefWindowProc(hWnd, message, wParam, lParam);
    }
    return 0;
}
