@echo off
setlocal EnableDelayedExpansion
title File Synchronizer Tool
color 0E

:menu
cls
echo ================================================================================
echo                         FILE SYNCHRONIZER TOOL
echo ================================================================================
echo.
echo   [1] One-Way Sync (Source to Destination)
echo   [2] Two-Way Sync (Mirror Both)
echo   [3] Backup Sync (Keep Versions)
echo   [4] Compare Directories
echo   [5] Schedule Sync Task
echo   [6] Sync with Filters
echo   [7] View Sync Log
echo   [8] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-8): "

if "%choice%"=="1" goto one_way_sync
if "%choice%"=="2" goto two_way_sync
if "%choice%"=="3" goto backup_sync
if "%choice%"=="4" goto compare_dirs
if "%choice%"=="5" goto schedule_sync
if "%choice%"=="6" goto filter_sync
if "%choice%"=="7" goto view_log
if "%choice%"=="8" exit /b 0
goto menu

:one_way_sync
cls
echo ================================================================================
echo                    ONE-WAY SYNC (SOURCE TO DEST)
echo ================================================================================
echo.
set /p source="Enter source directory: "
set /p dest="Enter destination directory: "
echo.
if not exist "%source%" (
    echo Source directory does not exist!
    pause
    goto menu
)
if not exist "%dest%" mkdir "%dest%"

echo Syncing from %source% to %dest%...
echo ----------------------------------------
robocopy "%source%" "%dest%" /E /Z /COPY:DAT /R:3 /W:10 /TEE /LOG+:sync_log.txt
echo.
echo Sync complete. Check sync_log.txt for details.
echo.
pause
goto menu

:two_way_sync
cls
echo ================================================================================
echo                       TWO-WAY SYNC (MIRROR)
echo ================================================================================
echo.
set /p dir1="Enter first directory: "
set /p dir2="Enter second directory: "
echo.
if not exist "%dir1%" mkdir "%dir1%"
if not exist "%dir2%" mkdir "%dir2%"

echo Syncing %dir1% and %dir2%...
echo ----------------------------------------
echo Phase 1: Copying from %dir1% to %dir2%
robocopy "%dir1%" "%dir2%" /E /XO /COPY:DAT /R:2 /W:5
echo.
echo Phase 2: Copying from %dir2% to %dir1%
robocopy "%dir2%" "%dir1%" /E /XO /COPY:DAT /R:2 /W:5
echo.
echo Two-way sync complete.
echo.
pause
goto menu

:backup_sync
cls
echo ================================================================================
echo                      BACKUP SYNC (WITH VERSIONS)
echo ================================================================================
echo.
set /p source="Enter source directory: "
set /p backup="Enter backup directory: "
echo.
if not exist "%source%" (
    echo Source directory does not exist!
    pause
    goto menu
)

set "timestamp=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%"
set "timestamp=!timestamp: =0!"
set "backup_dir=%backup%\backup_!timestamp!"
mkdir "%backup_dir%" 2>nul

echo Creating backup in %backup_dir%...
echo ----------------------------------------
robocopy "%source%" "%backup_dir%" /E /COPY:DAT /R:3 /W:10 /TEE
echo.
echo Backup complete: %backup_dir%
echo.
pause
goto menu

:compare_dirs
cls
echo ================================================================================
echo                        COMPARE DIRECTORIES
echo ================================================================================
echo.
set /p dir1="Enter first directory: "
set /p dir2="Enter second directory: "
echo.
echo Comparing %dir1% and %dir2%...
echo ----------------------------------------
echo.
echo Files only in %dir1%:
echo ----------------------------------------
for %%f in ("%dir1%\*") do (
    if not exist "%dir2%\%%~nxf" echo %%~nxf
)
echo.
echo Files only in %dir2%:
echo ----------------------------------------
for %%f in ("%dir2%\*") do (
    if not exist "%dir1%\%%~nxf" echo %%~nxf
)
echo.
echo Different file sizes:
echo ----------------------------------------
for %%f in ("%dir1%\*") do (
    if exist "%dir2%\%%~nxf" (
        set size1=%%~zf
        for %%g in ("%dir2%\%%~nxf") do (
            set size2=%%~zg
            if not !size1!==!size2! echo %%~nxf: !size1! vs !size2! bytes
        )
    )
)
echo.
pause
goto menu

:schedule_sync
cls
echo ================================================================================
echo                        SCHEDULE SYNC TASK
echo ================================================================================
echo.
set /p task_name="Enter task name: "
set /p source="Enter source directory: "
set /p dest="Enter destination directory: "
echo.
echo Schedule frequency:
echo   1 = Daily
echo   2 = Weekly
echo   3 = Monthly
set /p freq="Enter choice (1-3): "

if "%freq%"=="1" set schedule=/SC DAILY
if "%freq%"=="2" set schedule=/SC WEEKLY
if "%freq%"=="3" set schedule=/SC MONTHLY

set /p sync_time="Enter time (HH:MM format): "

echo Creating scheduled task %task_name%...
schtasks /Create /TN "%task_name%" %schedule% /ST %sync_time% /TR "robocopy \"%source%\" \"%dest%\" /E /Z /COPY:DAT" /F
echo.
echo Task scheduled successfully.
echo.
pause
goto menu

:filter_sync
cls
echo ================================================================================
echo                        SYNC WITH FILTERS
echo ================================================================================
echo.
set /p source="Enter source directory: "
set /p dest="Enter destination directory: "
set /p extension="Enter file extension to sync (e.g., *.txt or * for all): "
set /p exclude="Enter extensions to exclude (e.g., *.tmp *.bak or leave empty): "
echo.
echo Syncing with filters...
echo ----------------------------------------
if "%exclude%"=="" (
    robocopy "%source%" "%dest%" %extension% /E /COPY:DAT /R:2 /W:5
) else (
    robocopy "%source%" "%dest%" %extension% /E /COPY:DAT /XF %exclude% /R:2 /W:5
)
echo.
echo Filtered sync complete.
echo.
pause
goto menu

:view_log
cls
echo ================================================================================
echo                          VIEW SYNC LOG
echo ================================================================================
echo.
if exist sync_log.txt (
    type sync_log.txt | more
) else (
    echo No sync log found.
)
echo.
pause
goto menu