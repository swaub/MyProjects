@echo off
setlocal EnableDelayedExpansion
title Task Scheduler Manager
color 0B

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
echo                       TASK SCHEDULER MANAGER
echo ================================================================================
echo.
echo   [1] List All Scheduled Tasks
echo   [2] Create New Task
echo   [3] Delete Task
echo   [4] Enable/Disable Task
echo   [5] Run Task Now
echo   [6] View Task Details
echo   [7] Export Tasks
echo   [8] Import Task
echo   [9] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-9): "

if "%choice%"=="1" goto list_tasks
if "%choice%"=="2" goto create_task
if "%choice%"=="3" goto delete_task
if "%choice%"=="4" goto toggle_task
if "%choice%"=="5" goto run_task
if "%choice%"=="6" goto view_details
if "%choice%"=="7" goto export_tasks
if "%choice%"=="8" goto import_task
if "%choice%"=="9" exit /b 0
goto menu

:list_tasks
cls
echo ================================================================================
echo                      ALL SCHEDULED TASKS
echo ================================================================================
echo.
echo Task Name                    Status      Next Run Time
echo ----------------------------------------
schtasks /query /fo table | findstr /v "^$" | more
echo.
pause
goto menu

:create_task
cls
echo ================================================================================
echo                         CREATE NEW TASK
echo ================================================================================
echo.
set /p task_name="Enter task name: "
set /p program="Enter program path: "
echo.
echo Schedule Type:
echo   1 = Once
echo   2 = Daily
echo   3 = Weekly
echo   4 = Monthly
echo   5 = At Startup
echo   6 = At Logon
set /p schedule="Enter choice (1-6): "

if "%schedule%"=="1" (
    set /p run_date="Enter date (MM/DD/YYYY): "
    set /p run_time="Enter time (HH:MM): "
    schtasks /create /tn "%task_name%" /tr "%program%" /sc once /sd !run_date! /st !run_time! /f
)
if "%schedule%"=="2" (
    set /p run_time="Enter time (HH:MM): "
    schtasks /create /tn "%task_name%" /tr "%program%" /sc daily /st !run_time! /f
)
if "%schedule%"=="3" (
    set /p day="Enter day (MON,TUE,WED,THU,FRI,SAT,SUN): "
    set /p run_time="Enter time (HH:MM): "
    schtasks /create /tn "%task_name%" /tr "%program%" /sc weekly /d !day! /st !run_time! /f
)
if "%schedule%"=="4" (
    set /p day="Enter day of month (1-31): "
    set /p run_time="Enter time (HH:MM): "
    schtasks /create /tn "%task_name%" /tr "%program%" /sc monthly /d !day! /st !run_time! /f
)
if "%schedule%"=="5" (
    schtasks /create /tn "%task_name%" /tr "%program%" /sc onstart /f
)
if "%schedule%"=="6" (
    schtasks /create /tn "%task_name%" /tr "%program%" /sc onlogon /f
)

echo.
echo Task created successfully.
echo.
pause
goto menu

:delete_task
cls
echo ================================================================================
echo                          DELETE TASK
echo ================================================================================
echo.
set /p task_name="Enter task name to delete: "
echo.
echo Are you sure you want to delete "%task_name%"?
set /p confirm="Type YES to confirm: "
if /i "%confirm%"=="YES" (
    schtasks /delete /tn "%task_name%" /f
    echo Task deleted.
) else (
    echo Deletion cancelled.
)
echo.
pause
goto menu

:toggle_task
cls
echo ================================================================================
echo                      ENABLE/DISABLE TASK
echo ================================================================================
echo.
set /p task_name="Enter task name: "
echo.
echo Select action:
echo   1 = Enable
echo   2 = Disable
set /p action="Enter choice (1-2): "

if "%action%"=="1" (
    schtasks /change /tn "%task_name%" /enable
    echo Task enabled.
)
if "%action%"=="2" (
    schtasks /change /tn "%task_name%" /disable
    echo Task disabled.
)
echo.
pause
goto menu

:run_task
cls
echo ================================================================================
echo                         RUN TASK NOW
echo ================================================================================
echo.
set /p task_name="Enter task name to run: "
echo.
echo Running task "%task_name%"...
schtasks /run /tn "%task_name%"
echo.
echo Task execution initiated.
echo.
pause
goto menu

:view_details
cls
echo ================================================================================
echo                        VIEW TASK DETAILS
echo ================================================================================
echo.
set /p task_name="Enter task name: "
echo.
schtasks /query /tn "%task_name%" /v /fo list
echo.
pause
goto menu

:export_tasks
cls
echo ================================================================================
echo                         EXPORT TASKS
echo ================================================================================
echo.
set "export_file=tasks_export_%random%.xml"
set /p task_name="Enter task name to export (or ALL for all tasks): "
echo.
if /i "%task_name%"=="ALL" (
    echo Exporting all tasks...
    schtasks /query /xml > "%export_file%"
) else (
    echo Exporting task "%task_name%"...
    schtasks /query /tn "%task_name%" /xml > "%export_file%"
)
echo.
echo Tasks exported to %export_file%
echo.
pause
goto menu

:import_task
cls
echo ================================================================================
echo                         IMPORT TASK
echo ================================================================================
echo.
set /p xml_file="Enter XML file path: "
set /p task_name="Enter name for imported task: "
echo.
if exist "%xml_file%" (
    schtasks /create /tn "%task_name%" /xml "%xml_file%"
    echo Task imported successfully.
) else (
    echo File not found.
)
echo.
pause
goto menu