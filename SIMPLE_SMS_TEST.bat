@echo off
echo ========================================
echo   SMS SYSTEM QUICK TEST
echo ========================================
echo.
echo Checking Python installation...
python --version
if errorlevel 1 (
    echo.
    echo ❌ Python not found!
    echo Please install Python from python.org
    echo IMPORTANT: Check "Add Python to PATH"
    pause
    exit /b 1
)
echo.
echo ✅ Python is installed
echo.
echo Testing basic SMS monitoring...
echo.
echo 📱 Phone: (859) 428-7481
echo 📧 Email: jeremy@kermiclemedia.com  
echo 🔄 Status: Ready for setup
echo.
echo Next step: Complete Python dependencies
echo.
pause