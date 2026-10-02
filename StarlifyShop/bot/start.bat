@echo off
title StarlifyShopBot
color 0B
cd /d "%~dp0"

cls
echo.
echo  =======================================================
echo.
echo            S T A R L I F Y   S H O P
echo.
echo            Bot + Web Launcher
echo.
echo  =======================================================
echo.

echo  [1/3] Starting local web server for site folder...
start "StarlifyShop Web Server" /min cmd /c "cd /d %~dp0..\webapp && python -m http.server 8000"

timeout /t 2 > nul

echo  [2/3] Opening site in browser - http://localhost:8000
start http://localhost:8000

echo  [3/3] Starting Telegram bot...
echo.
echo  =======================================================
echo.

:loop
python main.py

echo.
echo  =======================================================
echo    Bot stopped, exit code: %errorlevel%
echo    Restarting in 5 seconds... close this window to stop
echo  =======================================================
echo.
timeout /t 5 > nul
goto loop
