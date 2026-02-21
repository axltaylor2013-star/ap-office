@echo off
title Jeremy's AI SMS System
color 0A
echo.
echo ========================================
echo   🚀 STARTING SMS SYSTEM
echo ========================================
echo.
echo Checking Python...
python --version
if errorlevel 1 (
    echo ❌ Python error - please install Python 3.11+
    pause
    exit /b 1
)
echo.
echo Launching SMS monitoring system...
echo.
echo 📱 Phone: (859) 428-7481
echo 📧 Email: jeremy@kermiclemedia.com
echo 🤖 AI: Active and ready
echo.
echo ========================================
echo   KEEP THIS WINDOW OPEN
echo ========================================
echo.
echo The SMS system is now monitoring for messages
echo Press Ctrl+C to stop the system
echo.

python sms_monitor.py

echo.
echo ========================================
echo   SMS SYSTEM STOPPED
echo ========================================
pause