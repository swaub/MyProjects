@echo off
setlocal EnableDelayedExpansion
title Advanced Port Scanner
color 0A

:menu
cls
echo ================================================================================
echo                          ADVANCED PORT SCANNER
echo ================================================================================
echo.
echo   [1] Scan Single Port
echo   [2] Scan Port Range
echo   [3] Scan Common Ports
echo   [4] Scan All Open Ports
echo   [5] Check Service on Port
echo   [6] Test Port Connection
echo   [7] Export Scan Results
echo   [8] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-8): "

if "%choice%"=="1" goto single_port
if "%choice%"=="2" goto port_range
if "%choice%"=="3" goto common_ports
if "%choice%"=="4" goto all_ports
if "%choice%"=="5" goto check_service
if "%choice%"=="6" goto test_connection
if "%choice%"=="7" goto export_results
if "%choice%"=="8" exit /b 0
goto menu

:single_port
cls
echo ================================================================================
echo                           SCAN SINGLE PORT
echo ================================================================================
echo.
set /p target="Enter target IP or hostname (localhost for local): "
set /p port="Enter port number: "
echo.
echo Scanning %target%:%port%...
echo ----------------------------------------
powershell -Command "Test-NetConnection -ComputerName %target% -Port %port% -InformationLevel Detailed" 2>nul
if %errorlevel%==0 (
    echo Port %port% is OPEN on %target%
) else (
    echo Port %port% is CLOSED or filtered on %target%
)
echo.
netstat -an | findstr ":%port% " | findstr "LISTENING"
echo.
pause
goto menu

:port_range
cls
echo ================================================================================
echo                           SCAN PORT RANGE
echo ================================================================================
echo.
set /p target="Enter target IP or hostname: "
set /p start_port="Enter start port: "
set /p end_port="Enter end port: "
echo.
echo Scanning %target% ports %start_port% to %end_port%...
echo ----------------------------------------
for /l %%p in (%start_port%,1,%end_port%) do (
    powershell -Command "$tcp = New-Object System.Net.Sockets.TcpClient; try { $tcp.Connect('%target%', %%p); Write-Host 'Port %%p: OPEN'; $tcp.Close() } catch { }" 2>nul
)
echo.
pause
goto menu

:common_ports
cls
echo ================================================================================
echo                          SCAN COMMON PORTS
echo ================================================================================
echo.
set /p target="Enter target IP or hostname: "
echo.
echo Scanning common ports on %target%...
echo ----------------------------------------
set "ports=21 22 23 25 53 80 110 135 139 143 443 445 1433 1521 3306 3389 5432 5900 8080 8443"
for %%p in (%ports%) do (
    set "service="
    if %%p==21 set "service=FTP"
    if %%p==22 set "service=SSH"
    if %%p==23 set "service=Telnet"
    if %%p==25 set "service=SMTP"
    if %%p==53 set "service=DNS"
    if %%p==80 set "service=HTTP"
    if %%p==110 set "service=POP3"
    if %%p==135 set "service=RPC"
    if %%p==139 set "service=NetBIOS"
    if %%p==143 set "service=IMAP"
    if %%p==443 set "service=HTTPS"
    if %%p==445 set "service=SMB"
    if %%p==1433 set "service=SQL Server"
    if %%p==1521 set "service=Oracle"
    if %%p==3306 set "service=MySQL"
    if %%p==3389 set "service=RDP"
    if %%p==5432 set "service=PostgreSQL"
    if %%p==5900 set "service=VNC"
    if %%p==8080 set "service=HTTP-Alt"
    if %%p==8443 set "service=HTTPS-Alt"

    powershell -Command "$tcp = New-Object System.Net.Sockets.TcpClient; try { $tcp.Connect('%target%', %%p); Write-Host 'Port %%p (!service!): OPEN'; $tcp.Close() } catch { Write-Host 'Port %%p (!service!): CLOSED' }" 2>nul
)
echo.
pause
goto menu

:all_ports
cls
echo ================================================================================
echo                         SCAN ALL OPEN PORTS
echo ================================================================================
echo.
echo Scanning all listening ports on local system...
echo ----------------------------------------
echo.
echo TCP Ports:
netstat -an | findstr "TCP.*LISTENING" | sort
echo.
echo UDP Ports:
netstat -an | findstr "UDP"
echo.
pause
goto menu

:check_service
cls
echo ================================================================================
echo                       CHECK SERVICE ON PORT
echo ================================================================================
echo.
set /p port="Enter port number: "
echo.
echo Services using port %port%:
echo ----------------------------------------
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%port% " ^| findstr "LISTENING"') do (
    set pid=%%a
    for /f "tokens=1" %%b in ('tasklist /fi "PID eq !pid!" ^| findstr "!pid!"') do (
        echo Process: %%b (PID: !pid!)
    )
)
echo.
pause
goto menu

:test_connection
cls
echo ================================================================================
echo                        TEST PORT CONNECTION
echo ================================================================================
echo.
set /p target="Enter target IP or hostname: "
set /p port="Enter port number: "
echo.
echo Testing connection to %target%:%port%...
echo ----------------------------------------
telnet %target% %port% 2>nul
if %errorlevel% neq 0 (
    echo.
    echo Connection failed or telnet not available.
    echo Trying PowerShell method...
    powershell -Command "Test-NetConnection -ComputerName %target% -Port %port%"
)
echo.
pause
goto menu

:export_results
cls
echo ================================================================================
echo                         EXPORT SCAN RESULTS
echo ================================================================================
echo.
set /p target="Enter target IP or hostname: "
set "export_file=port_scan_%target%_%random%.txt"
echo.
echo Scanning and exporting to %export_file%...
echo ----------------------------------------
echo Port Scan Results > %export_file%
echo Target: %target% >> %export_file%
echo Date: %date% %time% >> %export_file%
echo ======================================== >> %export_file%
echo. >> %export_file%
set "ports=21 22 23 25 53 80 110 135 139 143 443 445 1433 3306 3389 8080"
for %%p in (%ports%) do (
    powershell -Command "$tcp = New-Object System.Net.Sockets.TcpClient; try { $tcp.Connect('%target%', %%p); 'Port %%p: OPEN' | Out-File -Append %export_file%; $tcp.Close() } catch { 'Port %%p: CLOSED' | Out-File -Append %export_file% }" 2>nul
)
echo.
echo Scan complete. Results saved to %export_file%
echo.
pause
goto menu