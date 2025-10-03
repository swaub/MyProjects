@echo off
setlocal EnableDelayedExpansion
title Hardware Monitor Tool
color 0B

:menu
cls
echo ================================================================================
echo                           HARDWARE MONITOR TOOL
echo ================================================================================
echo.
echo   [1] Display System Information
echo   [2] Monitor CPU Temperature
echo   [3] Check Memory Usage
echo   [4] Display Disk Health
echo   [5] Show Battery Status
echo   [6] List USB Devices
echo   [7] Display Graphics Info
echo   [8] Generate Hardware Report
echo   [9] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-9): "

if "%choice%"=="1" goto system_info
if "%choice%"=="2" goto cpu_temp
if "%choice%"=="3" goto memory_usage
if "%choice%"=="4" goto disk_health
if "%choice%"=="5" goto battery_status
if "%choice%"=="6" goto usb_devices
if "%choice%"=="7" goto graphics_info
if "%choice%"=="8" goto hardware_report
if "%choice%"=="9" exit /b 0
goto menu

:system_info
cls
echo ================================================================================
echo                          SYSTEM INFORMATION
echo ================================================================================
echo.
echo Computer Name: %COMPUTERNAME%
echo.
echo BIOS Information:
echo ----------------------------------------
wmic bios get Manufacturer,Version,ReleaseDate /format:list 2>nul | findstr "="
echo.
echo Motherboard Information:
echo ----------------------------------------
wmic baseboard get Manufacturer,Product,Version /format:list 2>nul | findstr "="
echo.
echo Processor Information:
echo ----------------------------------------
wmic cpu get Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed /format:list 2>nul | findstr "="
echo.
pause
goto menu

:cpu_temp
cls
echo ================================================================================
echo                         CPU TEMPERATURE MONITOR
echo ================================================================================
echo.
echo Monitoring CPU Temperature (Press Ctrl+C to stop)...
echo.
:temp_loop
wmic /namespace:\\root\wmi PATH MSAcpi_ThermalZoneTemperature get CurrentTemperature 2>nul | findstr /r "[0-9]" >nul
if %errorlevel%==0 (
    for /f "skip=1" %%a in ('wmic /namespace:\\root\wmi PATH MSAcpi_ThermalZoneTemperature get CurrentTemperature 2^>nul ^| findstr /r "[0-9]"') do (
        set /a temp_celsius=(%%a-2732)/10
        echo Temperature: !temp_celsius! C at %time%
    )
) else (
    echo Temperature sensors not accessible on this system.
    echo.
    pause
    goto menu
)
timeout /t 3 /nobreak >nul
goto temp_loop

:memory_usage
cls
echo ================================================================================
echo                           MEMORY USAGE DETAILS
echo ================================================================================
echo.
for /f "skip=1" %%a in ('wmic os get TotalVisibleMemorySize') do (
    if not "%%a"=="" (
        set /a total_mb=%%a/1024
        echo Total Memory: !total_mb! MB
    )
)
for /f "skip=1" %%a in ('wmic os get FreePhysicalMemory') do (
    if not "%%a"=="" (
        set /a free_mb=%%a/1024
        echo Free Memory: !free_mb! MB
    )
)
if defined total_mb if defined free_mb (
    set /a used_mb=!total_mb!-!free_mb!
    set /a percent=!used_mb!*100/!total_mb!
    echo Used Memory: !used_mb! MB (!percent!%%)
)
echo.
echo Memory Banks:
echo ----------------------------------------
wmic memorychip get BankLabel,Capacity,Speed,MemoryType /format:table
echo.
pause
goto menu

:disk_health
cls
echo ================================================================================
echo                           DISK HEALTH STATUS
echo ================================================================================
echo.
echo Disk Information:
echo ----------------------------------------
wmic diskdrive get Model,Size,Status,MediaType /format:table
echo.
echo SMART Status:
echo ----------------------------------------
wmic diskdrive get Model,Status /format:list 2>nul | findstr "="
echo.
echo Disk Partitions:
echo ----------------------------------------
wmic partition get Name,Size,Type /format:table
echo.
pause
goto menu

:battery_status
cls
echo ================================================================================
echo                          BATTERY STATUS
echo ================================================================================
echo.
wmic path Win32_Battery get BatteryStatus >nul 2>&1
if %errorlevel% neq 0 (
    echo No battery detected. This is likely a desktop system.
) else (
    for /f "skip=1 tokens=*" %%a in ('wmic path Win32_Battery get EstimatedChargeRemaining 2^>nul') do (
        if not "%%a"=="" echo Battery Level: %%a%%
    )
    echo.
    wmic path Win32_Battery get BatteryStatus,EstimatedRunTime,DesignCapacity /format:list 2>nul | findstr "="
)
echo.
echo Power Plan:
echo ----------------------------------------
powercfg /getactivescheme
echo.
pause
goto menu

:usb_devices
cls
echo ================================================================================
echo                          USB DEVICES LIST
echo ================================================================================
echo.
echo Connected USB Devices:
echo ----------------------------------------
wmic path Win32_USBHub get DeviceID,Description /format:table
echo.
echo USB Controllers:
echo ----------------------------------------
wmic path Win32_USBController get Caption,Status /format:table
echo.
pause
goto menu

:graphics_info
cls
echo ================================================================================
echo                        GRAPHICS INFORMATION
echo ================================================================================
echo.
echo Graphics Adapters:
echo ----------------------------------------
wmic path Win32_VideoController get Caption,VideoModeDescription,DriverVersion /format:list 2>nul | findstr "="
echo.
echo Display Resolution:
echo ----------------------------------------
wmic path Win32_VideoController get CurrentHorizontalResolution,CurrentVerticalResolution,CurrentRefreshRate /format:list 2>nul | findstr "="
echo.
pause
goto menu

:hardware_report
cls
echo ================================================================================
echo                      GENERATING HARDWARE REPORT
echo ================================================================================
echo.
set "report_file=hardware_report_%random%.txt"
echo Generating report to %report_file%...
echo.
echo Hardware Report > %report_file%
echo Generated: %date% %time% >> %report_file%
echo =============================================== >> %report_file%
echo. >> %report_file%
systeminfo >> %report_file% 2>nul
echo. >> %report_file%
echo CPU Information: >> %report_file%
wmic cpu get * /format:list >> %report_file% 2>nul
echo. >> %report_file%
echo Memory Information: >> %report_file%
wmic memorychip get * /format:list >> %report_file% 2>nul
echo. >> %report_file%
echo Disk Information: >> %report_file%
wmic diskdrive get * /format:list >> %report_file% 2>nul
echo.
echo Report saved to %report_file%
echo.
pause
goto menu