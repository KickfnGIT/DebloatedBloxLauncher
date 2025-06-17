@echo off
setlocal enabledelayedexpansion

:: === Check for admin privileges ===
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator Privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: === Prompt the user up front ===
set /p createShortcut="Do you want to create a shortcut to Debloated Blox Launcher? (yes/no): "
set /p installDark="Would you like to apply the dark textures preset? (You can switch back anytime) (yes/no): "
set /p customSettings="Would you like to enter custom settings? (yes/no): "

:: === Define URLs and paths ===
set "PYTHON_URL=https://www.python.org/ftp/python/3.12.1/python-3.12.1-amd64.exe"
set "ZIP_URL=https://github.com/KickfnGIT/DebloatedBloxLauncher/archive/refs/heads/main.zip"
set "INSTALLER=python-installer.exe"
set "ZIP_FILE=DebloatedBloxLauncher.zip"
set "LOCALAPPDATA_PATH=%LOCALAPPDATA%"
set "TARGET_TEXTURES=%LOCALAPPDATA_PATH%\DBL\Default textures"
set "TEMP_ZIP=%TEMP%\dark_textures.zip"
set "TEMP_DIR=%TEMP%\dark_textures"

:: === Download and install Python ===
echo Downloading Python...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%PYTHON_URL%', '%INSTALLER%')"

echo Installing Python...
start /wait %INSTALLER% /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
del %INSTALLER%

echo Updating system PATH...
set "PYTHON_PATH=%ProgramFiles%\Python312"
setx PATH "%PATH%;%PYTHON_PATH%;%PYTHON_PATH%\Scripts" /M

echo Verifying Python installation...
python --version || echo Python installation failed.

:: === Install BeautifulSoup ===
echo Installing BeautifulSoup...
python -m ensurepip
python -m pip install --upgrade pip
python -m pip install pyqt5
python -m pip install pyside6


:: === Download and extract launcher repo ===
echo Downloading Debloated Blox Launcher...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%ZIP_URL%', '%ZIP_FILE%')"

if exist "%LOCALAPPDATA_PATH%\DBL" (
    echo Removing existing DBL folder...
    rd /s /q "%LOCALAPPDATA_PATH%\DBL"
)

echo Extracting launcher files...
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%LOCALAPPDATA_PATH%' -Force"
move "%LOCALAPPDATA_PATH%\DebloatedBloxLauncher-main\roblox" "%LOCALAPPDATA_PATH%\DBL" >nul 2>&1
rd /s /q "%LOCALAPPDATA_PATH%\DebloatedBloxLauncher-main"
del %ZIP_FILE%

echo Launcher files installed to %LOCALAPPDATA_PATH%\DBL

:: === Create shortcut if user agreed ===
if /i "%createShortcut%"=="yes" goto createShortcut
if /i "%createShortcut%"=="y" goto createShortcut
echo Shortcut creation skipped.
goto handleTextures

:createShortcut
echo Creating shortcut...
set "targetPath=%LOCALAPPDATA_PATH%\DBL\gui.py"
set "shortcutPath=%USERPROFILE%\Desktop\Debloated Blox Launcher.lnk"
set "cmdPath=%PYTHON_PATH%\pythonw.exe"
set "iconPath=%LOCALAPPDATA_PATH%\DBL\RobloxPlayerInstaller.exe"
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%shortcutPath%'); $s.TargetPath = '%cmdPath%'; $s.Arguments = '"%targetPath%"'; $s.IconLocation = '%iconPath%'; $s.Save()"
echo Shortcut created successfully.

:handleTextures
if /i "%installDark%"=="yes" goto installDarkTextures
if /i "%installDark%"=="y" goto installDarkTextures
goto checkCustomSettings

:installDarkTextures
echo Downloading dark textures preset...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%ZIP_URL%', '%TEMP_ZIP%')"

echo Extracting dark textures...
powershell -Command "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%TEMP_DIR%' -Force"

if exist "%TARGET_TEXTURES%" (
    echo Removing existing default textures...
    rd /s /q "%TARGET_TEXTURES%"
)

echo Installing dark textures...
move "%TEMP_DIR%\DebloatedBloxLauncher-main\dark textures roblox" "%TARGET_TEXTURES%" >nul 2>&1

del "%TEMP_ZIP%"
rd /s /q "%TEMP_DIR%"

echo Dark textures installed successfully.
goto checkCustomSettings

:checkCustomSettings
if /i "%customSettings%"=="yes" goto runCustomSettings
if /i "%customSettings%"=="y" goto runCustomSettings
goto cleanup

:runCustomSettings
echo Launching custom settings script...
powershell -ExecutionPolicy Bypass -File "%LOCALAPPDATA_PATH%\DBL\Change settings Or change textures\misc\Change settings.ps1"
goto cleanup

:cleanup
set "oldShortcut=%USERPROFILE%\Desktop\Roblox Player.lnk"
if exist "%oldShortcut%" (
    echo Removing old shortcut...
    del "%oldShortcut%"
)

pause
del "%~f0"
exit /b