@echo off
chcp 65001 >nul
setlocal EnableExtensions
set "CODE=0"
set "HERE=%~dp0"
call "%HERE%00-server-config.bat"

set "ACC=%~1"
set "PASS=%~2"
if not defined ACC set "ACC=%GM_ACCOUNT%"
if not defined PASS set "PASS=%GM_PASSWORD%"

if not defined ACC (
    echo Использование: 05-create-account.bat [логин] [пароль]
    set "CODE=1"
    goto :finish
)
if not defined PASS (
    echo Использование: 05-create-account.bat [логин] [пароль]
    set "CODE=1"
    goto :finish
)

echo %ACC%| findstr /R /C:"^[A-Za-z0-9_][A-Za-z0-9_]*$" >nul
if errorlevel 1 (
    echo [ОШИБКА] Логин: только латиница, цифры и подчёркивание.
    set "CODE=1"
    goto :finish
)
echo %PASS%| findstr /R /C:"^[A-Za-z0-9_][A-Za-z0-9_]*$" >nul
if errorlevel 1 (
    echo [ОШИБКА] Пароль: только латиница, цифры и подчёркивание.
    set "CODE=1"
    goto :finish
)

call :port_listening %WORLD_PORT%
if "%LISTENING%"=="0" (
    echo [ОШИБКА] Сервер не запущен. Сначала 04-start-server.bat.
    set "CODE=1"
    goto :finish
)

call :account_exists "%ACC%"
if "%EXISTS%"=="1" (
    echo Аккаунт "%ACC%" уже есть.
    echo Сменить пароль можно в окне mangosd:
    echo    account set password %ACC% ^<пароль^> ^<пароль^>
    goto :finish
)

> "%TEMP%\vmangos_account_cmd.txt" (
    echo account create %ACC% %PASS%
    echo account set gmlevel %ACC% 3
)
type "%TEMP%\vmangos_account_cmd.txt" | clip >nul 2>&1

echo ============================================================
echo   Создание аккаунта "%ACC%"
echo ============================================================
echo.
echo Команды скопированы в буфер обмена:
echo    account create %ACC% %PASS%
echo    account set gmlevel %ACC% 3
echo.
echo 1. Переключись в окно "VMaNGOS mangosd".
echo 2. Вставь команды ^(Ctrl+V или правый клик мыши^) и нажми Enter.
echo 3. Вернись сюда и нажми любую клавишу.
echo.
pause >nul

call :account_exists "%ACC%"
if "%EXISTS%"=="1" (
    echo [ OK ] Аккаунт "%ACC%" создан, права администратора выданы.
) else (
    echo [WARN] Аккаунт пока не найден.
    echo        Проверь окно mangosd: возможно, логин занят или не подошёл пароль.
)
goto :finish

rem ============================================================================
:account_exists
set "EXISTS=0"
set "CNT="
"%MYSQL%" %MYSQL_ARGS% -N -B realmd -e "SELECT COUNT(*) FROM account WHERE username='%~1';" > "%TEMP%\vmangos_acc.txt" 2>nul
for /f "usebackq delims=" %%c in ("%TEMP%\vmangos_acc.txt") do set "CNT=%%c"
if "%CNT%"=="1" set "EXISTS=1"
exit /b 0

:port_listening
set "LISTENING=0"
netstat -ano | findstr /C:":%~1 " | findstr /C:"LISTENING" >nul 2>&1
if not errorlevel 1 set "LISTENING=1"
exit /b 0

:finish
echo.
if not defined VMANGOS_NO_PAUSE pause
exit /b %CODE%
