@echo off
setlocal EnableDelayedExpansion

:: Use the modern Windows file picker dialog
set "psScript=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object Windows.Forms.OpenFileDialog; $f.InitialDirectory = [Environment]::GetFolderPath('Desktop'); $f.Title = 'Select your custom sky folder'; $f.Filter = 'Folders|*.*'; $f.CheckFileExists = $false; $f.CheckPathExists = $true; $f.ValidateNames = $false; $f.FileName = 'Select Folder'; $f.TopMost = $true; if($f.ShowDialog() -eq 'OK') { Split-Path $f.FileName }"

for /f "delims=" %%I in ('powershell -NoProfile -WindowStyle Hidden -Command "%psScript%"') do set "selectedFolder=%%I"

if not defined selectedFolder (
    echo No folder was selected.
    pause
    exit /b
)

:: Find the sky folder in the selected directory
set "skyFound="
for /r "%selectedFolder%" %%F in (.) do (
    if "%%~nxF"=="sky" (
        set "skyFolder=%%F"
        set "skyFound=1"
    )
)

if not defined skyFound (
    echo No sky folder found in the selected directory.
    pause
    exit /b
)

:: Find the target texture folder (any folder not named skyboxfix or Change settings Or change textures)
set "targetFound="
for /d %%D in ("%~dp0..\*") do (
    set "dirname=%%~nxD"
    if /i not "!dirname!"=="skyboxfix" if /i not "!dirname!"=="Change settings Or change textures" (
        set "targetFolder=%%~fD\sky"
        set "targetFound=1"
    )
)

if not defined targetFound (
    echo No valid texture folder found.
    pause
    exit /b
)

:: Create sky folder if it doesn't exist
if not exist "!targetFolder!" mkdir "!targetFolder!"

:: Copy sky files
echo Copying sky files...
for %%F in ("!skyFolder!\indoor512*.*" "!skyFolder!\sky512*.*" "!skyFolder!\diffuse.dds") do (
    if exist "%%~F" (
        echo Copying %%~nxF...
        copy /y "%%~F" "!targetFolder!" >nul
    )
)

echo Sky installation complete!
exit