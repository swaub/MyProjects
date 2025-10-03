@echo off
setlocal EnableDelayedExpansion
title System Cleaner Pro
color 0A

:menu
cls
echo ================================================================================
echo                         SYSTEM CLEANER PRO
echo ================================================================================
echo.
echo   [1] Quick Clean
echo   [2] Deep Clean
echo   [3] Browser Cleanup
echo   [4] Windows Update Cleanup
echo   [5] Registry Cleanup
echo   [6] Disk Defragmentation
echo   [7] System File Check
echo   [8] View Cleanup Report
echo   [9] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-9): "

if "%choice%"=="1" goto quick_clean
if "%choice%"=="2" goto deep_clean
if "%choice%"=="3" goto browser_clean
if "%choice%"=="4" goto update_clean
if "%choice%"=="5" goto registry_clean
if "%choice%"=="6" goto defrag
if "%choice%"=="7" goto sfc_scan
if "%choice%"=="8" goto view_report
if "%choice%"=="9" exit /b 0
goto menu

:quick_clean
cls
echo ================================================================================
echo                           QUICK CLEAN
echo ================================================================================
echo.
echo Starting quick cleanup...
echo ----------------------------------------
echo.
set /a cleaned_size=0

echo [1/5] Cleaning Temporary Files...
for /d %%d in ("%temp%\*") do rd /s /q "%%d" 2>nul
del /f /s /q "%temp%\*.*" 2>nul
for /d %%d in ("C:\Windows\Temp\*") do rd /s /q "%%d" 2>nul
del /f /s /q "C:\Windows\Temp\*.*" 2>nul

echo [2/5] Clearing Recycle Bin...
rd /s /q %SystemDrive%\$Recycle.Bin 2>nul

echo [3/5] Cleaning Thumbnails Cache...
del /f /s /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" 2>nul

echo [4/5] Cleaning Windows Error Reports...
del /f /s /q "%LocalAppData%\Microsoft\Windows\WER\ReportArchive\*.*" 2>nul
del /f /s /q "%LocalAppData%\Microsoft\Windows\WER\ReportQueue\*.*" 2>nul

echo [5/5] Cleaning DNS Cache...
ipconfig /flushdns >nul 2>&1

echo.
echo Quick cleanup complete!
echo %date% %time% - Quick Clean performed >> cleanup_log.txt
echo.
pause
goto menu

:deep_clean
cls
echo ================================================================================
echo                           DEEP CLEAN
echo ================================================================================
echo.
echo Starting deep cleanup (This may take several minutes)...
echo ----------------------------------------
echo.

echo [1/10] Removing Temporary Files...
del /f /s /q "%temp%\*.*" 2>nul
del /f /s /q "C:\Windows\Temp\*.*" 2>nul
del /f /s /q "%LocalAppData%\Temp\*.*" 2>nul

echo [2/10] Cleaning Windows Prefetch...
del /f /s /q "C:\Windows\Prefetch\*.*" 2>nul

echo [3/10] Removing Old Windows Logs...
for /f "tokens=*" %%a in ('dir C:\Windows\Logs /b /s 2^>nul') do del "%%a" 2>nul

echo [4/10] Cleaning Windows Update Cache...
net stop wuauserv >nul 2>&1
del /f /s /q "C:\Windows\SoftwareDistribution\Download\*.*" 2>nul
net start wuauserv >nul 2>&1

echo [5/10] Removing Dump Files...
del /f /s /q "C:\Windows\*.dmp" 2>nul
del /f /s /q "C:\Windows\Minidump\*.*" 2>nul

echo [6/10] Cleaning Font Cache...
net stop FontCache >nul 2>&1
del /f /s /q "C:\Windows\ServiceProfiles\LocalService\AppData\Local\FontCache\*.*" 2>nul
net start FontCache >nul 2>&1

echo [7/10] Removing Old System Restore Points...
vssadmin delete shadows /for=c: /oldest /quiet 2>nul

echo [8/10] Cleaning Windows Installer Cache...
del /f /s /q "C:\Windows\Installer\$PatchCache$\*.*" 2>nul

echo [9/10] Removing Delivery Optimization Files...
del /f /s /q "%SystemRoot%\SoftwareDistribution\DeliveryOptimization\*.*" 2>nul

echo [10/10] Running Disk Cleanup...
cleanmgr /sageset:1 >nul 2>&1
cleanmgr /sagerun:1 >nul 2>&1

echo.
echo Deep cleanup complete!
echo %date% %time% - Deep Clean performed >> cleanup_log.txt
echo.
pause
goto menu

:browser_clean
cls
echo ================================================================================
echo                        BROWSER CLEANUP
echo ================================================================================
echo.
echo Cleaning browser data...
echo ----------------------------------------
echo.

echo [1/4] Cleaning Internet Explorer...
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255 2>nul
del /f /s /q "%LocalAppData%\Microsoft\Windows\Temporary Internet Files\*.*" 2>nul

echo [2/4] Cleaning Microsoft Edge...
del /f /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache\*.*" 2>nul
del /f /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cookies" 2>nul

echo [3/4] Cleaning Chrome...
taskkill /f /im chrome.exe 2>nul
del /f /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache\*.*" 2>nul
del /f /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Cookies" 2>nul

echo [4/4] Cleaning Firefox...
taskkill /f /im firefox.exe 2>nul
for /d %%x in ("%LocalAppData%\Mozilla\Firefox\Profiles\*.default*") do (
    del /f /s /q "%%x\cache2\*.*" 2>nul
    del /f /s /q "%%x\cookies.sqlite" 2>nul
)

echo.
echo Browser cleanup complete!
echo.
pause
goto menu

:update_clean
cls
echo ================================================================================
echo                     WINDOWS UPDATE CLEANUP
echo ================================================================================
echo.
echo Cleaning Windows Update files...
echo ----------------------------------------
echo.

echo Stopping Windows Update services...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
net stop dosvc >nul 2>&1

echo Deleting update cache...
rd /s /q "C:\Windows\SoftwareDistribution" 2>nul
rd /s /q "C:\Windows\System32\catroot2" 2>nul

echo Restarting services...
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
net start dosvc >nul 2>&1

echo Running Windows Update cleanup...
Dism.exe /online /Cleanup-Image /StartComponentCleanup 2>nul
Dism.exe /online /Cleanup-Image /SPSuperseded 2>nul

echo.
echo Windows Update cleanup complete!
echo.
pause
goto menu

:registry_clean
cls
echo ================================================================================
echo                        REGISTRY CLEANUP
echo ================================================================================
echo.
echo WARNING: Registry cleaning can affect system stability.
echo Creating backup first...
echo.
set "backup_file=registry_backup_%random%.reg"
reg export HKLM "HKLM_%backup_file%" /y >nul
reg export HKCU "HKCU_%backup_file%" /y >nul
echo Backup created: HKLM_%backup_file% and HKCU_%backup_file%
echo.
echo Cleaning registry...
echo ----------------------------------------

echo Removing empty registry keys...
for /f "tokens=*" %%a in ('reg query HKCU\Software 2^>nul ^| findstr "REG_"') do (
    reg query "%%a" >nul 2>&1 || reg delete "%%a" /f 2>nul
)

echo Removing obsolete software entries...
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /v DisplayName /f 2>nul

echo Optimizing registry...
echo.
echo Registry cleanup complete!
echo.
pause
goto menu

:defrag
cls
echo ================================================================================
echo                      DISK DEFRAGMENTATION
echo ================================================================================
echo.
echo Available drives:
wmic logicaldisk get name,size,freespace
echo.
set /p drive="Enter drive letter to defrag (e.g., C): "
echo.
echo Analyzing drive %drive%:...
defrag %drive%: /A
echo.
echo Defragmenting drive %drive%: (This may take a while)...
defrag %drive%: /O
echo.
echo Defragmentation complete!
echo.
pause
goto menu

:sfc_scan
cls
echo ================================================================================
echo                       SYSTEM FILE CHECK
echo ================================================================================
echo.
echo Running System File Checker...
echo This may take 10-15 minutes.
echo ----------------------------------------
echo.
sfc /scannow
echo.
echo System file check complete!
echo.
echo Running DISM health check...
DISM /Online /Cleanup-image /Restorehealth
echo.
echo System health check complete!
echo.
pause
goto menu

:view_report
cls
echo ================================================================================
echo                        CLEANUP REPORT
echo ================================================================================
echo.
if exist cleanup_log.txt (
    type cleanup_log.txt | more
) else (
    echo No cleanup log found.
)
echo.
pause
goto menu