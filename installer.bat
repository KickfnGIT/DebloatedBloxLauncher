@echo off
setlocal enabledelayedexpansion

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator Privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Prompt the user about shortcut creation **after admin check**
set /p createShortcut="Do you want to create a shortcut to Debloated Blox Launcher? (yes/no): "

:: Define URLs
set PYTHON_URL=https://www.python.org/ftp/python/3.12.1/python-3.12.1-amd64.exe
set ZIP_URL=https://github.com/KickfnGIT/DebloatedBloxLauncher/archive/refs/heads/main.zip
set INSTALLER=python-installer.exe
set ZIP_FILE=DebloatedBloxLauncher.zip

:: Download Python installer
echo Downloading Python...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%PYTHON_URL%', '%INSTALLER%')"

:: Install Python silently
echo Installing Python...
start /wait %INSTALLER% /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

:: Remove installer after installation
del %INSTALLER%

:: Refresh system PATH
echo Updating system PATH...
set "PYTHON_PATH=%ProgramFiles%\Python312"
setx PATH "%PATH%;%PYTHON_PATH%;%PYTHON_PATH%\Scripts" /M

:: Verify Python installation
echo Verifying Python installation...
python --version || echo Python installation failed.

:: Upgrade pip and install BeautifulSoup
echo Installing BeautifulSoup...
python -m ensurepip
python -m pip install --upgrade pip
python -m pip install beautifulsoup4

:: Download repository ZIP file
echo Downloading repository...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%ZIP_URL%', '%ZIP_FILE%')"

:: Set Documents path
set "DOCS_PATH=%USERPROFILE%\Documents"

:: Remove existing 'roblox' folder if it exists
if exist "%DOCS_PATH%\roblox" (
    echo Removing existing roblox folder...
    rd /s /q "%DOCS_PATH%\roblox"
)

:: Extract only the 'roblox' folder into Documents
echo Extracting files...
powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%DOCS_PATH%' -Force"

:: Move extracted 'roblox' folder directly into Documents
move "%DOCS_PATH%\DebloatedBloxLauncher-main\roblox" "%DOCS_PATH%"

:: Cleanup: Remove ZIP file and extracted repo folder
rd /s /q "%DOCS_PATH%\DebloatedBloxLauncher-main"
del %ZIP_FILE%

echo Installation complete!

:: Create shortcut **only if user said yes**
if /i "%createShortcut%"=="y" goto createShortcut
if /i "%createShortcut%"=="yes" goto createShortcut

echo Shortcut creation skipped.
pause
exit /b

:createShortcut
echo Creating shortcut...

:: Use PowerShell to create the shortcut dynamically
set "targetPath=%USERPROFILE%\Documents\roblox\roblox launcher.bat"
set "shortcutPath=%USERPROFILE%\Desktop\Debloated Blox Launcher.lnk"
set "cmdPath=C:\Windows\System32\cmd.exe"

powershell -command "$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%shortcutPath%'); $Shortcut.TargetPath = '%cmdPath%'; $Shortcut.Arguments = '/c \"%targetPath%\"'; $Shortcut.Save()"

echo Shortcut created successfully on your desktop!
pause
exit /b