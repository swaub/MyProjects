// NetworkOptimizer.cpp : Defines the entry point for the application.
//

#include "framework.h"
#include "NetworkOptimizer.h"
#include "optimizer.h"
#include <commctrl.h>
#include <string>
#include <sstream>

#define MAX_LOADSTRING 100

#define IDC_BTN_PING 1001
#define IDC_BTN_OPTIMIZE 1002
#define IDC_BTN_RESTORE 1003
#define IDC_OUTPUT 1004

// Global Variables:
HINSTANCE hInst;                                // current instance
WCHAR szTitle[MAX_LOADSTRING];                  // The title bar text
WCHAR szWindowClass[MAX_LOADSTRING];            // the main window class name
HWND hOutput;                                   // Output text box

// Forward declarations of functions included in this code module:
ATOM                MyRegisterClass(HINSTANCE hInstance);
BOOL                InitInstance(HINSTANCE, int);
LRESULT CALLBACK    WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK    About(HWND, UINT, WPARAM, LPARAM);

int APIENTRY wWinMain(_In_ HINSTANCE hInstance,
                     _In_opt_ HINSTANCE hPrevInstance,
                     _In_ LPWSTR    lpCmdLine,
                     _In_ int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

    // TODO: Place code here.

    // Initialize global strings
    LoadStringW(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
    LoadStringW(hInstance, IDC_NETWORKOPTIMIZER, szWindowClass, MAX_LOADSTRING);
    MyRegisterClass(hInstance);

    // Perform application initialization:
    if (!InitInstance (hInstance, nCmdShow))
    {
        return FALSE;
    }

    HACCEL hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_NETWORKOPTIMIZER));

    MSG msg;

    // Main message loop:
    while (GetMessage(&msg, nullptr, 0, 0))
    {
        if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg))
        {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
    }

    return (int) msg.wParam;
}



//
//  FUNCTION: MyRegisterClass()
//
//  PURPOSE: Registers the window class.
//
ATOM MyRegisterClass(HINSTANCE hInstance)
{
    WNDCLASSEXW wcex;

    wcex.cbSize = sizeof(WNDCLASSEX);

    wcex.style          = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc    = WndProc;
    wcex.cbClsExtra     = 0;
    wcex.cbWndExtra     = 0;
    wcex.hInstance      = hInstance;
    wcex.hIcon          = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_NETWORKOPTIMIZER));
    wcex.hCursor        = LoadCursor(nullptr, IDC_ARROW);
    wcex.hbrBackground  = (HBRUSH)(COLOR_WINDOW+1);
    wcex.lpszMenuName   = MAKEINTRESOURCEW(IDC_NETWORKOPTIMIZER);
    wcex.lpszClassName  = szWindowClass;
    wcex.hIconSm        = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

    return RegisterClassExW(&wcex);
}

//
//   FUNCTION: InitInstance(HINSTANCE, int)
//
//   PURPOSE: Saves instance handle and creates main window
//
//   COMMENTS:
//
//        In this function, we save the instance handle in a global variable and
//        create and display the main program window.
//
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
   hInst = hInstance; // Store instance handle in our global variable

   HWND hWnd = CreateWindowW(szWindowClass, L"Network Optimizer - TESTING",
      WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, 0, 600, 500, nullptr, nullptr, hInstance, nullptr);

   if (!hWnd)
   {
      return FALSE;
   }

   // Create buttons
   CreateWindowW(L"BUTTON", L"Test Ping (8.8.8.8)",
      WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
      20, 20, 180, 40, hWnd, (HMENU)IDC_BTN_PING, hInstance, NULL);

   CreateWindowW(L"BUTTON", L"Apply Optimizations",
      WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
      220, 20, 180, 40, hWnd, (HMENU)IDC_BTN_OPTIMIZE, hInstance, NULL);

   CreateWindowW(L"BUTTON", L"Restore Defaults",
      WS_TABSTOP | WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON,
      420, 20, 150, 40, hWnd, (HMENU)IDC_BTN_RESTORE, hInstance, NULL);

   // Create output text box
   hOutput = CreateWindowExW(WS_EX_CLIENTEDGE, L"EDIT", L"",
      WS_CHILD | WS_VISIBLE | WS_VSCROLL | ES_LEFT | ES_MULTILINE | ES_AUTOVSCROLL | ES_READONLY,
      20, 80, 550, 350, hWnd, (HMENU)IDC_OUTPUT, hInstance, NULL);

   // Set font
   HFONT hFont = CreateFontW(16, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
      DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
      DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE, L"Consolas");
   SendMessage(hOutput, WM_SETFONT, (WPARAM)hFont, TRUE);

   // Initial message
   SetWindowTextW(hOutput,
      L"Network Optimizer - Testing Build\r\n"
      L"=====================================\r\n\r\n"
      L"⚠️ ADMINISTRATOR RIGHTS REQUIRED ⚠️\r\n\r\n"
      L"Features:\r\n"
      L"• Test ping to 8.8.8.8 (Google DNS)\r\n"
      L"• Apply 5 safe network optimizations\r\n"
      L"• Restore all defaults\r\n\r\n"
      L"Click a button to begin...\r\n");

   ShowWindow(hWnd, nCmdShow);
   UpdateWindow(hWnd);

   return TRUE;
}

//
//  FUNCTION: WndProc(HWND, UINT, WPARAM, LPARAM)
//
//  PURPOSE: Processes messages for the main window.
//
//  WM_COMMAND  - process the application menu
//  WM_PAINT    - Paint the main window
//  WM_DESTROY  - post a quit message and return
//
//
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    switch (message)
    {
    case WM_COMMAND:
        {
            int wmId = LOWORD(wParam);
            // Parse the menu selections:
            switch (wmId)
            {
            case IDC_BTN_PING:
            {
                SetWindowTextW(hOutput, L"Testing ping to 8.8.8.8...\r\nPlease wait...\r\n");
                UpdateWindow(hOutput);

                PingResult result = NetworkOptimizer::TestPing(L"8.8.8.8");

                std::wstringstream ss;
                ss << L"Ping Test Results (8.8.8.8)\r\n";
                ss << L"=============================\r\n\r\n";
                ss << L"Min Ping:    " << result.minPing << L" ms\r\n";
                ss << L"Max Ping:    " << result.maxPing << L" ms\r\n";
                ss << L"Avg Ping:    " << result.avgPing << L" ms\r\n";
                ss << L"Packet Loss: " << result.packetLoss << L"%\r\n\r\n";

                if (result.avgPing < 30) {
                    ss << L"Status: Excellent connection! ✓\r\n";
                }
                else if (result.avgPing < 60) {
                    ss << L"Status: Good connection\r\n";
                }
                else {
                    ss << L"Status: High latency detected\r\n";
                }

                SetWindowTextW(hOutput, ss.str().c_str());
                break;
            }

            case IDC_BTN_OPTIMIZE:
            {
                if (!NetworkOptimizer::IsAdministrator()) {
                    MessageBoxW(hWnd,
                        L"Please run this program as Administrator!",
                        L"Admin Required",
                        MB_OK | MB_ICONWARNING);
                    break;
                }

                int result = MessageBoxW(hWnd,
                    L"This will modify Windows registry to optimize network performance.\n\n"
                    L"Changes can be reverted using 'Restore Defaults'.\n\n"
                    L"Continue?",
                    L"Apply Optimizations",
                    MB_YESNO | MB_ICONQUESTION);

                if (result == IDYES) {
                    SetWindowTextW(hOutput, L"Applying optimizations...\r\n");
                    UpdateWindow(hOutput);

                    auto optResult = NetworkOptimizer::ApplyOptimizations();
                    SetWindowTextW(hOutput, optResult.message.c_str());

                    if (optResult.success) {
                        MessageBoxW(hWnd,
                            L"Optimizations applied!\n\nPlease RESTART your computer for changes to take effect.",
                            L"Success",
                            MB_OK | MB_ICONINFORMATION);
                    }
                }
                break;
            }

            case IDC_BTN_RESTORE:
            {
                if (!NetworkOptimizer::IsAdministrator()) {
                    MessageBoxW(hWnd,
                        L"Please run this program as Administrator!",
                        L"Admin Required",
                        MB_OK | MB_ICONWARNING);
                    break;
                }

                int result = MessageBoxW(hWnd,
                    L"This will restore Windows default network settings.\n\n"
                    L"Continue?",
                    L"Restore Defaults",
                    MB_YESNO | MB_ICONQUESTION);

                if (result == IDYES) {
                    SetWindowTextW(hOutput, L"Restoring defaults...\r\n");
                    UpdateWindow(hOutput);

                    auto restoreResult = NetworkOptimizer::RestoreDefaults();
                    SetWindowTextW(hOutput, restoreResult.message.c_str());

                    if (restoreResult.success) {
                        MessageBoxW(hWnd,
                            L"Defaults restored!\n\nPlease RESTART your computer.",
                            L"Success",
                            MB_OK | MB_ICONINFORMATION);
                    }
                }
                break;
            }

            case IDM_ABOUT:
                DialogBox(hInst, MAKEINTRESOURCE(IDD_ABOUTBOX), hWnd, About);
                break;
            case IDM_EXIT:
                DestroyWindow(hWnd);
                break;
            default:
                return DefWindowProc(hWnd, message, wParam, lParam);
            }
        }
        break;
    case WM_PAINT:
        {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hWnd, &ps);
            // TODO: Add any drawing code that uses hdc here...
            EndPaint(hWnd, &ps);
        }
        break;
    case WM_DESTROY:
        PostQuitMessage(0);
        break;
    default:
        return DefWindowProc(hWnd, message, wParam, lParam);
    }
    return 0;
}

// Message handler for about box.
INT_PTR CALLBACK About(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    UNREFERENCED_PARAMETER(lParam);
    switch (message)
    {
    case WM_INITDIALOG:
        return (INT_PTR)TRUE;

    case WM_COMMAND:
        if (LOWORD(wParam) == IDOK || LOWORD(wParam) == IDCANCEL)
        {
            EndDialog(hDlg, LOWORD(wParam));
            return (INT_PTR)TRUE;
        }
        break;
    }
    return (INT_PTR)FALSE;
}
