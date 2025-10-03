@echo off
setlocal EnableDelayedExpansion
title System Diagnostics Analyzer
color 0A

net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo ===============================================
    echo  ERROR: Administrator privileges required!
    echo ===============================================
    echo.
    pause
    exit /b 1
)

cls
echo ================================================================================
echo                         SYSTEM DIAGNOSTICS ANALYZER
echo ================================================================================
echo.
echo Analyzing system, please wait...
echo.

echo [1/6] System Information
echo ----------------------------------------
echo Computer Name: %COMPUTERNAME%
echo User Name: %USERNAME%
echo Domain: %USERDOMAIN%
echo Processor: %PROCESSOR_IDENTIFIER%
echo Architecture: %PROCESSOR_ARCHITECTURE%
echo Number of Processors: %NUMBER_OF_PROCESSORS%
echo.

echo [2/6] Operating System
echo ----------------------------------------
ver
echo.
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Boot Time" /C:"System Type" /C:"Total Physical Memory"
echo.

echo [3/6] Disk Information
echo ----------------------------------------
for %%d in (C D E F G) do (
    if exist %%d:\ (
        echo Drive %%d:\
        fsutil volume diskfree %%d:\ 2>nul
        echo.
    )
)

echo [4/6] Network Status
echo ----------------------------------------
ipconfig | findstr "IPv4 Subnet Default"
echo.

echo Testing Internet Connection...
ping -n 1 8.8.8.8 >nul 2>&1
if !errorlevel!==0 (
    echo Internet Status: Connected
) else (
    echo Internet Status: Disconnected or Limited
)
echo.

echo [5/6] Running Services
echo ----------------------------------------
echo Key Services Status:
echo.

sc query WinDefend >nul 2>&1
if !errorlevel!==0 (
    sc query WinDefend | findstr "STATE"
    echo Service: Windows Defender
) else (
    echo Windows Defender: Not Available
)

sc query Spooler | findstr "STATE"
echo Service: Print Spooler

sc query W32Time | findstr "STATE"
echo Service: Windows Time

sc query EventLog | findstr "STATE"
echo Service: Windows Event Log
echo.

echo [6/6] Process Statistics
echo ----------------------------------------
set /a proc_count=0
for /f %%a in ('tasklist /fo csv ^| find /c /v ""') do set /a proc_count=%%a-1
echo Total Running Processes: !proc_count!
echo.

echo Top 10 Memory Usage Processes:
echo ----------------------------------------
set /a counter=0
for /f "tokens=1,5" %%a in ('tasklist ^| findstr "K$" ^| sort /r /+65') do (
    if !counter! LSS 10 (
        set "name=%%a                    "
        echo !name:~0,25! %%b
        set /a counter+=1
    )
)

echo.
echo ================================================================================
echo                           DIAGNOSTICS COMPLETE
echo ================================================================================
echo.
pause
exit /b 0