@echo off
setlocal EnableDelayedExpansion
title Network Traffic Monitor
color 0B

:menu
cls
echo ================================================================================
echo                        NETWORK TRAFFIC MONITOR
echo ================================================================================
echo.
echo   [1] Monitor Active Connections
echo   [2] Network Statistics
echo   [3] Bandwidth Usage
echo   [4] Connection Count by Process
echo   [5] Foreign IP Connections
echo   [6] Network Interface Details
echo   [7] Packet Statistics
echo   [8] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-8): "

if "%choice%"=="1" goto monitor_connections
if "%choice%"=="2" goto network_stats
if "%choice%"=="3" goto bandwidth_usage
if "%choice%"=="4" goto process_connections
if "%choice%"=="5" goto foreign_ips
if "%choice%"=="6" goto interface_details
if "%choice%"=="7" goto packet_stats
if "%choice%"=="8" exit /b 0
goto menu

:monitor_connections
cls
echo ================================================================================
echo                      MONITORING ACTIVE CONNECTIONS
echo ================================================================================
echo.
echo Press Ctrl+C to stop monitoring...
echo ----------------------------------------
:monitor_loop
cls
echo Active Connections at %time%:
echo.
echo Proto  Local Address         Foreign Address       State         PID
echo ----------------------------------------------------------------------
netstat -ano | findstr "ESTABLISHED TIME_WAIT CLOSE_WAIT"
timeout /t 2 /nobreak >nul
goto monitor_loop

:network_stats
cls
echo ================================================================================
echo                         NETWORK STATISTICS
echo ================================================================================
echo.
echo Interface Statistics:
echo ----------------------------------------
netstat -e
echo.
echo Protocol Statistics:
echo ----------------------------------------
netstat -s
echo.
pause
goto menu

:bandwidth_usage
cls
echo ================================================================================
echo                          BANDWIDTH USAGE
echo ================================================================================
echo.
echo Network Adapter Performance:
echo ----------------------------------------
typeperf "\Network Interface(*)\Bytes Total/sec" -sc 1 2>nul
echo.
echo Current Network Load:
echo ----------------------------------------
for /f "tokens=2 delims==" %%a in ('wmic path Win32_PerfRawData_Tcpip_NetworkInterface get BytesReceivedPerSec /value 2^>nul ^| findstr "="') do (
    if not "%%a"=="" (
        set /a rx_bytes=%%a/1024
        echo Receive Rate: !rx_bytes! KB/s
    )
)
for /f "tokens=2 delims==" %%a in ('wmic path Win32_PerfRawData_Tcpip_NetworkInterface get BytesSentPerSec /value 2^>nul ^| findstr "="') do (
    if not "%%a"=="" (
        set /a tx_bytes=%%a/1024
        echo Send Rate: !tx_bytes! KB/s
    )
)
echo.
pause
goto menu

:process_connections
cls
echo ================================================================================
echo                   CONNECTION COUNT BY PROCESS
echo ================================================================================
echo.
echo Process Name          Connection Count
echo ----------------------------------------
for /f "tokens=5" %%a in ('netstat -ano ^| findstr "ESTABLISHED" ^| sort /u') do (
    set pid=%%a
    for /f "tokens=1" %%b in ('tasklist /fi "PID eq !pid!" 2^>nul ^| findstr "!pid!"') do (
        set proc_name=%%b
        set /a count=0
        for /f %%c in ('netstat -ano ^| findstr "!pid!" ^| find /c "ESTABLISHED"') do set count=%%c
        if !count! gtr 0 echo !proc_name!          !count!
    )
) | sort /u
echo.
pause
goto menu

:foreign_ips
cls
echo ================================================================================
echo                      FOREIGN IP CONNECTIONS
echo ================================================================================
echo.
echo External IP addresses connected:
echo ----------------------------------------
for /f "tokens=3" %%a in ('netstat -an ^| findstr "ESTABLISHED" ^| findstr /v "127.0.0.1" ^| findstr /v "::1"') do (
    for /f "tokens=1 delims=:" %%b in ("%%a") do (
        set ip=%%b
        if not "!ip!"=="0.0.0.0" if not "!ip!"=="*" echo !ip!
    )
) | sort /u
echo.
echo Geographical lookup (requires internet):
echo ----------------------------------------
set /p lookup_ip="Enter IP to lookup (or press Enter to skip): "
if not "%lookup_ip%"=="" (
    nslookup %lookup_ip% 2>nul | findstr "Name"
)
echo.
pause
goto menu

:interface_details
cls
echo ================================================================================
echo                      NETWORK INTERFACE DETAILS
echo ================================================================================
echo.
echo Network Adapters:
echo ----------------------------------------
wmic nic get Name,Speed,MACAddress,NetConnectionStatus /format:table
echo.
echo Interface Configuration:
echo ----------------------------------------
ipconfig /all | findstr "adapter IPv4 Subnet Gateway DNS"
echo.
pause
goto menu

:packet_stats
cls
echo ================================================================================
echo                         PACKET STATISTICS
echo ================================================================================
echo.
echo Packet Statistics:
echo ----------------------------------------
netstat -es
echo.
echo Errors and Discards:
echo ----------------------------------------
netstat -s | findstr "Errors Discards Failed"
echo.
echo ARP Statistics:
echo ----------------------------------------
arp -a | find /c "dynamic"
echo dynamic ARP entries
echo.
pause
goto menu