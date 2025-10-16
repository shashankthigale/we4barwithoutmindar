@echo off
REM WebAR Image Tracking - Quick Start Script (Windows)
REM This script helps set up and run the WebAR application

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════╗
echo ║   WebAR Image Tracking - Quick Start   ║
echo ║           Windows Edition              ║
echo ╔════════════════════════════════════════╗
echo.

REM Check if required files exist
echo Checking required files...

if not exist "index.html" (
    echo [ERROR] index.html not found!
    pause
    exit /b 1
)
echo [OK] index.html found

set MISSING_ASSETS=0

if not exist "poster.png" (
    echo [WARNING] poster.png not found
    echo   You need to provide a target image as 'poster.png'
    set MISSING_ASSETS=1
) else (
    echo [OK] poster.png found
)

if not exist "overlay.mp4" (
    echo [WARNING] overlay.mp4 not found
    echo   You need to provide an overlay video as 'overlay.mp4'
    set MISSING_ASSETS=1
) else (
    echo [OK] overlay.mp4 found
)

echo.

REM Check if assets are missing
if !MISSING_ASSETS!==1 (
    goto :manual_setup
)

goto :start_server

:manual_setup
echo.
echo [ERROR] Required assets are missing!
echo.
echo Please provide:
echo   - poster.png (target image for tracking)
echo   - overlay.mp4 (video to display on target)
echo.
echo Place both files in the project root directory
echo.
pause
exit /b 1

:start_server
echo Starting web server...
echo.

set PORT=8000

REM Check if Python 3 is available
where python >nul 2>nul
if %errorlevel% equ 0 (
    echo Using Python HTTP server
    echo Server running at: http://localhost:!PORT!
    echo.
    echo Desktop Access:
    echo   http://localhost:!PORT!
    echo.
    echo Mobile Access:
    echo   1. Find your IP address below
    echo   2. Visit http://YOUR_IP:!PORT! on your mobile device
    echo.
    
    REM Get local IP address
    for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
        set IP=%%a
        set IP=!IP:~1!
        echo   Your IP: !IP!
        echo   Mobile URL: http://!IP!:!PORT!
        goto :found_ip
    )
    
    :found_ip
    echo.
    echo Next Steps:
    echo   1. Open the URL in Chrome (Android^) or Safari (iOS^)
    echo   2. Grant camera permissions
    echo   3. Print poster.png or display on another screen
    echo   4. Point camera at the image
    echo   5. Watch the AR overlay appear!
    echo.
    echo Press Ctrl+C to stop the server
    echo.
    
    python -m http.server !PORT!
    goto :end
)

REM Check if PHP is available
where php >nul 2>nul
if %errorlevel% equ 0 (
    echo Using PHP built-in server
    echo Server running at: http://localhost:!PORT!
    echo Press Ctrl+C to stop
    echo.
    php -S localhost:!PORT!
    goto :end
)

REM Check if Node.js is available
where node >nul 2>nul
if %errorlevel% equ 0 (
    echo Using Node.js http-server
    echo Server running at: http://localhost:!PORT!
    echo Press Ctrl+C to stop
    echo.
    npx -y http-server -p !PORT!
    goto :end
)

REM No server found
echo [ERROR] No web server found!
echo Please install one of: Python 3, PHP, or Node.js
echo.
echo Quick install options:
echo   - Python 3: https://www.python.org/downloads/
echo   - Node.js: https://nodejs.org/
echo   - PHP: https://windows.php.net/download/
pause
exit /b 1

:end
pause

