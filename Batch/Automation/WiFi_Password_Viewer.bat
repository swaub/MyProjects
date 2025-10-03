@echo off

setlocal EnableDelayedExpansion
title WiFi Password Viewer - Console Only
color 0A

net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo ===============================================
    echo  ERROR: Administrator privileges required!
    echo ===============================================
    echo.
    echo Please run this script as Administrator.
    echo Right-click and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

cls
echo ===============================================
echo      WiFi PASSWORD VIEWER - Console Only
echo           No files will be created
echo ===============================================
echo.
echo Generated: %date% %time%
echo Computer: %COMPUTERNAME%
echo User: %USERNAME%
echo.
echo ===============================================
echo         SCANNING FOR WIFI NETWORKS...
echo ===============================================
echo.

set /a count=0
set /a found=0

for /f "tokens=2 delims=:" %%a in ('netsh wlan show profiles 2^>nul ^| findstr /i "All User Profile"') do (
    set "profile=%%a"
    set "profile=!profile:~1!"

    set "network_name=!profile!"
    set "password="
    set "auth_type=Unknown"
    set "has_password=0"
    set /a count+=1

    for /f "tokens=2 delims=:" %%b in ('netsh wlan show profile "!profile!" key^=clear 2^>nul ^| findstr /i "Key Content"') do (
        set "password=%%b"
        set "password=!password:~1!"
        set "has_password=1"
    )

    for /f "tokens=2 delims=:" %%b in ('netsh wlan show profile "!profile!" key^=clear 2^>nul ^| findstr /i "Authentication"') do (
        set "auth_type=%%b"
        set "auth_type=!auth_type:~1!"
    )

    if "!has_password!"=="1" (
        if "!password!"=="1" (
            set "display_password=Open - Network - Possibility of other Authentication Method"
        ) else if "!password!"=="Absent" (
            set "display_password=Open - Network - Possibility of other Authentication Method"
        ) else (
            set "display_password=!password!"
            set /a found+=1
        )
    ) else (
        set "display_password=Open - Network - Possibility of other Authentication Method"
    )

    echo -----------------------------------------------
    echo Network Name:   !network_name!
    echo Password:       !display_password!
    echo Authentication: !auth_type!
)

echo.
echo ===============================================
echo                    SUMMARY
echo ===============================================
echo Total Networks Found: !count!
echo Networks with Saved Passwords: !found!
echo ===============================================
echo.
echo NOTE: This information was displayed only in
echo       the console. No files were created.
echo ===============================================
echo.
echo Press any key to exit...
pause >nul
exit /b 0