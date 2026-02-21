@echo off
echo ========================================
echo   INSTALLING GMAIL API LIBRARIES
echo ========================================
echo.
echo Installing Google API Python client...
echo.

pip install --upgrade pip
echo ✅ Pip updated

pip install google-api-python-client
echo ✅ Google API Python client installed

pip install google-auth
echo ✅ Google Auth installed  

pip install google-auth-oauthlib
echo ✅ Google Auth OAuth installed

pip install google-auth-httplib2
echo ✅ Google Auth HTTP lib installed

echo.
echo ========================================
echo   ✅ GMAIL API LIBRARIES INSTALLED
echo ========================================
echo.
echo Now run: python FIXED_SMS_DEBUG.py
echo.
pause