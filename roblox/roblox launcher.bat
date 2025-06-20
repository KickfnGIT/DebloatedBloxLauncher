@echo off
setlocal enabledelayedexpansion

:: Define paths dynamically
set "userProfile=%USERPROFILE%"
set "robloxRoot=%LOCALAPPDATA%\Roblox\Versions"
set "robloxBase=%LOCALAPPDATA%\Roblox"
set "updateChecker=%LOCALAPPDATA%\DBL\updatechecker.py"
set "installer=%LOCALAPPDATA%\DBL\RobloxPlayerInstaller.exe"
set "versionFile=%LOCALAPPDATA%\DBL\roblox_version.txt"
set "settingsFile=%LOCALAPPDATA%\DBL\GlobalBasicSettings_13.xml"
set "skyboxFixPath=%LOCALAPPDATA%\DBL\skyboxfix\move.bat"

:: Detect latest texture folder dynamically, skipping "skyboxfix"
set "texturesPath=%LOCALAPPDATA%\DBL"
set "source="

for /d %%i in ("%texturesPath%\*") do (
    if /i not "%%~nxi"=="skyboxfix" (
        set "source=%%i"
    )
)

echo Detected texture folder: %source%

:: Check if Roblox base directory exists; install if missing
if not exist "%robloxBase%" (
    echo Roblox is not installed. Installing now...
    start "" "%installer%"
    echo Waiting for Roblox to start...
    timeout /t 10 >nul

    :: Redetect version folder after installation
    set "latestInstalled="
    for /d %%i in ("%robloxRoot%\version-*") do (
        set "latestInstalled=%%~nxi"
    )
    echo New installed Roblox version: %latestInstalled%
)

:: Run update checker
echo Running update checker...
python "%updateChecker%"

:: Read latest online version from file
set "latestOnline="
for /f "tokens=* delims=" %%A in (%versionFile%) do set "latestOnline=%%A"
echo Latest Roblox online version: %latestOnline%

:: Find the latest installed version folder
set "latestInstalled="
for /d %%i in ("%robloxRoot%\version-*") do (
    set "latestInstalled=%%~nxi"
)
echo Installed Roblox version: %latestInstalled%

:: Compare versions
if "%latestInstalled%"=="%latestOnline%" (
    echo Roblox is up to date.
) else (
    echo New version available. Installing update...
    start "" "%installer%"
    echo Waiting for Roblox to start...
    rmdir /s /q "%localappdata%\Roblox\Versions\version-%latestInstalled%"
    echo deleting %localappdata%\Roblox\Versions\version-%latestInstalled%
    timeout /t 15 >nul

    :: Redetect version folder after update
    set "latestInstalled="
    for /d %%i in ("%robloxRoot%\version-*") do (
        set "latestInstalled=%%~nxi"
    )
    echo Updated Roblox version: %latestInstalled%

    :: Wait for RobloxPlayerBeta.exe to launch
    echo Waiting for Roblox to open...
    :waitLoop
    tasklist | find /i "RobloxPlayerBeta.exe" >nul && goto foundRoblox
    timeout /t 1 >nul
    goto waitLoop

    :foundRoblox
    echo Roblox detected, closing it...
    taskkill /F /IM RobloxPlayerBeta.exe
    timeout /t 3 >nul
)

:: Copy textures dynamically
set "destination=%robloxRoot%\%latestInstalled%\PlatformContent\pc\textures"
echo Copying textures...
xcopy "%source%" "%destination%" /E /I /Y
echo Files copied to: %destination%

:: Run skyboxfix script minimized
echo Running skyboxfix move script...
start /min "" "%skyboxFixPath%"

:: Always copy GlobalBasicSettings_13.xml before launching Roblox
echo Copying GlobalBasicSettings_13.xml...
xcopy "%settingsFile%" "%robloxBase%" /Y
echo Settings file copied successfully.

:: Relaunch Roblox
echo Launching Roblox...
start "" "%robloxRoot%\%latestInstalled%\RobloxPlayerBeta.exe"
echo Launched: %robloxRoot%\%latestInstalled%\RobloxPlayerBeta.exe"

echo please wait 5-6 seconds for roblox to start
timeout /t 8 >nul
exit