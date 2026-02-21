@echo off
echo ========================================
echo   INSTALLING SMS SYSTEM DEPENDENCIES
echo ========================================
echo.
echo Installing required Python packages...
echo.

pip install --upgrade pip
echo ✅ Pip updated

pip install requests
echo ✅ Requests installed

pip install beautifulsoup4
echo ✅ BeautifulSoup installed

pip install lxml
echo ✅ LXML installed

pip install pyyaml
echo ✅ YAML installed

pip install schedule
echo ✅ Schedule installed

echo.
echo ========================================
echo   ✅ ALL DEPENDENCIES INSTALLED
echo ========================================
echo.
echo SMS system is now ready to run!
echo.
echo Next: Run the main SMS system
echo.
pause