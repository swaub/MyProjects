@echo off
setlocal EnableDelayedExpansion
title Startup Optimizer
color 0E

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

:menu
cls
echo ================================================================================
echo                         STARTUP OPTIMIZER
echo ================================================================================
echo.
echo   [1] View All Startup Programs
echo   [2] Disable Startup Program
echo   [3] Enable Startup Program
echo   [4] Add Startup Program
echo   [5] Remove Startup Program
echo   [6] Backup Startup Config
echo   [7] Analyze Boot Time
echo   [8] Clean Startup
echo   [9] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-9): "

if "%choice%"=="1" goto view_startup
if "%choice%"=="2" goto disable_startup
if "%choice%"=="3" goto enable_startup
if "%choice%"=="4" goto add_startup
if "%choice%"=="5" goto remove_startup
if "%choice%"=="6" goto backup_config
if "%choice%"=="7" goto analyze_boot
if "%choice%"=="8" goto clean_startup
if "%choice%"=="9" exit /b 0
goto menu

:view_startup
cls
echo ================================================================================
echo                      ALL STARTUP PROGRAMS
echo ================================================================================
echo.
echo Registry Startup (HKLM):
echo ----------------------------------------
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2>nul
echo.
echo Registry Startup (HKCU):
echo ----------------------------------------
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" 2>nul
echo.
echo Startup Folder (All Users):
echo ----------------------------------------
dir "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" /b 2>nul
echo.
echo Startup Folder (Current User):
echo ----------------------------------------
dir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" /b 2>nul
echo.
echo Scheduled Tasks at Startup:
echo ----------------------------------------
schtasks /query | findstr "At startup At logon"
echo.
pause
goto menu

:disable_startup
cls
echo ================================================================================
echo                      DISABLE STARTUP PROGRAM
echo ================================================================================
echo.
echo Select location:
echo   1 = Registry (HKLM)
echo   2 = Registry (HKCU)
echo   3 = Task Scheduler
set /p location="Enter choice (1-3): "
echo.

if "%location%"=="1" (
    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /s
    echo.
    set /p prog_name="Enter program name to disable: "
    reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "backup_hklm_%random%.reg" /y >nul
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "!prog_name!" /f
)
if "%location%"=="2" (
    reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /s
    echo.
    set /p prog_name="Enter program name to disable: "
    reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "backup_hkcu_%random%.reg" /y >nul
    reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "!prog_name!" /f
)
if "%location%"=="3" (
    schtasks /query | findstr "At startup At logon"
    echo.
    set /p task_name="Enter task name to disable: "
    schtasks /change /tn "!task_name!" /disable
)

echo.
echo Program disabled from startup.
echo.
pause
goto menu

:enable_startup
cls
echo ================================================================================
echo                       ENABLE STARTUP PROGRAM
echo ================================================================================
echo.
echo This will re-enable previously disabled startup items.
echo.
set /p task_name="Enter task name to enable: "
schtasks /change /tn "%task_name%" /enable
echo.
echo Task enabled.
echo.
pause
goto menu

:add_startup
cls
echo ================================================================================
echo                       ADD STARTUP PROGRAM
echo ================================================================================
echo.
set /p prog_name="Enter program name: "
set /p prog_path="Enter full program path: "
echo.
echo Select location:
echo   1 = Registry (All Users)
echo   2 = Registry (Current User)
echo   3 = Startup Folder (All Users)
echo   4 = Startup Folder (Current User)
set /p location="Enter choice (1-4): "

if "%location%"=="1" (
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "%prog_name%" /t REG_SZ /d "%prog_path%" /f
)
if "%location%"=="2" (
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "%prog_name%" /t REG_SZ /d "%prog_path%" /f
)
if "%location%"=="3" (
    powershell -Command "New-Item -ItemType SymbolicLink -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\%prog_name%.lnk' -Target '%prog_path%'" 2>nul
)
if "%location%"=="4" (
    powershell -Command "New-Item -ItemType SymbolicLink -Path '%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\%prog_name%.lnk' -Target '%prog_path%'" 2>nul
)

echo.
echo Program added to startup.
echo.
pause
goto menu

:remove_startup
cls
echo ================================================================================
echo                      REMOVE STARTUP PROGRAM
echo ================================================================================
echo.
echo WARNING: This permanently removes startup entries.
echo.
echo Select location:
echo   1 = Registry (HKLM)
echo   2 = Registry (HKCU)
echo   3 = Startup Folder
set /p location="Enter choice (1-3): "
echo.

if "%location%"=="1" (
    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /s
    echo.
    set /p prog_name="Enter program name to remove: "
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "!prog_name!" /f
)
if "%location%"=="2" (
    reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /s
    echo.
    set /p prog_name="Enter program name to remove: "
    reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "!prog_name!" /f
)
if "%location%"=="3" (
    echo All Users Startup:
    dir "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" /b
    echo.
    echo Current User Startup:
    dir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" /b
    echo.
    set /p file_name="Enter filename to remove: "
    del "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\!file_name!" 2>nul
    del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\!file_name!" 2>nul
)

echo.
echo Startup entry removed.
echo.
pause
goto menu

:backup_config
cls
echo ================================================================================
echo                      BACKUP STARTUP CONFIG
echo ================================================================================
echo.
set "backup_file=startup_backup_%random%.reg"
echo Creating backup...
echo.
reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "hklm_%backup_file%" /y
reg export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "hkcu_%backup_file%" /y
echo.
echo Backup created:
echo - hklm_%backup_file%
echo - hkcu_%backup_file%
echo.
pause
goto menu

:analyze_boot
cls
echo ================================================================================
echo                        ANALYZE BOOT TIME
echo ================================================================================
echo.
echo Analyzing system boot performance...
echo ----------------------------------------
echo.
powershell -Command "Get-WinEvent -FilterHashTable @{LogName='Microsoft-Windows-Diagnostics-Performance/Operational'; ID=100} | Select-Object -First 5 | Format-List TimeCreated, Message" 2>nul
echo.
echo Boot Time Analysis:
echo ----------------------------------------
wevtutil qe Microsoft-Windows-Diagnostics-Performance/Operational "/q:*[System[EventID=100]]" /c:1 /f:text 2>nul
echo.
pause
goto menu

:clean_startup
cls
echo ================================================================================
echo                         CLEAN STARTUP
echo ================================================================================
echo.
echo This will disable non-essential startup programs.
echo.
set /p confirm="Are you sure? (YES/NO): "
if /i not "%confirm%"=="YES" goto menu

echo.
echo Creating restore point...
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Before Startup Clean", 100, 7 2>nul

echo Disabling non-essential services...
sc config "Windows Search" start= disabled 2>nul
sc config "Print Spooler" start= disabled 2>nul
sc config "Themes" start= disabled 2>nul

echo.
echo Startup cleaned. Restart to see improvements.
echo.
pause
goto menu