@echo off
setlocal

set APWORLD_DIR=D:\GIT-Home\Archipelago_GemcraftFrostbornWrath\apworld
set APWORLD_NAME=gcfw.apworld
set INSTALL_DIR=C:\Program Files\Archipelago\lib\worlds

echo Building %APWORLD_NAME%...

:: Remove old apworld if it exists
if exist "%APWORLD_DIR%\%APWORLD_NAME%" del /f "%APWORLD_DIR%\%APWORLD_NAME%"

:: Compress and rename using PowerShell
powershell -NoProfile -Command "Compress-Archive -Path '%APWORLD_DIR%\gcfw' -DestinationPath '%APWORLD_DIR%\gcfw.zip' -Force; Rename-Item '%APWORLD_DIR%\gcfw.zip' '%APWORLD_NAME%'"

if not exist "%APWORLD_DIR%\%APWORLD_NAME%" (
    echo ERROR: Build failed - apworld not created.
    pause
    exit /b 1
)

echo Copying to %INSTALL_DIR%...
copy /y "%APWORLD_DIR%\%APWORLD_NAME%" "%INSTALL_DIR%\%APWORLD_NAME%"

if errorlevel 1 (
    echo ERROR: Copy failed. Try running this bat as Administrator.
    pause
    exit /b 1
)

echo Done! %APWORLD_NAME% installed successfully.
pause
