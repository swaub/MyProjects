@echo off
setlocal EnableDelayedExpansion
title Batch Rename Tool
color 0A

:menu
cls
echo ================================================================================
echo                          BATCH RENAME TOOL
echo ================================================================================
echo.
echo   [1] Add Prefix
echo   [2] Add Suffix
echo   [3] Replace Text
echo   [4] Sequential Numbering
echo   [5] Change Case
echo   [6] Add Date/Time
echo   [7] Remove Characters
echo   [8] Extension Change
echo   [9] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-9): "

if "%choice%"=="1" goto add_prefix
if "%choice%"=="2" goto add_suffix
if "%choice%"=="3" goto replace_text
if "%choice%"=="4" goto sequential
if "%choice%"=="5" goto change_case
if "%choice%"=="6" goto add_datetime
if "%choice%"=="7" goto remove_chars
if "%choice%"=="8" goto change_ext
if "%choice%"=="9" exit /b 0
goto menu

:add_prefix
cls
echo ================================================================================
echo                            ADD PREFIX
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
set /p prefix="Enter prefix to add: "
set /p pattern="Enter file pattern (e.g., *.txt or * for all): "
echo.
echo Preview of changes:
echo ----------------------------------------
set /a count=0
for %%f in ("%directory%\%pattern%") do (
    if not "%%~nxf"=="Batch_Rename_Tool.bat" (
        echo %%~nxf --^> %prefix%%%~nxf
        set /a count+=1
    )
)
echo.
echo Total files to rename: !count!
echo.
set /p confirm="Proceed with renaming? (Y/N): "
if /i "%confirm%"=="Y" (
    for %%f in ("%directory%\%pattern%") do (
        if not "%%~nxf"=="Batch_Rename_Tool.bat" (
            ren "%%f" "%prefix%%%~nxf"
        )
    )
    echo Renaming complete.
)
echo.
pause
goto menu

:add_suffix
cls
echo ================================================================================
echo                            ADD SUFFIX
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
set /p suffix="Enter suffix to add (before extension): "
set /p pattern="Enter file pattern (e.g., *.txt or * for all): "
echo.
echo Preview of changes:
echo ----------------------------------------
set /a count=0
for %%f in ("%directory%\%pattern%") do (
    if not "%%~nxf"=="Batch_Rename_Tool.bat" (
        echo %%~nxf --^> %%~nf%suffix%%%~xf
        set /a count+=1
    )
)
echo.
echo Total files to rename: !count!
echo.
set /p confirm="Proceed with renaming? (Y/N): "
if /i "%confirm%"=="Y" (
    for %%f in ("%directory%\%pattern%") do (
        if not "%%~nxf"=="Batch_Rename_Tool.bat" (
            ren "%%f" "%%~nf%suffix%%%~xf"
        )
    )
    echo Renaming complete.
)
echo.
pause
goto menu

:replace_text
cls
echo ================================================================================
echo                          REPLACE TEXT
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
set /p find_text="Enter text to find: "
set /p replace_text="Enter replacement text: "
set /p pattern="Enter file pattern (e.g., *.txt or * for all): "
echo.
echo Preview of changes:
echo ----------------------------------------
set /a count=0
for %%f in ("%directory%\%pattern%") do (
    if not "%%~nxf"=="Batch_Rename_Tool.bat" (
        set "oldname=%%~nxf"
        set "newname=!oldname:%find_text%=%replace_text%!"
        if not "!oldname!"=="!newname!" (
            echo !oldname! --^> !newname!
            set /a count+=1
        )
    )
)
echo.
echo Total files to rename: !count!
echo.
set /p confirm="Proceed with renaming? (Y/N): "
if /i "%confirm%"=="Y" (
    for %%f in ("%directory%\%pattern%") do (
        if not "%%~nxf"=="Batch_Rename_Tool.bat" (
            set "oldname=%%~nxf"
            set "newname=!oldname:%find_text%=%replace_text%!"
            if not "!oldname!"=="!newname!" ren "%%f" "!newname!"
        )
    )
    echo Renaming complete.
)
echo.
pause
goto menu

:sequential
cls
echo ================================================================================
echo                       SEQUENTIAL NUMBERING
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
set /p base_name="Enter base name: "
set /p start_num="Enter starting number: "
set /p pattern="Enter file pattern (e.g., *.txt or * for all): "
echo.
echo Preview of changes:
echo ----------------------------------------
set /a counter=%start_num%
for %%f in ("%directory%\%pattern%") do (
    if not "%%~nxf"=="Batch_Rename_Tool.bat" (
        echo %%~nxf --^> %base_name%!counter!%%~xf
        set /a counter+=1
    )
)
echo.
set /p confirm="Proceed with renaming? (Y/N): "
if /i "%confirm%"=="Y" (
    set /a counter=%start_num%
    for %%f in ("%directory%\%pattern%") do (
        if not "%%~nxf"=="Batch_Rename_Tool.bat" (
            ren "%%f" "%base_name%!counter!%%~xf"
            set /a counter+=1
        )
    )
    echo Renaming complete.
)
echo.
pause
goto menu

:change_case
cls
echo ================================================================================
echo                           CHANGE CASE
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
echo.
echo Select case type:
echo   1 = UPPERCASE
echo   2 = lowercase
echo   3 = Title Case
set /p case_type="Enter choice (1-3): "
set /p pattern="Enter file pattern (e.g., *.txt or * for all): "
echo.
echo Changing case...
echo ----------------------------------------
for %%f in ("%directory%\%pattern%") do (
    if not "%%~nxf"=="Batch_Rename_Tool.bat" (
        set "filename=%%~nf"
        set "extension=%%~xf"
        if "%case_type%"=="1" (
            powershell -Command "Rename-Item -Path '%%f' -NewName ('!filename!!extension!'.ToUpper())" 2>nul
        )
        if "%case_type%"=="2" (
            powershell -Command "Rename-Item -Path '%%f' -NewName ('!filename!!extension!'.ToLower())" 2>nul
        )
        if "%case_type%"=="3" (
            powershell -Command "Rename-Item -Path '%%f' -NewName (Get-Culture).TextInfo.ToTitleCase('!filename!!extension!')" 2>nul
        )
        echo Renamed: %%~nxf
    )
)
echo.
echo Case change complete.
echo.
pause
goto menu

:add_datetime
cls
echo ================================================================================
echo                         ADD DATE/TIME
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
echo.
echo Select format:
echo   1 = Add current date (YYYYMMDD)
echo   2 = Add current time (HHMMSS)
echo   3 = Add both date and time
set /p dt_format="Enter choice (1-3): "
set /p pattern="Enter file pattern (e.g., *.txt or * for all): "
echo.
set "date_str=%date:~-4%%date:~3,2%%date:~0,2%"
set "time_str=%time:~0,2%%time:~3,2%%time:~6,2%"
set "time_str=!time_str: =0!"

echo Adding date/time...
echo ----------------------------------------
for %%f in ("%directory%\%pattern%") do (
    if not "%%~nxf"=="Batch_Rename_Tool.bat" (
        if "%dt_format%"=="1" ren "%%f" "%%~nf_!date_str!%%~xf"
        if "%dt_format%"=="2" ren "%%f" "%%~nf_!time_str!%%~xf"
        if "%dt_format%"=="3" ren "%%f" "%%~nf_!date_str!_!time_str!%%~xf"
        echo Renamed: %%~nxf
    )
)
echo.
echo Date/time added to filenames.
echo.
pause
goto menu

:remove_chars
cls
echo ================================================================================
echo                        REMOVE CHARACTERS
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
set /p remove="Enter characters to remove: "
set /p pattern="Enter file pattern (e.g., *.txt or * for all): "
echo.
echo Removing characters...
echo ----------------------------------------
for %%f in ("%directory%\%pattern%") do (
    if not "%%~nxf"=="Batch_Rename_Tool.bat" (
        set "oldname=%%~nxf"
        set "newname=!oldname:%remove%=!"
        if not "!oldname!"=="!newname!" (
            ren "%%f" "!newname!"
            echo Renamed: !oldname! --^> !newname!
        )
    )
)
echo.
echo Character removal complete.
echo.
pause
goto menu

:change_ext
cls
echo ================================================================================
echo                        CHANGE EXTENSION
echo ================================================================================
echo.
set /p directory="Enter directory path (or . for current): "
set /p old_ext="Enter current extension (e.g., txt): "
set /p new_ext="Enter new extension (e.g., bak): "
echo.
echo Changing extensions...
echo ----------------------------------------
set /a count=0
for %%f in ("%directory%\*.%old_ext%") do (
    ren "%%f" "%%~nf.%new_ext%"
    echo Renamed: %%~nxf --^> %%~nf.%new_ext%
    set /a count+=1
)
echo.
echo Total files renamed: !count!
echo.
pause
goto menu