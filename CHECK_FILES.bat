@echo off
echo ========================================
echo   FILE LOCATION CHECKER
echo ========================================
echo.
echo Current working directory:
cd
echo.
echo Looking for gmail_credentials.json in current folder:
if exist gmail_credentials.json (
    echo ✅ gmail_credentials.json FOUND
    echo File size:
    for %%I in (gmail_credentials.json) do echo %%~zI bytes
) else (
    echo ❌ gmail_credentials.json NOT FOUND in current directory
)
echo.
echo All .json files in current directory:
dir *.json /b 2>nul
if errorlevel 1 echo No .json files found
echo.
echo Full workspace directory listing:
dir /b
echo.
pause