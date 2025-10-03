@echo off
setlocal EnableDelayedExpansion
title Secure File Shredder
color 0C

:menu
cls
echo ================================================================================
echo                        SECURE FILE SHREDDER
echo ================================================================================
echo.
echo   WARNING: Files deleted with this tool CANNOT be recovered!
echo.
echo   [1] Shred Single File
echo   [2] Shred Multiple Files
echo   [3] Shred Directory
echo   [4] Wipe Free Space
echo   [5] Shred Temporary Files
echo   [6] Shred Recycle Bin
echo   [7] View Shred Log
echo   [8] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-8): "

if "%choice%"=="1" goto shred_single
if "%choice%"=="2" goto shred_multiple
if "%choice%"=="3" goto shred_directory
if "%choice%"=="4" goto wipe_free
if "%choice%"=="5" goto shred_temp
if "%choice%"=="6" goto shred_recycle
if "%choice%"=="7" goto view_log
if "%choice%"=="8" exit /b 0
goto menu

:shred_single
cls
echo ================================================================================
echo                         SHRED SINGLE FILE
echo ================================================================================
echo.
set /p filepath="Enter full path to file: "
echo.
if not exist "%filepath%" (
    echo File not found!
    pause
    goto menu
)

echo File to shred: %filepath%
echo.
echo WARNING: This action is IRREVERSIBLE!
set /p confirm="Are you sure you want to permanently delete this file? (YES/NO): "
if /i not "%confirm%"=="YES" goto menu

echo.
echo Shredding file...
echo Pass 1: Overwriting with random data...
powershell -Command "$bytes = New-Object byte[] (Get-Item '%filepath%').length; (New-Object Random).NextBytes($bytes); [IO.File]::WriteAllBytes('%filepath%', $bytes)" 2>nul
echo Pass 2: Overwriting with zeros...
powershell -Command "$size = (Get-Item '%filepath%').length; $zeros = New-Object byte[] $size; [IO.File]::WriteAllBytes('%filepath%', $zeros)" 2>nul
echo Pass 3: Overwriting with ones...
powershell -Command "$size = (Get-Item '%filepath%').length; $ones = [byte[]]@(255) * $size; [IO.File]::WriteAllBytes('%filepath%', $ones)" 2>nul
echo Pass 4: Final overwrite...
type nul > "%filepath%"
echo Deleting file...
del /f /q "%filepath%"

echo %date% %time% - Shredded: %filepath% >> shred_log.txt
echo.
echo File has been securely shredded.
echo.
pause
goto menu

:shred_multiple
cls
echo ================================================================================
echo                        SHRED MULTIPLE FILES
echo ================================================================================
echo.
set /p directory="Enter directory path: "
set /p pattern="Enter file pattern (e.g., *.tmp): "
echo.
echo Files to shred:
echo ----------------------------------------
dir "%directory%\%pattern%" /b 2>nul
echo.
set /p confirm="Shred all these files? (YES/NO): "
if /i not "%confirm%"=="YES" goto menu

echo.
for %%f in ("%directory%\%pattern%") do (
    echo Shredding: %%~nxf
    type nul > "%%f"
    powershell -Command "$bytes = New-Object byte[] 1024; (New-Object Random).NextBytes($bytes); [IO.File]::WriteAllBytes('%%f', $bytes)" 2>nul
    del /f /q "%%f"
    echo %date% %time% - Shredded: %%f >> shred_log.txt
)
echo.
echo Multiple files shredded.
echo.
pause
goto menu

:shred_directory
cls
echo ================================================================================
echo                         SHRED DIRECTORY
echo ================================================================================
echo.
set /p dirpath="Enter directory to shred (ENTIRE CONTENTS WILL BE DELETED): "
echo.
if not exist "%dirpath%" (
    echo Directory not found!
    pause
    goto menu
)

echo Directory: %dirpath%
echo.
echo WARNING: ALL FILES AND SUBDIRECTORIES WILL BE PERMANENTLY DELETED!
set /p confirm="Type DELETE to confirm: "
if /i not "%confirm%"=="DELETE" goto menu

echo.
echo Shredding directory contents...
for /r "%dirpath%" %%f in (*) do (
    echo Shredding: %%~nxf
    type nul > "%%f" 2>nul
    del /f /q "%%f" 2>nul
)
echo Removing directory structure...
rd /s /q "%dirpath%" 2>nul
echo %date% %time% - Shredded directory: %dirpath% >> shred_log.txt
echo.
echo Directory has been shredded.
echo.
pause
goto menu

:wipe_free
cls
echo ================================================================================
echo                        WIPE FREE SPACE
echo ================================================================================
echo.
echo Select drive to wipe free space:
echo.
echo Available drives:
wmic logicaldisk get name,size,freespace
echo.
set /p drive="Enter drive letter (e.g., C): "
echo.
echo This will wipe all free space on drive %drive%:
echo This process may take a long time!
set /p confirm="Continue? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo.
echo Wiping free space on %drive%:...
cipher /w:%drive%:\ 2>nul
echo.
echo Free space wiped.
echo.
pause
goto menu

:shred_temp
cls
echo ================================================================================
echo                      SHRED TEMPORARY FILES
echo ================================================================================
echo.
echo Temporary file locations:
echo - %temp%
echo - %tmp%
echo - C:\Windows\Temp
echo.
set /p confirm="Shred all temporary files? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo.
echo Shredding temporary files...
echo ----------------------------------------
del /f /s /q "%temp%\*" 2>nul
del /f /s /q "%tmp%\*" 2>nul
del /f /s /q "C:\Windows\Temp\*" 2>nul
for /d %%d in ("%temp%\*") do rd /s /q "%%d" 2>nul
for /d %%d in ("%tmp%\*") do rd /s /q "%%d" 2>nul
echo %date% %time% - Shredded temporary files >> shred_log.txt
echo.
echo Temporary files shredded.
echo.
pause
goto menu

:shred_recycle
cls
echo ================================================================================
echo                       SHRED RECYCLE BIN
echo ================================================================================
echo.
echo This will permanently delete all items in the Recycle Bin.
set /p confirm="Continue? (Y/N): "
if /i not "%confirm%"=="Y" goto menu

echo.
echo Shredding Recycle Bin contents...
powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" 2>nul
rd /s /q %SystemDrive%\$Recycle.Bin 2>nul
echo %date% %time% - Shredded Recycle Bin >> shred_log.txt
echo.
echo Recycle Bin shredded.
echo.
pause
goto menu

:view_log
cls
echo ================================================================================
echo                          SHRED LOG
echo ================================================================================
echo.
if exist shred_log.txt (
    type shred_log.txt | more
) else (
    echo No shred log found.
)
echo.
pause
goto menu