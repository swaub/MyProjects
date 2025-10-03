@echo off
setlocal EnableDelayedExpansion
title Advanced Process Manager
color 0A

:menu
cls
echo ================================================================================
echo                            ADVANCED PROCESS MANAGER
echo ================================================================================
echo.
echo   [1] List All Running Processes
echo   [2] Kill Process by Name
echo   [3] Kill Process by PID
echo   [4] Set Process Priority
echo   [5] Find Process Using Port
echo   [6] Export Process List
echo   [7] Monitor CPU Usage
echo   [8] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-8): "

if "%choice%"=="1" goto list_processes
if "%choice%"=="2" goto kill_by_name
if "%choice%"=="3" goto kill_by_pid
if "%choice%"=="4" goto set_priority
if "%choice%"=="5" goto find_port
if "%choice%"=="6" goto export_list
if "%choice%"=="7" goto monitor_cpu
if "%choice%"=="8" exit /b 0
goto menu

:list_processes
cls
echo ================================================================================
echo                           ALL RUNNING PROCESSES
echo ================================================================================
echo.
echo PID         Memory         Process Name
echo ----------------------------------------
tasklist /fo table | findstr /v "Image" | more
echo.
pause
goto menu

:kill_by_name
cls
echo ================================================================================
echo                          KILL PROCESS BY NAME
echo ================================================================================
echo.
set /p proc_name="Enter process name (e.g., notepad.exe): "
echo.
taskkill /IM %proc_name% /F 2>nul
if %errorlevel%==0 (
    echo Process %proc_name% terminated successfully.
) else (
    echo Failed to terminate %proc_name%. Process may not exist or access denied.
)
echo.
pause
goto menu

:kill_by_pid
cls
echo ================================================================================
echo                           KILL PROCESS BY PID
echo ================================================================================
echo.
set /p pid="Enter Process ID: "
echo.
taskkill /PID %pid% /F 2>nul
if %errorlevel%==0 (
    echo Process with PID %pid% terminated successfully.
) else (
    echo Failed to terminate PID %pid%. Invalid PID or access denied.
)
echo.
pause
goto menu

:set_priority
cls
echo ================================================================================
echo                          SET PROCESS PRIORITY
echo ================================================================================
echo.
echo Priority Levels:
echo   1 = Realtime
echo   2 = High
echo   3 = Above Normal
echo   4 = Normal
echo   5 = Below Normal
echo   6 = Low
echo.
set /p proc_name="Enter process name: "
set /p priority="Enter priority level (1-6): "

if "%priority%"=="1" set prio_level=realtime
if "%priority%"=="2" set prio_level=high
if "%priority%"=="3" set prio_level=abovenormal
if "%priority%"=="4" set prio_level=normal
if "%priority%"=="5" set prio_level=belownormal
if "%priority%"=="6" set prio_level=low

wmic process where name="%proc_name%" CALL setpriority "%prio_level%" >nul 2>&1
if %errorlevel%==0 (
    echo Priority for %proc_name% set to %prio_level%.
) else (
    echo Failed to set priority. Process may not exist.
)
echo.
pause
goto menu

:find_port
cls
echo ================================================================================
echo                       FIND PROCESS USING PORT
echo ================================================================================
echo.
set /p port="Enter port number: "
echo.
echo Processes using port %port%:
echo ----------------------------------------
netstat -ano | findstr ":%port% "
echo.
pause
goto menu

:export_list
cls
echo ================================================================================
echo                         EXPORT PROCESS LIST
echo ================================================================================
echo.
set "export_file=process_list_%random%.csv"
echo Exporting to %export_file%...
echo.
wmic process get Name,ProcessId,WorkingSetSize,PageFileUsage,CommandLine /format:csv > %export_file% 2>nul
echo Process list exported to %export_file%
echo.
pause
goto menu

:monitor_cpu
cls
echo ================================================================================
echo                         CPU USAGE MONITOR
echo ================================================================================
echo.
echo Monitoring CPU usage (Press Ctrl+C to stop)...
echo ----------------------------------------
:cpu_loop
cls
echo CPU Usage at %time%:
echo.
wmic cpu get loadpercentage /value | findstr "="
echo.
echo Top 5 CPU Consuming Processes:
echo ----------------------------------------
powershell "Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | Format-Table Name, CPU, WorkingSet -AutoSize"
timeout /t 2 /nobreak >nul
goto cpu_loop

pause
goto menu