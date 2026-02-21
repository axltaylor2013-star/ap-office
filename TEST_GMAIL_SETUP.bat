@echo off
echo ========================================
echo   TESTING GMAIL API SETUP
echo ========================================
echo.
echo Checking Gmail credentials...
python TEST_GMAIL_CONNECTION.py
echo.
echo Installing Gmail API library...
pip install google-api-python-client google-auth-oauthlib google-auth
echo.
echo ✅ Gmail API setup complete!
echo.
pause