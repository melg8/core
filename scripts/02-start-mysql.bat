@echo off
chcp 65001 >nul
setlocal EnableExtensions
set "CODE=0"
set "HERE=%~dp0"
call "%HERE%00-server-config.bat"

echo ============================================================
echo   VMaNGOS - запуск MySQL
echo ============================================================
echo.

if not exist "%MYSQL%" (
    echo [ОШИБКА] Не найден "%MYSQL%".
    echo Поправь MYSQL_HOME в 00-server-config.bat.
    set "CODE=1"
    goto :finish
)

call :port_listening
if "%LISTENING%"=="1" (
    echo MySQL уже запущен на порту %MYSQL_PORT%.
    goto :finish
)

rem --- try the Windows service first ------------------------------------------
sc query "%MYSQL_SERVICE%" >nul 2>&1
if not errorlevel 1 (
    echo Запускаю службу "%MYSQL_SERVICE%"...
    net start "%MYSQL_SERVICE%" >nul 2>&1
    call :wait_port 20
    if "%LISTENING%"=="1" (
        echo MySQL запущен как служба.
        goto :finish
    )
    echo Служба не запустилась ^(нет прав администратора?^). Пробую обычный запуск...
)

rem --- fallback: standalone process in its own window -------------------------
echo Запускаю MySQL из "%MYSQL_HOME%"...
start "XAMPP MySQL" /min "%MYSQL_BIN%\mysqld.exe" --defaults-file="%MYSQL_HOME%\bin\my.ini" --standalone
call :wait_port 40
if "%LISTENING%"=="1" (
    echo.
    echo MySQL запущен на порту %MYSQL_PORT%.
    echo Окно "XAMPP MySQL" сворачивать или закрывать нельзя - вместе с ним остановится MySQL.
    echo Чтобы MySQL стартовал автоматически после перезагрузки, один раз запусти
    echo 08-install-mysql-service.bat от администратора.
    goto :finish
)

echo.
echo [ОШИБКА] MySQL не открыл порт %MYSQL_PORT%.
echo Посмотри лог: "%MYSQL_HOME%\data\mysql_error.log"
set "CODE=1"
goto :finish

rem ============================================================================
:port_listening
set "LISTENING=0"
netstat -ano | findstr /C:":%MYSQL_PORT% " | findstr /C:"LISTENING" >nul 2>&1
if not errorlevel 1 set "LISTENING=1"
exit /b 0

:wait_port
set /a _tries=%~1
:wait_loop
call :port_listening
if "%LISTENING%"=="1" exit /b 0
set /a _tries-=1
if %_tries% LEQ 0 exit /b 1
ping -n 2 127.0.0.1 >nul
goto wait_loop

:finish
echo.
if not defined VMANGOS_NO_PAUSE pause
exit /b %CODE%
