@echo off
setlocal EnableDelayedExpansion
title Directory Analyzer
color 0D

:menu
cls
echo ================================================================================
echo                         DIRECTORY ANALYZER
echo ================================================================================
echo.
echo   [1] Analyze Directory Size
echo   [2] File Type Distribution
echo   [3] Find Largest Files
echo   [4] Find Oldest Files
echo   [5] Directory Tree View
echo   [6] Permission Analysis
echo   [7] Generate Full Report
echo   [8] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-8): "

if "%choice%"=="1" goto analyze_size
if "%choice%"=="2" goto file_distribution
if "%choice%"=="3" goto largest_files
if "%choice%"=="4" goto oldest_files
if "%choice%"=="5" goto tree_view
if "%choice%"=="6" goto permissions
if "%choice%"=="7" goto full_report
if "%choice%"=="8" exit /b 0
goto menu

:analyze_size
cls
echo ================================================================================
echo                       ANALYZE DIRECTORY SIZE
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
echo.
if not exist "%directory%" (
    echo Directory not found!
    pause
    goto menu
)

echo Analyzing %directory%...
echo ----------------------------------------
echo.
set /a total_size=0
set /a file_count=0
set /a dir_count=0

for /r "%directory%" %%f in (*) do (
    set /a total_size+=%%~zf/1024
    set /a file_count+=1
)

for /d /r "%directory%" %%d in (*) do (
    set /a dir_count+=1
)

echo Total Files: !file_count!
echo Total Directories: !dir_count!
echo Total Size: !total_size! KB
set /a total_mb=!total_size!/1024
echo Total Size: !total_mb! MB
set /a total_gb=!total_mb!/1024
if !total_gb! gtr 0 echo Total Size: !total_gb! GB
echo.

echo Subdirectory Sizes:
echo ----------------------------------------
for /d %%d in ("%directory%\*") do (
    set /a subdir_size=0
    for /r "%%d" %%f in (*) do (
        set /a subdir_size+=%%~zf/1024/1024
    )
    echo %%~nxd: !subdir_size! MB
)
echo.
pause
goto menu

:file_distribution
cls
echo ================================================================================
echo                      FILE TYPE DISTRIBUTION
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
echo.
echo Analyzing file types in %directory%...
echo ----------------------------------------
echo.

if exist temp_ext.txt del temp_ext.txt
for /r "%directory%" %%f in (*) do (
    echo %%~xf >> temp_ext.txt
)

echo Extension    Count    Total Size (MB)
echo ----------------------------------------
for /f "tokens=1" %%e in ('type temp_ext.txt ^| sort ^| uniq 2^>nul') do (
    set ext=%%e
    if "!ext!"=="" set ext=NO_EXT
    set /a count=0
    set /a size=0
    for /r "%directory%" %%f in (*!ext!) do (
        set /a count+=1
        set /a size+=%%~zf/1024/1024
    )
    if !count! gtr 0 (
        set "ext_str=!ext!                "
        set "count_str=!count!          "
        echo !ext_str:~0,12! !count_str:~0,8! !size!
    )
)

del temp_ext.txt 2>nul
echo.
pause
goto menu

:largest_files
cls
echo ================================================================================
echo                        FIND LARGEST FILES
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
set /p num_files="Number of files to show (default 10): "
if "%num_files%"=="" set num_files=10
echo.
echo Finding %num_files% largest files in %directory%...
echo ----------------------------------------
echo.
echo Size (MB)    File Name
echo ----------------------------------------

set count=0
for /f "tokens=*" %%a in ('dir "%directory%" /s /b /o-s 2^>nul') do (
    if !count! lss %num_files% (
        if exist "%%a\" (
            rem Skip directories
        ) else (
            set /a size_mb=%%~za/1024/1024
            set "size_str=!size_mb!            "
            echo !size_str:~0,12! %%~nxa
            echo              %%a
            set /a count+=1
        )
    )
)
echo.
pause
goto menu

:oldest_files
cls
echo ================================================================================
echo                        FIND OLDEST FILES
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
set /p num_files="Number of files to show (default 10): "
if "%num_files%"=="" set num_files=10
echo.
echo Finding %num_files% oldest files in %directory%...
echo ----------------------------------------
echo.
echo Date Modified    File Name
echo ----------------------------------------

set count=0
for /f "tokens=*" %%a in ('dir "%directory%" /s /b /o:d 2^>nul') do (
    if !count! lss %num_files% (
        if exist "%%a\" (
            rem Skip directories
        ) else (
            echo %%~ta    %%~nxa
            echo                 %%a
            set /a count+=1
        )
    )
)
echo.
pause
goto menu

:tree_view
cls
echo ================================================================================
echo                        DIRECTORY TREE VIEW
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
echo.
echo Directory structure of %directory%:
echo ----------------------------------------
tree "%directory%" /f
echo.
pause
goto menu

:permissions
cls
echo ================================================================================
echo                       PERMISSION ANALYSIS
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
echo.
echo Analyzing permissions for %directory%...
echo ----------------------------------------
echo.
icacls "%directory%" /t /c 2>nul | more
echo.
echo Summary:
echo ----------------------------------------
echo Current User: %USERNAME%
echo User Domain: %USERDOMAIN%
echo.
icacls "%directory%" | findstr "%USERNAME%"
echo.
pause
goto menu

:full_report
cls
echo ================================================================================
echo                      GENERATING FULL REPORT
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
set "report_file=dir_analysis_%random%.txt"
echo.
echo Generating comprehensive report to %report_file%...
echo.

echo Directory Analysis Report > "%report_file%"
echo Generated: %date% %time% >> "%report_file%"
echo Directory: %directory% >> "%report_file%"
echo ======================================== >> "%report_file%"
echo. >> "%report_file%"

echo SUMMARY >> "%report_file%"
echo -------- >> "%report_file%"
set /a total_size=0
set /a file_count=0
for /r "%directory%" %%f in (*) do (
    set /a total_size+=%%~zf/1024/1024
    set /a file_count+=1
)
echo Total Files: !file_count! >> "%report_file%"
echo Total Size: !total_size! MB >> "%report_file%"
echo. >> "%report_file%"

echo FILE TYPE DISTRIBUTION >> "%report_file%"
echo ---------------------- >> "%report_file%"
for /f "tokens=1" %%e in ('dir "%directory%" /b /s 2^>nul ^| findstr "\." ^| sort') do (
    set ext=%%~xe
    if defined ext echo !ext! >> temp_ext2.txt
)
if exist temp_ext2.txt (
    type temp_ext2.txt | sort | uniq -c 2>nul >> "%report_file%"
    del temp_ext2.txt
)
echo. >> "%report_file%"

echo LARGEST FILES >> "%report_file%"
echo ------------- >> "%report_file%"
dir "%directory%" /s /o-s 2>nul | findstr "File(s)" | head -10 >> "%report_file%" 2>nul
echo. >> "%report_file%"

echo DIRECTORY STRUCTURE >> "%report_file%"
echo ------------------- >> "%report_file%"
tree "%directory%" >> "%report_file%" 2>nul

echo.
echo Report saved to %report_file%
echo.
pause
goto menu