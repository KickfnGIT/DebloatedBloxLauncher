@echo off
title DBL Settings Menu
color 0f
cls

:menu
echo =====================================
echo            SETTINGS MENU
echo =====================================
echo.
echo       1. Change Settings
echo       2. Install Dark Textures
echo       3. Install White Textures
echo       4. Install Default Sky
echo       5. Revert All to Default
echo       6. Exit
echo. 
echo =====================================
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" (
    start /wait "" "%~dp0change settings.bat"
    cls
    goto menu
)
if "%choice%"=="2" (
    start /wait "" "%~dp0install dark textures.bat"
    cls
    goto menu
)
if "%choice%"=="3" (
    start /wait "" "%~dp0install white textures.bat"
    cls
    goto menu
)
if "%choice%"=="4" (
    start /wait "" "%~dp0install default sky.bat"
    cls
    goto menu
)
if "%choice%"=="5" (
    start /wait "" "%~dp0revert FULLY to default textures.bat"
    cls
    goto menu
)
if "%choice%"=="6" (
    start "" pythonw "%~dp0..\gui.py"
    timeout /t 1 >nul
    taskkill /IM cmd.exe /F >nul 2>&1
    exit /b
)
