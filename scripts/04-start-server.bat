@echo off
chcp 65001 >nul
setlocal EnableExtensions
set "CODE=0"
set "HERE=%~dp0"
call "%HERE%00-server-config.bat"

echo ============================================================
echo   VMaNGOS - запуск сервера
echo ============================================================
echo.

if not exist "%BIN_DIR%\realmd.exe" (
    echo [ОШИБКА] Нет "%BIN_DIR%\realmd.exe". Сначала собери сервер: build.bat в корне проекта
    set "CODE=1"
    goto :finish
)
if not exist "%BIN_DIR%\mangosd.exe" (
    echo [ОШИБКА] Нет "%BIN_DIR%\mangosd.exe". Сначала собери сервер: build.bat в корне проекта
    set "CODE=1"
    goto :finish
)

call :port_listening %MYSQL_PORT%
if "%LISTENING%"=="0" (
    echo [ОШИБКА] MySQL не запущен. Запусти 02-start-mysql.bat.
    set "CODE=1"
    goto :finish
)

rem --- realmd -----------------------------------------------------------------
tasklist /FI "IMAGENAME eq realmd.exe" 2>nul | findstr /I /C:"realmd.exe" >nul
if errorlevel 1 (
    echo Запускаю realmd...
    start "VMaNGOS realmd" /D "%BIN_DIR%" "%BIN_DIR%\realmd.exe"
    call :wait_port %AUTH_PORT% 20
    if "%LISTENING%"=="0" (
        echo [ОШИБКА] realmd не открыл порт %AUTH_PORT%.
        echo Последние строки "%BIN_DIR%\Realmd.log":
        powershell -NoProfile -Command "if (Test-Path '%BIN_DIR%\Realmd.log') { Get-Content -Tail 20 -LiteralPath '%BIN_DIR%\Realmd.log' }"
        set "CODE=1"
        goto :finish
    )
    echo realmd слушает порт %AUTH_PORT%.
) else (
    echo realmd уже запущен.
)

rem --- mangosd ----------------------------------------------------------------
tasklist /FI "IMAGENAME eq mangosd.exe" 2>nul | findstr /I /C:"mangosd.exe" >nul
if not errorlevel 1 (
    echo mangosd уже запущен.
    echo Сервер работает. Играть: 06-play.bat
    goto :finish
)

echo Запускаю mangosd ^(загрузка мира может занять до минуты^)...
start "VMaNGOS mangosd" /D "%BIN_DIR%" "%BIN_DIR%\mangosd.exe"
call :wait_port %WORLD_PORT% 120
if "%LISTENING%"=="1" (
    echo.
    echo ============================================================
    echo   Сервер запущен.
    echo   Аккаунт: 05-create-account.bat
    echo   Играть:  06-play.bat
    echo   Стоп:    07-stop-server.bat
    echo ============================================================
    goto :finish
)

echo.
echo [ОШИБКА] mangosd не открыл порт %WORLD_PORT% за 120 секунд.
echo Последние строки "%BIN_DIR%\Server.log":
powershell -NoProfile -Command "if (Test-Path '%BIN_DIR%\Server.log') { Get-Content -Tail 30 -LiteralPath '%BIN_DIR%\Server.log' }"
echo.
echo Также проверь "%BIN_DIR%\DBErrors.log" и окно "VMaNGOS mangosd".
set "CODE=1"
goto :finish

rem ============================================================================
:port_listening
set "LISTENING=0"
netstat -ano | findstr /C:":%~1 " | findstr /C:"LISTENING" >nul 2>&1
if not errorlevel 1 set "LISTENING=1"
exit /b 0

:wait_port
set /a _tries=%~2
:wait_loop
call :port_listening %~1
if "%LISTENING%"=="1" exit /b 0
set /a _tries-=1
if %_tries% LEQ 0 exit /b 1
ping -n 2 127.0.0.1 >nul
goto wait_loop

:finish
echo.
if not defined VMANGOS_NO_PAUSE pause
exit /b %CODE%
