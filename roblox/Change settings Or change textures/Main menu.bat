@echo off
title DBL Settings Menu
setlocal EnableDelayedExpansion

:: Enable ANSI escape sequences
for /f "tokens=*" %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "ESC=%ESC:~0,1%"

:: Find dark mode state and sky state by checking for indicator files
set "darkmode=OFF"
set "customsky=ON"
for /d %%D in ("%~dp0..\*") do (
    set "dirname=%%~nxD"
    if /i not "!dirname!"=="skyboxfix" if /i not "!dirname!"=="Change settings Or change textures" (
        if exist "%%D\darkon.txt" (
            set "darkmode=ON"
            set "texturePath=%%D"
        )
        if exist "%%D\sky\defaulton.txt" (
            set "customsky=OFF"
            set "texturePath=%%D"
        )
    )
)

:: Menu options
set "options=Change Settings|Dark Textures: [!darkmode!]|Custom Skies: [!customsky!]|Revert All Textures to Default|Exit"
set "actions=change settings.bat|TOGGLE_DARK|TOGGLE_SKY|revert FULLY to default textures.bat|EXIT"
set "numOptions=5"
set "selected=1"

:: Initial draw
call :drawfullmenu

:main_menu
:: Move cursor to menu start and redraw only the menu items
echo %ESC%[5;1H
set i=1
for /f "tokens=1-6 delims=|" %%a in ("!options!") do (
    for %%j in (a b c d e f) do (
        if !i! leq !numOptions! (
            set "opt=%%a"
            if "%%j"=="b" set "opt=%%b"
            if "%%j"=="c" set "opt=%%c"
            if "%%j"=="d" set "opt=%%d"
            if "%%j"=="e" set "opt=%%e"
            if "%%j"=="f" set "opt=%%f"
            if defined opt if not "!opt!"=="" (
                if !i! equ !selected! (
                    echo %ESC%[K   %ESC%[7m!i!. !opt!%ESC%[0m
                ) else (
                    echo %ESC%[K   !i!. !opt!
                )
                set /a i+=1
            )
        )
    )
)

:: Read key
for /f "delims=" %%K in ('powershell -NoLogo -NonInteractive -Command "$k=$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'); if($k.VirtualKeyCode -eq 38){'UP'}elseif($k.VirtualKeyCode -eq 40){'DOWN'}elseif($k.VirtualKeyCode -eq 13){'ENTER'}else{''}" 2^>nul') do set "key=%%K"

if "%key%"=="UP" (
    set /a selected-=1
    if !selected! lss 1 set selected=!numOptions!
    goto main_menu
)
if "%key%"=="DOWN" (
    set /a selected+=1
    if !selected! gtr !numOptions! set selected=1
    goto main_menu
)
if "%key%"=="ENTER" (
    set i=1
    for /f "tokens=1-6 delims=|" %%a in ("%actions%") do (
        for %%j in (a b c d e f) do (
            set "act=%%a"
            if "%%j"=="b" set "act=%%b"
            if "%%j"=="c" set "act=%%c"
            if "%%j"=="d" set "act=%%d"
            if "%%j"=="e" set "act=%%e"
            if "%%j"=="f" set "act=%%f"
            if defined act if not "!act!"=="" (
                if !i! equ !selected! (
                    if "!act!"=="EXIT" (
                        start "" pythonw "%~dp0..\gui.py"
                        timeout /t 1 >nul
                        taskkill /IM cmd.exe /F >nul 2>&1
                        exit /b
                    ) else if "!act!"=="TOGGLE_DARK" (
                        if "!darkmode!"=="OFF" (
                            set "darkmode=ON"
                            for /d %%D in ("%~dp0..\*") do (
                                set "dirname=%%~nxD"
                                if /i not "!dirname!"=="skyboxfix" if /i not "!dirname!"=="Change settings Or change textures" (
                                    echo Dark mode enabled> "%%D\darkon.txt"
                                    set "texturePath=%%D"
                                )
                            )
                            start /wait "" "%~dp0install dark textures.bat"
                        ) else (
                            set "darkmode=OFF"
                            if exist "!texturePath!\darkon.txt" del "!texturePath!\darkon.txt"
                            start /wait "" "%~dp0install white textures.bat"
                        )
                        set "options=Change Settings|Dark Textures: [!darkmode!]|Custom Skies: [!customsky!]|Revert All Textures to Default|Exit"
                    ) else if "!act!"=="TOGGLE_SKY" (
                        if "!customsky!"=="OFF" (
                            set "customsky=ON"
                            if exist "!texturePath!\sky\defaulton.txt" del "!texturePath!\sky\defaulton.txt"
                            start /wait "" "%~dp0install custom sky.bat"
                        ) else (
                            set "customsky=OFF"
                            for /d %%D in ("%~dp0..\*") do (
                                set "dirname=%%~nxD"
                                if /i not "!dirname!"=="skyboxfix" if /i not "!dirname!"=="Change settings Or change textures" (
                                    if not exist "%%D\sky" mkdir "%%D\sky"
                                    echo Default sky enabled> "%%D\sky\defaulton.txt"
                                    set "texturePath=%%D"
                                )
                            )
                            start /wait "" "%~dp0install default sky.bat"
                        )
                        set "options=Change Settings|Dark Textures: [!darkmode!]|Custom Skies: [!customsky!]|Revert All Textures to Default|Exit"
                    ) else (
                        cls
                        start /wait "" "%~dp0!act!"
                    )
                    call :drawfullmenu
                    goto main_menu
                )
                set /a i+=1
            )
        )
    )
)
goto main_menu

:drawfullmenu
cls
echo %ESC%[?25l
echo =====================================
echo            SETTINGS MENU
echo =====================================
echo.
set i=1
for /f "tokens=1-6 delims=|" %%a in ("!options!") do (
    for %%j in (a b c d e f) do (
        if !i! leq !numOptions! (
            set "opt=%%a"
            if "%%j"=="b" set "opt=%%b"
            if "%%j"=="c" set "opt=%%c"
            if "%%j"=="d" set "opt=%%d"
            if "%%j"=="e" set "opt=%%e"
            if "%%j"=="f" set "opt=%%f"
            if defined opt if not "!opt!"=="" (
                if !i! equ !selected! (
                    echo    %ESC%[7m!i!. !opt!%ESC%[0m
                ) else (
                    echo    !i!. !opt!
                )
                set /a i+=1
            )
        )
    )
)
echo.
echo =====================================
echo Use UP/DOWN arrows to navigate, ENTER to select.
exit /b
