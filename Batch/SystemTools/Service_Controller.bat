@echo off
setlocal EnableDelayedExpansion
title Windows Service Controller
color 09

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
echo                         WINDOWS SERVICE CONTROLLER
echo ================================================================================
echo.
echo   [1] List All Services
echo   [2] Start Service
echo   [3] Stop Service
echo   [4] Restart Service
echo   [5] Check Service Status
echo   [6] Set Service Startup Type
echo   [7] View Service Dependencies
echo   [8] Export Service List
echo   [9] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-9): "

if "%choice%"=="1" goto list_services
if "%choice%"=="2" goto start_service
if "%choice%"=="3" goto stop_service
if "%choice%"=="4" goto restart_service
if "%choice%"=="5" goto check_status
if "%choice%"=="6" goto set_startup
if "%choice%"=="7" goto view_dependencies
if "%choice%"=="8" goto export_services
if "%choice%"=="9" exit /b 0
goto menu

:list_services
cls
echo ================================================================================
echo                           ALL WINDOWS SERVICES
echo ================================================================================
echo.
echo Status    Service Name
echo ----------------------------------------
sc query state= all | findstr "SERVICE_NAME STATE" | more
echo.
pause
goto menu

:start_service
cls
echo ================================================================================
echo                            START SERVICE
echo ================================================================================
echo.
set /p svc_name="Enter service name: "
echo.
echo Starting %svc_name%...
sc start "%svc_name%" 2>nul
if %errorlevel%==0 (
    echo Service %svc_name% started successfully.
) else (
    echo Failed to start %svc_name%. Service may not exist or already running.
)
echo.
pause
goto menu

:stop_service
cls
echo ================================================================================
echo                            STOP SERVICE
echo ================================================================================
echo.
set /p svc_name="Enter service name: "
echo.
echo Stopping %svc_name%...
sc stop "%svc_name%" 2>nul
if %errorlevel%==0 (
    echo Service %svc_name% stopped successfully.
) else (
    echo Failed to stop %svc_name%. Service may not exist or already stopped.
)
echo.
pause
goto menu

:restart_service
cls
echo ================================================================================
echo                          RESTART SERVICE
echo ================================================================================
echo.
set /p svc_name="Enter service name: "
echo.
echo Restarting %svc_name%...
sc stop "%svc_name%" >nul 2>&1
timeout /t 2 /nobreak >nul
sc start "%svc_name%" 2>nul
if %errorlevel%==0 (
    echo Service %svc_name% restarted successfully.
) else (
    echo Failed to restart %svc_name%.
)
echo.
pause
goto menu

:check_status
cls
echo ================================================================================
echo                         SERVICE STATUS CHECK
echo ================================================================================
echo.
set /p svc_name="Enter service name: "
echo.
echo Status of %svc_name%:
echo ----------------------------------------
sc query "%svc_name%" 2>nul | findstr "SERVICE_NAME STATE"
if %errorlevel% neq 0 (
    echo Service %svc_name% not found.
)
echo.
sc qc "%svc_name%" 2>nul | findstr "START_TYPE"
echo.
pause
goto menu

:set_startup
cls
echo ================================================================================
echo                      SET SERVICE STARTUP TYPE
echo ================================================================================
echo.
echo Startup Types:
echo   1 = Automatic
echo   2 = Automatic (Delayed)
echo   3 = Manual
echo   4 = Disabled
echo.
set /p svc_name="Enter service name: "
set /p startup="Enter startup type (1-4): "

if "%startup%"=="1" set type=auto
if "%startup%"=="2" set type=delayed-auto
if "%startup%"=="3" set type=demand
if "%startup%"=="4" set type=disabled

sc config "%svc_name%" start= %type% 2>nul
if %errorlevel%==0 (
    echo Startup type for %svc_name% set to %type%.
) else (
    echo Failed to set startup type.
)
echo.
pause
goto menu

:view_dependencies
cls
echo ================================================================================
echo                        SERVICE DEPENDENCIES
echo ================================================================================
echo.
set /p svc_name="Enter service name: "
echo.
echo Dependencies for %svc_name%:
echo ----------------------------------------
sc qc "%svc_name%" 2>nul | findstr "DEPENDENCIES"
echo.
echo Services that depend on %svc_name%:
echo ----------------------------------------
sc enumdepend "%svc_name%" 2>nul
echo.
pause
goto menu

:export_services
cls
echo ================================================================================
echo                        EXPORT SERVICE LIST
echo ================================================================================
echo.
set "export_file=services_%random%.txt"
echo Exporting to %export_file%...
echo.
echo Windows Services Report > %export_file%
echo Generated: %date% %time% >> %export_file%
echo =============================================== >> %export_file%
echo. >> %export_file%
sc query state= all >> %export_file% 2>nul
echo.
echo Service list exported to %export_file%
echo.
pause
goto menu