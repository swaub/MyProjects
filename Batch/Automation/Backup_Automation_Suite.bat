@echo off
setlocal EnableDelayedExpansion
title Backup Automation Suite
color 0D

:menu
cls
echo ================================================================================
echo                      BACKUP AUTOMATION SUITE
echo ================================================================================
echo.
echo   [1] Quick Backup (Documents, Desktop, Pictures)
echo   [2] Full System Backup
echo   [3] Custom Backup
echo   [4] Incremental Backup
echo   [5] Restore from Backup
echo   [6] Schedule Automated Backup
echo   [7] Verify Backup Integrity
echo   [8] Backup Settings
echo   [9] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-9): "

if "%choice%"=="1" goto quick_backup
if "%choice%"=="2" goto full_backup
if "%choice%"=="3" goto custom_backup
if "%choice%"=="4" goto incremental_backup
if "%choice%"=="5" goto restore_backup
if "%choice%"=="6" goto schedule_backup
if "%choice%"=="7" goto verify_backup
if "%choice%"=="8" goto backup_settings
if "%choice%"=="9" exit /b 0
goto menu

:quick_backup
cls
echo ================================================================================
echo                           QUICK BACKUP
echo ================================================================================
echo.
set /p backup_path="Enter backup destination path: "
if not exist "%backup_path%" mkdir "%backup_path%"
echo.
set "timestamp=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%"
set "timestamp=!timestamp: =0!"
set "backup_folder=%backup_path%\QuickBackup_!timestamp!"
mkdir "%backup_folder%"

echo Backing up user data to %backup_folder%...
echo ----------------------------------------
echo.
echo [1/4] Backing up Documents...
robocopy "%USERPROFILE%\Documents" "%backup_folder%\Documents" /E /Z /COPY:DAT /R:2 /W:5 /TEE
echo.
echo [2/4] Backing up Desktop...
robocopy "%USERPROFILE%\Desktop" "%backup_folder%\Desktop" /E /Z /COPY:DAT /R:2 /W:5 /TEE
echo.
echo [3/4] Backing up Pictures...
robocopy "%USERPROFILE%\Pictures" "%backup_folder%\Pictures" /E /Z /COPY:DAT /R:2 /W:5 /TEE
echo.
echo [4/4] Backing up Videos...
robocopy "%USERPROFILE%\Videos" "%backup_folder%\Videos" /E /Z /COPY:DAT /R:2 /W:5 /TEE /XF *.tmp

echo.
echo Quick backup complete: %backup_folder%
echo %date% %time% - Quick Backup to %backup_folder% >> backup_log.txt
echo.
pause
goto menu

:full_backup
cls
echo ================================================================================
echo                         FULL SYSTEM BACKUP
echo ================================================================================
echo.
set /p backup_path="Enter backup destination path: "
if not exist "%backup_path%" mkdir "%backup_path%"
echo.
echo This will create a system image backup.
echo WARNING: This requires significant disk space and time!
set /p confirm="Continue? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo.
echo Creating system image...
wbadmin start backup -backupTarget:%backup_path% -include:C: -allCritical -quiet
echo.
echo Full system backup complete!
echo %date% %time% - Full System Backup to %backup_path% >> backup_log.txt
echo.
pause
goto menu

:custom_backup
cls
echo ================================================================================
echo                          CUSTOM BACKUP
echo ================================================================================
echo.
set /p source="Enter source path to backup: "
set /p dest="Enter destination path: "
echo.
if not exist "%source%" (
    echo Source path not found!
    pause
    goto menu
)
if not exist "%dest%" mkdir "%dest%"

echo Select backup options:
echo   1 = Mirror (exact copy)
echo   2 = Archive (keep all versions)
echo   3 = Compress backup
set /p option="Enter choice (1-3): "

set "timestamp=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%"
set "timestamp=!timestamp: =0!"
set "backup_folder=%dest%\CustomBackup_!timestamp!"

if "%option%"=="1" (
    echo Creating mirror backup...
    robocopy "%source%" "%backup_folder%" /MIR /Z /COPY:DAT /R:2 /W:5
)
if "%option%"=="2" (
    echo Creating archive backup...
    robocopy "%source%" "%backup_folder%" /E /Z /COPY:DAT /R:2 /W:5
)
if "%option%"=="3" (
    echo Creating compressed backup...
    powershell -Command "Compress-Archive -Path '%source%' -DestinationPath '%backup_folder%.zip'" 2>nul
)

echo.
echo Custom backup complete!
echo %date% %time% - Custom Backup: %source% to %backup_folder% >> backup_log.txt
echo.
pause
goto menu

:incremental_backup
cls
echo ================================================================================
echo                        INCREMENTAL BACKUP
echo ================================================================================
echo.
set /p source="Enter source path: "
set /p dest="Enter backup destination: "
echo.
if not exist "%source%" (
    echo Source not found!
    pause
    goto menu
)
if not exist "%dest%" mkdir "%dest%"

echo Performing incremental backup (only changed files)...
echo ----------------------------------------
robocopy "%source%" "%dest%" /E /XO /COPY:DAT /R:2 /W:5 /TEE /LOG+:incremental_log.txt
echo.
echo Incremental backup complete!
echo %date% %time% - Incremental Backup: %source% to %dest% >> backup_log.txt
echo.
pause
goto menu

:restore_backup
cls
echo ================================================================================
echo                       RESTORE FROM BACKUP
echo ================================================================================
echo.
set /p backup_location="Enter backup location path: "
echo.
if not exist "%backup_location%" (
    echo Backup location not found!
    pause
    goto menu
)

echo Available backups:
echo ----------------------------------------
dir "%backup_location%" /b /ad
echo.
set /p backup_folder="Enter backup folder name to restore: "
set /p restore_path="Enter restore destination: "
echo.
echo WARNING: This will overwrite existing files!
set /p confirm="Continue with restore? (YES/NO): "
if /i not "%confirm%"=="YES" goto menu

echo.
echo Restoring from backup...
robocopy "%backup_location%\%backup_folder%" "%restore_path%" /E /Z /COPY:DAT /R:2 /W:5
echo.
echo Restore complete!
echo %date% %time% - Restored: %backup_folder% to %restore_path% >> backup_log.txt
echo.
pause
goto menu

:schedule_backup
cls
echo ================================================================================
echo                     SCHEDULE AUTOMATED BACKUP
echo ================================================================================
echo.
set /p task_name="Enter task name: "
set /p source="Enter source path to backup: "
set /p dest="Enter backup destination: "
echo.
echo Schedule frequency:
echo   1 = Daily
echo   2 = Weekly
echo   3 = Monthly
set /p freq="Enter choice (1-3): "
set /p backup_time="Enter time (HH:MM): "

set "backup_cmd=robocopy \"%source%\" \"%dest%\Scheduled_%%date:~-4%%%%date:~3,2%%%%date:~0,2%%\" /E /Z /COPY:DAT /R:2 /W:5"

if "%freq%"=="1" set schedule=/SC DAILY
if "%freq%"=="2" set schedule=/SC WEEKLY
if "%freq%"=="3" set schedule=/SC MONTHLY

schtasks /Create /TN "%task_name%" %schedule% /ST %backup_time% /TR "%backup_cmd%" /F
echo.
echo Backup task scheduled successfully!
echo.
pause
goto menu

:verify_backup
cls
echo ================================================================================
echo                      VERIFY BACKUP INTEGRITY
echo ================================================================================
echo.
set /p backup_path="Enter backup path to verify: "
echo.
if not exist "%backup_path%" (
    echo Backup path not found!
    pause
    goto menu
)

echo Verifying backup integrity...
echo ----------------------------------------
echo.
set /a total_files=0
set /a corrupt_files=0

for /r "%backup_path%" %%f in (*) do (
    set /a total_files+=1
    certutil -hashfile "%%f" MD5 >nul 2>&1
    if !errorlevel! neq 0 (
        echo Corrupt: %%f
        set /a corrupt_files+=1
    )
)

echo.
echo Verification Results:
echo Total Files: !total_files!
echo Corrupt Files: !corrupt_files!
if !corrupt_files!==0 (
    echo Status: Backup is INTACT
) else (
    echo Status: Backup has ERRORS
)
echo.
pause
goto menu

:backup_settings
cls
echo ================================================================================
echo                         BACKUP SETTINGS
echo ================================================================================
echo.
echo Current Settings:
echo ----------------------------------------
echo Backup Log: backup_log.txt
echo.
if exist backup_config.txt (
    type backup_config.txt
) else (
    echo No configuration file found.
    echo.
    echo Creating default configuration...
    echo Default Backup Path=C:\Backups > backup_config.txt
    echo Compression=Disabled >> backup_config.txt
    echo Verification=Enabled >> backup_config.txt
    echo Max Backups=10 >> backup_config.txt
    echo.
    echo Default configuration created.
)
echo.
echo Options:
echo   1 = Edit configuration
echo   2 = View backup log
echo   3 = Clear backup log
echo   4 = Back to menu
echo.
set /p setting="Enter choice (1-4): "

if "%setting%"=="1" notepad backup_config.txt
if "%setting%"=="2" if exist backup_log.txt type backup_log.txt | more
if "%setting%"=="3" del backup_log.txt 2>nul && echo Log cleared.
if "%setting%"=="4" goto menu

pause
goto backup_settings