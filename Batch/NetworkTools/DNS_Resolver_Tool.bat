@echo off
setlocal EnableDelayedExpansion
title DNS Resolver Tool
color 0D

:menu
cls
echo ================================================================================
echo                          DNS RESOLVER TOOL
echo ================================================================================
echo.
echo   [1] Resolve Domain Name
echo   [2] Reverse DNS Lookup
echo   [3] Query DNS Records
echo   [4] DNS Server Test
echo   [5] Flush DNS Cache
echo   [6] Display DNS Cache
echo   [7] Check DNS Propagation
echo   [8] Exit
echo.
echo ================================================================================
echo.
set /p choice="Select option (1-8): "

if "%choice%"=="1" goto resolve_domain
if "%choice%"=="2" goto reverse_lookup
if "%choice%"=="3" goto query_records
if "%choice%"=="4" goto dns_test
if "%choice%"=="5" goto flush_cache
if "%choice%"=="6" goto display_cache
if "%choice%"=="7" goto check_propagation
if "%choice%"=="8" exit /b 0
goto menu

:resolve_domain
cls
echo ================================================================================
echo                         RESOLVE DOMAIN NAME
echo ================================================================================
echo.
set /p domain="Enter domain name: "
echo.
echo Resolving %domain%...
echo ----------------------------------------
nslookup %domain%
echo.
echo Additional Information:
echo ----------------------------------------
ping -n 1 %domain% | findstr "Pinging Reply"
echo.
pause
goto menu

:reverse_lookup
cls
echo ================================================================================
echo                         REVERSE DNS LOOKUP
echo ================================================================================
echo.
set /p ip="Enter IP address: "
echo.
echo Performing reverse lookup for %ip%...
echo ----------------------------------------
nslookup %ip%
echo.
echo WHOIS Information:
echo ----------------------------------------
for /f "tokens=2" %%a in ('nslookup %ip% 2^>nul ^| findstr "Name:"') do echo Hostname: %%a
echo.
pause
goto menu

:query_records
cls
echo ================================================================================
echo                         QUERY DNS RECORDS
echo ================================================================================
echo.
set /p domain="Enter domain name: "
echo.
echo Select record type:
echo   1 = A (IPv4)
echo   2 = AAAA (IPv6)
echo   3 = MX (Mail)
echo   4 = TXT
echo   5 = NS (Name Server)
echo   6 = CNAME
echo   7 = SOA
echo   8 = ALL
echo.
set /p record_type="Enter choice (1-8): "

if "%record_type%"=="1" set type=A
if "%record_type%"=="2" set type=AAAA
if "%record_type%"=="3" set type=MX
if "%record_type%"=="4" set type=TXT
if "%record_type%"=="5" set type=NS
if "%record_type%"=="6" set type=CNAME
if "%record_type%"=="7" set type=SOA
if "%record_type%"=="8" set type=ANY

echo.
echo Querying %type% records for %domain%...
echo ----------------------------------------
nslookup -type=%type% %domain% 8.8.8.8
echo.
pause
goto menu

:dns_test
cls
echo ================================================================================
echo                          DNS SERVER TEST
echo ================================================================================
echo.
echo Testing DNS servers...
echo ----------------------------------------
echo.
echo Google DNS (8.8.8.8):
nslookup google.com 8.8.8.8 | findstr "Address"
echo.
echo Cloudflare DNS (1.1.1.1):
nslookup google.com 1.1.1.1 | findstr "Address"
echo.
echo OpenDNS (208.67.222.222):
nslookup google.com 208.67.222.222 | findstr "Address"
echo.
echo Your Default DNS:
nslookup google.com | findstr "Address"
echo.
echo Response Time Test:
echo ----------------------------------------
powershell -Command "Measure-Command {nslookup google.com 8.8.8.8} | Select-Object -Property TotalMilliseconds"
echo.
pause
goto menu

:flush_cache
cls
echo ================================================================================
echo                          FLUSH DNS CACHE
echo ================================================================================
echo.
echo Flushing DNS cache...
ipconfig /flushdns
echo.
echo DNS cache has been cleared.
echo.
echo Registering DNS...
ipconfig /registerdns
echo.
pause
goto menu

:display_cache
cls
echo ================================================================================
echo                         DISPLAY DNS CACHE
echo ================================================================================
echo.
echo Current DNS cache entries:
echo ----------------------------------------
ipconfig /displaydns | more
echo.
pause
goto menu

:check_propagation
cls
echo ================================================================================
echo                       CHECK DNS PROPAGATION
echo ================================================================================
echo.
set /p domain="Enter domain name: "
echo.
echo Checking DNS propagation across multiple servers...
echo ----------------------------------------
echo.
set "dns_servers=8.8.8.8 1.1.1.1 208.67.222.222 9.9.9.9 8.8.4.4"
for %%s in (%dns_servers%) do (
    echo DNS Server: %%s
    nslookup %domain% %%s 2>nul | findstr "Address" | findstr /v "#53"
    echo ----------------------------------------
)
echo.
pause
goto menu