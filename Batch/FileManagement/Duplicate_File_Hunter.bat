@echo off
setlocal EnableDelayedExpansion
title Advanced Duplicate File Hunter
color 0E

cls
echo ====================================================================================================
echo                                 ADVANCED DUPLICATE FILE HUNTER
echo                              Professional File Management System
echo ====================================================================================================
echo.

set "scan_path=%cd%"
set /a total_files=0
set /a duplicate_groups=0
set /a space_wasted=0
set "temp_file=%temp%\dup_scan_%random%.tmp"
set "result_file=%temp%\dup_results_%random%.tmp"

:main_menu
cls
echo ====================================================================================================
echo                                      MAIN MENU
echo ====================================================================================================
echo.
echo   Current Scan Path: %scan_path%
echo.
echo   [1] Set Scan Directory
echo   [2] Quick Scan (By Name and Size)
echo   [3] Deep Scan (By Content Hash)
echo   [4] Find Empty Folders
echo   [5] Find Large Files
echo   [6] Find Old Files
echo   [7] Analyze File Types
echo   [8] Exit
echo.
echo ====================================================================================================
set /p choice="Select option (1-8): "

if "%choice%"=="1" goto set_directory
if "%choice%"=="2" goto quick_scan
if "%choice%"=="3" goto deep_scan
if "%choice%"=="4" goto empty_folders
if "%choice%"=="5" goto large_files
if "%choice%"=="6" goto old_files
if "%choice%"=="7" goto analyze_types
if "%choice%"=="8" goto cleanup_exit
goto main_menu

:set_directory
echo.
set /p scan_path="Enter full path to scan: "
if not exist "%scan_path%" (
    echo.
    echo ERROR: Path does not exist!
    pause
    goto main_menu
)
goto main_menu

:quick_scan
cls
echo ====================================================================================================
echo                                    QUICK DUPLICATE SCAN
echo ====================================================================================================
echo.
echo Scanning: %scan_path%
echo Building file database...
echo.

if exist "%temp_file%" del "%temp_file%"
if exist "%result_file%" del "%result_file%"

set /a total_files=0
set /a scanned=0

for /r "%scan_path%" %%f in (*) do (
    set /a total_files+=1
)

echo Total files to scan: !total_files!
echo.
echo Progress:

for /r "%scan_path%" %%f in (*) do (
    set /a scanned+=1
    set /a percent=!scanned!*100/!total_files!
    set "filename=%%~nxf"
    set "filesize=%%~zf"
    set "filepath=%%f"

    if !filesize! GTR 0 (
        echo !filesize!^|!filename!^|!filepath!>>"%temp_file%"
    )

    set /a mod=!scanned!%%50
    if !mod!==0 (
        echo Processed: !scanned!/!total_files! ^(!percent!%%^)
    )
)

echo.
echo Analyzing for duplicates...
echo.

sort "%temp_file%" > "%temp_file%.sorted"

set "last_size="
set "last_name="
set /a dup_count=0
set /a dup_groups=0
set /a total_wasted=0

for /f "tokens=1,2,3 delims=|" %%a in (%temp_file%.sorted) do (
    if "%%a|%%b"=="!last_size!|!last_name!" (
        if !dup_count!==0 (
            set /a dup_groups+=1
            echo. >> "%result_file%"
            echo Duplicate Group #!dup_groups! - File: %%b - Size: %%a bytes >> "%result_file%"
            echo -------------------------------------------- >> "%result_file%"
            echo !last_path! >> "%result_file%"
            set /a total_wasted+=%%a
        )
        echo %%c >> "%result_file%"
        set /a dup_count+=1
        set /a total_wasted+=%%a
    ) else (
        set /a dup_count=0
    )
    set "last_size=%%a"
    set "last_name=%%b"
    set "last_path=%%c"
)

cls
echo ====================================================================================================
echo                                   SCAN RESULTS
echo ====================================================================================================
echo.
echo Total Files Scanned: !total_files!
echo Duplicate Groups Found: !dup_groups!
echo Space Wasted: !total_wasted! bytes
echo.

if !dup_groups! GTR 0 (
    echo Duplicate Details:
    echo ----------------------------------------------------------------------------------------------------
    type "%result_file%" 2>nul | more
)

del "%temp_file%" 2>nul
del "%temp_file%.sorted" 2>nul
del "%result_file%" 2>nul

echo.
pause
goto main_menu

:deep_scan
cls
echo ====================================================================================================
echo                                    DEEP CONTENT SCAN
echo ====================================================================================================
echo.
echo WARNING: This performs byte-by-byte comparison and may take significant time!
echo.
echo Scanning: %scan_path%
echo.

set /a count=0
if exist "%temp%\hash_list.tmp" del "%temp%\hash_list.tmp"

for /r "%scan_path%" %%f in (*) do (
    set /a count+=1
    echo Processing file !count!: %%~nxf

    for /f "skip=1 tokens=*" %%h in ('certutil -hashfile "%%f" MD5 2^>nul ^| findstr /v ":"') do (
        echo %%h^|%%~zf^|%%f >> "%temp%\hash_list.tmp"
        goto :next_file
    )
    :next_file
)

echo.
echo Finding exact duplicates by content...
echo.

sort "%temp%\hash_list.tmp" > "%temp%\hash_sorted.tmp"

set "last_hash="
set /a dup_groups=0

for /f "tokens=1,2,3 delims=|" %%a in (%temp%\hash_sorted.tmp) do (
    if "%%a"=="!last_hash!" (
        if !dup_count!==0 (
            set /a dup_groups+=1
            echo.
            echo Identical Files Group #!dup_groups! ^(Hash: %%a^)
            echo Size: %%b bytes
            echo ----------------------------------------------------------------------------------------------------
            echo !last_file!
        )
        echo %%c
        set /a dup_count+=1
    ) else (
        set /a dup_count=0
    )
    set "last_hash=%%a"
    set "last_file=%%c"
)

del "%temp%\hash_list.tmp" 2>nul
del "%temp%\hash_sorted.tmp" 2>nul

echo.
echo ====================================================================================================
echo.
pause
goto main_menu

:empty_folders
cls
echo ====================================================================================================
echo                                   EMPTY FOLDER FINDER
echo ====================================================================================================
echo.
echo Scanning for empty folders in: %scan_path%
echo.

set /a empty_count=0

for /d /r "%scan_path%" %%d in (*) do (
    dir /b "%%d" 2>nul | findstr "^" >nul
    if errorlevel 1 (
        set /a empty_count+=1
        echo [EMPTY] %%d
    )
)

echo.
echo ----------------------------------------------------------------------------------------------------
echo Total Empty Folders Found: !empty_count!
echo ====================================================================================================
echo.
pause
goto main_menu

:large_files
cls
echo ====================================================================================================
echo                                   LARGE FILE FINDER
echo ====================================================================================================
echo.
set /p size_mb="Enter minimum file size in MB (default 100): "
if "%size_mb%"=="" set size_mb=100
set /a size_bytes=!size_mb!*1048576

echo.
echo Finding files larger than !size_mb! MB in: %scan_path%
echo.
echo Size (MB)    File Path
echo ----------------------------------------------------------------------------------------------------

for /r "%scan_path%" %%f in (*) do (
    if %%~zf GTR !size_bytes! (
        set /a size_display=%%~zf/1048576
        set "filepath=%%f"
        set "size_str=!size_display!        "
        echo !size_str:~0,12! !filepath!
    )
)

echo ====================================================================================================
echo.
pause
goto main_menu

:old_files
cls
echo ====================================================================================================
echo                                     OLD FILE FINDER
echo ====================================================================================================
echo.
set /p days="Enter age in days (files older than): "
if "%days%"=="" set days=365

echo.
echo Finding files older than !days! days in: %scan_path%
echo.
echo Date Modified         File Name
echo ----------------------------------------------------------------------------------------------------

forfiles /P "%scan_path%" /S /D -!days! /C "cmd /c echo @fdate @fpath" 2>nul

echo ====================================================================================================
echo.
pause
goto main_menu

:analyze_types
cls
echo ====================================================================================================
echo                                  FILE TYPE ANALYSIS
echo ====================================================================================================
echo.
echo Analyzing file types in: %scan_path%
echo.

if exist "%temp%\ext_count.tmp" del "%temp%\ext_count.tmp"

for /r "%scan_path%" %%f in (*) do (
    set "ext=%%~xf"
    if "!ext!"=="" set "ext=NO_EXTENSION"
    echo !ext! >> "%temp%\ext_count.tmp"
)

echo Extension    Count    Total Size
echo ----------------------------------------------------------------------------------------------------

sort "%temp%\ext_count.tmp" > "%temp%\ext_sorted.tmp"

set "prev_ext="
set /a ext_count=0

for /f %%e in (%temp%\ext_sorted.tmp) do (
    if "%%e"=="!prev_ext!" (
        set /a ext_count+=1
    ) else (
        if defined prev_ext (
            set /a total_size=0
            for /r "%scan_path%" %%f in (*!prev_ext!) do (
                set /a total_size+=%%~zf/1024
            )
            set "count_str=!ext_count!          "
            set "size_str=!total_size! KB          "
            echo !prev_ext!          !count_str:~0,9! !size_str:~0,15!
        )
        set "prev_ext=%%e"
        set /a ext_count=1
    )
)

if defined prev_ext (
    set /a total_size=0
    for /r "%scan_path%" %%f in (*!prev_ext!) do (
        set /a total_size+=%%~zf/1024
    )
    set "count_str=!ext_count!          "
    set "size_str=!total_size! KB          "
    echo !prev_ext!          !count_str:~0,9! !size_str:~0,15!
)

del "%temp%\ext_sorted.tmp" 2>nul

del "%temp%\ext_count.tmp" 2>nul

echo ====================================================================================================
echo.
pause
goto main_menu

:cleanup_exit
if exist "%temp_file%" del "%temp_file%" 2>nul
if exist "%result_file%" del "%result_file%" 2>nul
echo.
echo Thank you for using Duplicate File Hunter!
timeout /t 2 /nobreak >nul
exit /b 0