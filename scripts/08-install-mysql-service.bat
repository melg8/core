@echo off
chcp 65001 >nul
setlocal EnableExtensions

rem --- self-elevate -----------------------------------------------------------
net session >nul 2>&1
if errorlevel 1 (
    echo Требуются права администратора - запрашиваю повышение...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "CODE=0"
set "HERE=%~dp0"
call "%HERE%00-server-config.bat"

echo ============================================================
echo   Установка MySQL (XAMPP) как службы Windows
echo ============================================================
echo.

if not exist "%MYSQL_BIN%\mysqld.exe" (
    echo [ОШИБКА] Не найден "%MYSQL_BIN%\mysqld.exe".
    echo Поправь MYSQL_HOME в 00-server-config.bat.
    set "CODE=1"
    goto :finish
)

call :port_listening
if "%LISTENING%"=="1" (
    echo [ВНИМАНИЕ] MySQL уже запущен на порту %MYSQL_PORT%.
    echo Сначала останови его: закрой окно "XAMPP MySQL" ^(если MySQL запущен им^).
    echo Иначе служба не сможет занять порт.
    echo.
    choice /C YN /N /M "Продолжить? [Y/N] "
    if errorlevel 2 (
        set "CODE=1"
        goto :finish
    )
)

sc query "%MYSQL_SERVICE%" >nul 2>&1
if errorlevel 1 (
    echo Устанавливаю службу "%MYSQL_SERVICE%"...
    "%MYSQL_BIN%\mysqld.exe" --install "%MYSQL_SERVICE%" --defaults-file="%MYSQL_HOME%\bin\my.ini"
    if errorlevel 1 (
        echo [ОШИБКА] Не удалось установить службу.
        set "CODE=1"
        goto :finish
    )
) else (
    echo Служба "%MYSQL_SERVICE%" уже установлена.
)

sc config "%MYSQL_SERVICE%" start= auto >nul
echo Запускаю службу...
net start "%MYSQL_SERVICE%"
if errorlevel 1 (
    echo [ОШИБКА] Служба не запустилась.
    echo Проверь "%MYSQL_HOME%\data\mysql_error.log".
    set "CODE=1"
    goto :finish
)

echo.
echo Готово: MySQL теперь запускается автоматически при старте Windows.
goto :finish

rem ============================================================================
:port_listening
set "LISTENING=0"
netstat -ano | findstr /C:":%MYSQL_PORT% " | findstr /C:"LISTENING" >nul 2>&1
if not errorlevel 1 set "LISTENING=1"
exit /b 0

:finish
echo.
if not defined VMANGOS_NO_PAUSE pause
exit /b %CODE%
