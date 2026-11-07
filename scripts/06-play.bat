@echo off
chcp 65001 >nul
setlocal EnableExtensions
set "CODE=0"
set "HERE=%~dp0"
call "%HERE%00-server-config.bat"

echo ============================================================
echo   VMaNGOS - запуск клиента
echo ============================================================
echo.

:resolve_client
if not defined CLIENT_DIR goto ask_client
if not exist "%CLIENT_DIR%\wow.exe" goto ask_client
goto client_ready

:ask_client
echo Укажи папку с WoW 1.12.1 ^(в ней должен лежать wow.exe^).
set "CLIENT_DIR="
set /p "CLIENT_DIR=Путь: "
if not defined CLIENT_DIR (
    echo Отменено.
    set "CODE=1"
    goto :finish
)
set "CLIENT_DIR=%CLIENT_DIR:"=%"
if not exist "%CLIENT_DIR%\wow.exe" (
    echo [ОШИБКА] В "%CLIENT_DIR%" нет wow.exe.
    set "CODE=1"
    goto :finish
)
> "%ROOT%\client-dir.txt" echo %CLIENT_DIR%
echo Путь сохранён в client-dir.txt.

:client_ready
> "%CLIENT_DIR%\realmlist.wtf" echo set realmlist %REALM_ADDRESS%
echo realmlist.wtf: set realmlist %REALM_ADDRESS%

call :port_listening %AUTH_PORT%
if "%LISTENING%"=="0" (
    echo.
    echo Сервер не запущен.
    choice /C YN /N /M "Запустить сервер сейчас? [Y/N] "
    if errorlevel 2 (
        set "CODE=1"
        goto :finish
    )
    set "VMANGOS_NO_PAUSE=1"
    call "%HERE%04-start-server.bat"
    set "VMANGOS_NO_PAUSE="
    if errorlevel 1 (
        set "CODE=1"
        goto :finish
    )
)

echo Запускаю клиент...
start "" /D "%CLIENT_DIR%" "%CLIENT_DIR%\wow.exe"
goto :finish

rem ============================================================================
:port_listening
set "LISTENING=0"
netstat -ano | findstr /C:":%~1 " | findstr /C:"LISTENING" >nul 2>&1
if not errorlevel 1 set "LISTENING=1"
exit /b 0

:finish
echo.
if not defined VMANGOS_NO_PAUSE pause
exit /b %CODE%
