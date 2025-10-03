@echo off
setlocal EnableDelayedExpansion
title Windows Firewall Manager
color 0C

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
echo                       WINDOWS FIREWALL MANAGER
echo ================================================================================
echo.
echo   [1] Check Firewall Status
echo   [2] Enable/Disable Firewall
echo   [3] Add Inbound Rule
echo   [4] Add Outbound Rule
echo   [5] List All Rules
echo   [6] Delete Rule
echo   [7] Block/Unblock Program
echo   [8] Export Firewall Config
echo   [9] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-9): "

if "%choice%"=="1" goto check_status
if "%choice%"=="2" goto toggle_firewall
if "%choice%"=="3" goto add_inbound
if "%choice%"=="4" goto add_outbound
if "%choice%"=="5" goto list_rules
if "%choice%"=="6" goto delete_rule
if "%choice%"=="7" goto block_program
if "%choice%"=="8" goto export_config
if "%choice%"=="9" exit /b 0
goto menu

:check_status
cls
echo ================================================================================
echo                        FIREWALL STATUS
echo ================================================================================
echo.
netsh advfirewall show allprofiles
echo.
pause
goto menu

:toggle_firewall
cls
echo ================================================================================
echo                      ENABLE/DISABLE FIREWALL
echo ================================================================================
echo.
echo Select action:
echo   1 = Enable All Profiles
echo   2 = Disable All Profiles
echo   3 = Enable Domain Profile
echo   4 = Enable Private Profile
echo   5 = Enable Public Profile
echo   6 = Back to Menu
echo.
set /p action="Enter choice (1-6): "

if "%action%"=="1" netsh advfirewall set allprofiles state on
if "%action%"=="2" netsh advfirewall set allprofiles state off
if "%action%"=="3" netsh advfirewall set domainprofile state on
if "%action%"=="4" netsh advfirewall set privateprofile state on
if "%action%"=="5" netsh advfirewall set publicprofile state on
if "%action%"=="6" goto menu

echo.
echo Firewall settings updated.
echo.
pause
goto menu

:add_inbound
cls
echo ================================================================================
echo                         ADD INBOUND RULE
echo ================================================================================
echo.
set /p rule_name="Enter rule name: "
set /p port="Enter port number (or range like 8080-8090): "
echo.
echo Select protocol:
echo   1 = TCP
echo   2 = UDP
echo   3 = Both
set /p proto="Enter choice (1-3): "

if "%proto%"=="1" set protocol=TCP
if "%proto%"=="2" set protocol=UDP
if "%proto%"=="3" set protocol=any

netsh advfirewall firewall add rule name="%rule_name%" dir=in action=allow protocol=%protocol% localport=%port%
echo.
echo Inbound rule "%rule_name%" created.
echo.
pause
goto menu

:add_outbound
cls
echo ================================================================================
echo                         ADD OUTBOUND RULE
echo ================================================================================
echo.
set /p rule_name="Enter rule name: "
set /p port="Enter port number: "
echo.
echo Select protocol:
echo   1 = TCP
echo   2 = UDP
echo   3 = Both
set /p proto="Enter choice (1-3): "

if "%proto%"=="1" set protocol=TCP
if "%proto%"=="2" set protocol=UDP
if "%proto%"=="3" set protocol=any

netsh advfirewall firewall add rule name="%rule_name%" dir=out action=allow protocol=%protocol% localport=%port%
echo.
echo Outbound rule "%rule_name%" created.
echo.
pause
goto menu

:list_rules
cls
echo ================================================================================
echo                         ALL FIREWALL RULES
echo ================================================================================
echo.
echo Select rules to display:
echo   1 = All Rules
echo   2 = Inbound Rules
echo   3 = Outbound Rules
echo   4 = Enabled Rules Only
echo.
set /p list_choice="Enter choice (1-4): "

if "%list_choice%"=="1" netsh advfirewall firewall show rule name=all
if "%list_choice%"=="2" netsh advfirewall firewall show rule name=all dir=in
if "%list_choice%"=="3" netsh advfirewall firewall show rule name=all dir=out
if "%list_choice%"=="4" netsh advfirewall firewall show rule name=all | findstr "Enabled: Yes"

echo.
pause
goto menu

:delete_rule
cls
echo ================================================================================
echo                          DELETE RULE
echo ================================================================================
echo.
set /p rule_name="Enter exact rule name to delete: "
echo.
netsh advfirewall firewall delete rule name="%rule_name%"
echo.
echo Rule deleted (if it existed).
echo.
pause
goto menu

:block_program
cls
echo ================================================================================
echo                       BLOCK/UNBLOCK PROGRAM
echo ================================================================================
echo.
echo Select action:
echo   1 = Block Program
echo   2 = Unblock Program
echo.
set /p block_action="Enter choice (1-2): "

if "%block_action%"=="1" (
    set /p program="Enter full path to program: "
    set /p block_name="Enter rule name: "
    netsh advfirewall firewall add rule name="!block_name!" dir=out action=block program="!program!"
    netsh advfirewall firewall add rule name="!block_name!" dir=in action=block program="!program!"
    echo Program blocked.
) else (
    set /p unblock_name="Enter rule name to remove: "
    netsh advfirewall firewall delete rule name="!unblock_name!"
    echo Program unblocked.
)
echo.
pause
goto menu

:export_config
cls
echo ================================================================================
echo                      EXPORT FIREWALL CONFIG
echo ================================================================================
echo.
set "export_file=firewall_config_%random%.wfw"
echo Exporting to %export_file%...
netsh advfirewall export "%export_file%"
echo.
echo Firewall configuration exported to %export_file%
echo.
echo To import later, use: netsh advfirewall import "%export_file%"
echo.
pause
goto menu