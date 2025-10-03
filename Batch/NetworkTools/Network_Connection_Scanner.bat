@echo off
setlocal EnableDelayedExpansion
title Network Connection Scanner
color 0B

:menu
cls
echo =======================================================================================
echo                          NETWORK CONNECTION SCANNER
echo =======================================================================================
echo.
echo   [1] View Active Connections
echo   [2] Check Open Ports
echo   [3] Test Internet Connection
echo   [4] Show Network Configuration
echo   [5] Display Network Statistics
echo   [6] Scan WiFi Networks
echo   [7] Export Network Report
echo   [8] Exit
echo.
echo =======================================================================================
echo.
set /p choice="Enter your choice (1-8): "

if "%choice%"=="1" goto active_connections
if "%choice%"=="2" goto open_ports
if "%choice%"=="3" goto test_connection
if "%choice%"=="4" goto network_config
if "%choice%"=="5" goto network_stats
if "%choice%"=="6" goto wifi_scan
if "%choice%"=="7" goto export_report
if "%choice%"=="8" exit /b 0
goto menu

:active_connections
cls
echo =======================================================================================
echo                            ACTIVE NETWORK CONNECTIONS
echo =======================================================================================
echo.

netstat -an | findstr "ESTABLISHED LISTENING"

echo.
echo =======================================================================================
pause
goto menu

:open_ports
cls
echo =======================================================================================
echo                              CHECKING OPEN PORTS
echo =======================================================================================
echo.
echo Checking common ports...
echo.

set "ports=21 22 23 25 80 443 445 1433 3306 3389 8080"

for %%p in (!ports!) do (
    netstat -an | findstr ":%%p " | findstr "LISTENING" >nul 2>&1
    if !errorlevel!==0 (
        echo Port %%p: OPEN
    )
)

echo.
echo Detailed port listing:
echo ----------------------
netstat -an | findstr "LISTENING"

echo.
echo =======================================================================================
pause
goto menu

:test_connection
cls
echo =======================================================================================
echo                            INTERNET CONNECTION TEST
echo =======================================================================================
echo.

echo Testing connectivity to Google DNS (8.8.8.8)...
ping -n 4 8.8.8.8

echo.
echo Testing connectivity to Google.com...
ping -n 4 google.com

echo.
echo Testing connectivity to Cloudflare DNS (1.1.1.1)...
ping -n 4 1.1.1.1

echo.
echo =======================================================================================
pause
goto menu

:network_config
cls
echo =======================================================================================
echo                           NETWORK CONFIGURATION
echo =======================================================================================
echo.

ipconfig /all

echo.
echo =======================================================================================
pause
goto menu

:network_stats
cls
echo =======================================================================================
echo                           NETWORK STATISTICS
echo =======================================================================================
echo.

echo Interface Statistics:
echo --------------------
netstat -e

echo.
echo Protocol Statistics:
echo -------------------
netstat -s | more

echo.
echo =======================================================================================
pause
goto menu

:wifi_scan
cls
echo =======================================================================================
echo                            WIFI NETWORK SCANNER
echo =======================================================================================
echo.

echo Available WiFi Networks:
echo -----------------------
netsh wlan show networks

echo.
echo Current WiFi Connection:
echo -----------------------
netsh wlan show interfaces

echo.
echo =======================================================================================
pause
goto menu

:export_report
cls
echo =======================================================================================
echo                          EXPORTING NETWORK REPORT
echo =======================================================================================
echo.

set "report_file=network_report_%random%.txt"

echo Network Report > !report_file!
echo Generated: %date% %time% >> !report_file!
echo ======================================================================================= >> !report_file!
echo. >> !report_file!

echo System Information: >> !report_file!
echo ------------------- >> !report_file!
echo Computer: %COMPUTERNAME% >> !report_file!
echo User: %USERNAME% >> !report_file!
echo. >> !report_file!

echo Network Configuration: >> !report_file!
echo --------------------- >> !report_file!
ipconfig /all >> !report_file! 2>nul
echo. >> !report_file!

echo Active Connections: >> !report_file!
echo ------------------ >> !report_file!
netstat -an >> !report_file! 2>nul
echo. >> !report_file!

echo Routing Table: >> !report_file!
echo ------------- >> !report_file!
route print >> !report_file! 2>nul
echo. >> !report_file!

echo ARP Table: >> !report_file!
echo --------- >> !report_file!
arp -a >> !report_file! 2>nul

echo.
echo Report exported to: !report_file!
echo.
echo =======================================================================================
pause
goto menu