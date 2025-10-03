@echo off
setlocal EnableDelayedExpansion
title Windows Event Log Analyzer
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
echo                      WINDOWS EVENT LOG ANALYZER
echo ================================================================================
echo.
echo   [1] View System Errors (Last 24 Hours)
echo   [2] View Application Errors
echo   [3] View Security Events
echo   [4] Search Event by ID
echo   [5] Export Event Logs
echo   [6] Clear Event Logs
echo   [7] Monitor Real-time Events
echo   [8] View Critical Events
echo   [9] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-9): "

if "%choice%"=="1" goto system_errors
if "%choice%"=="2" goto app_errors
if "%choice%"=="3" goto security_events
if "%choice%"=="4" goto search_event
if "%choice%"=="5" goto export_logs
if "%choice%"=="6" goto clear_logs
if "%choice%"=="7" goto monitor_events
if "%choice%"=="8" goto critical_events
if "%choice%"=="9" exit /b 0
goto menu

:system_errors
cls
echo ================================================================================
echo                    SYSTEM ERRORS (LAST 24 HOURS)
echo ================================================================================
echo.
wevtutil qe System "/q:*[System[Level=2 and TimeCreated[timediff(@SystemTime) <= 86400000]]]" /f:text /c:10
echo.
pause
goto menu

:app_errors
cls
echo ================================================================================
echo                       APPLICATION ERRORS
echo ================================================================================
echo.
wevtutil qe Application "/q:*[System[Level<=3]]" /f:text /c:10 /rd:true
echo.
pause
goto menu

:security_events
cls
echo ================================================================================
echo                        SECURITY EVENTS
echo ================================================================================
echo.
echo Recent Security Events:
echo ----------------------------------------
wevtutil qe Security /c:20 /f:text /rd:true
echo.
pause
goto menu

:search_event
cls
echo ================================================================================
echo                       SEARCH EVENT BY ID
echo ================================================================================
echo.
set /p event_id="Enter Event ID: "
set /p log_name="Enter Log Name (System/Application/Security): "
echo.
echo Searching for Event ID %event_id% in %log_name% log...
echo ----------------------------------------
wevtutil qe %log_name% "/q:*[System[EventID=%event_id%]]" /f:text /c:5
echo.
pause
goto menu

:export_logs
cls
echo ================================================================================
echo                         EXPORT EVENT LOGS
echo ================================================================================
echo.
set "export_file=eventlog_%random%.evtx"
echo.
echo Select log to export:
echo   1 = System
echo   2 = Application
echo   3 = Security
echo.
set /p log_choice="Enter choice (1-3): "

if "%log_choice%"=="1" set log_name=System
if "%log_choice%"=="2" set log_name=Application
if "%log_choice%"=="3" set log_name=Security

echo Exporting %log_name% log to %export_file%...
wevtutil epl %log_name% %export_file%
if %errorlevel%==0 (
    echo Export successful: %export_file%
) else (
    echo Export failed.
)
echo.
pause
goto menu

:clear_logs
cls
echo ================================================================================
echo                         CLEAR EVENT LOGS
echo ================================================================================
echo.
echo WARNING: This will clear event logs!
echo.
echo Select log to clear:
echo   1 = System
echo   2 = Application
echo   3 = All Logs
echo   4 = Cancel
echo.
set /p clear_choice="Enter choice (1-4): "

if "%clear_choice%"=="4" goto menu
if "%clear_choice%"=="1" wevtutil cl System
if "%clear_choice%"=="2" wevtutil cl Application
if "%clear_choice%"=="3" (
    for /f "tokens=*" %%a in ('wevtutil el') do wevtutil cl "%%a" 2>nul
)
echo.
echo Event logs cleared.
echo.
pause
goto menu

:monitor_events
cls
echo ================================================================================
echo                      REAL-TIME EVENT MONITOR
echo ================================================================================
echo.
echo Monitoring new events (Press Ctrl+C to stop)...
echo ----------------------------------------
:monitor_loop
wevtutil qe System /c:1 /f:text /rd:true
timeout /t 2 /nobreak >nul
goto monitor_loop

:critical_events
cls
echo ================================================================================
echo                        CRITICAL EVENTS
echo ================================================================================
echo.
echo Critical System Events:
echo ----------------------------------------
wevtutil qe System "/q:*[System[Level=1]]" /f:text /c:10
echo.
echo Critical Application Events:
echo ----------------------------------------
wevtutil qe Application "/q:*[System[Level=1]]" /f:text /c:10
echo.
pause
goto menu