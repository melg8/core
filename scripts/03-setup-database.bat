@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
set "CODE=0"
set "HERE=%~dp0"
call "%HERE%00-server-config.bat"

set "FORCE=0"
if /I "%~1"=="reimport" set "FORCE=1"

echo ============================================================
echo   VMaNGOS - настройка баз данных
echo ============================================================
echo.

call :port_listening
if "%LISTENING%"=="0" (
    echo [ОШИБКА] MySQL не запущен. Сначала запусти 02-start-mysql.bat.
    set "CODE=1"
    goto :finish
)

echo [1/5] Ослабляю режим MySQL под старые дампы...
"%MYSQL%" %MYSQL_ARGS% -e "SET GLOBAL sql_mode=''; SET GLOBAL max_allowed_packet=134217728; SET GLOBAL innodb_strict_mode=OFF;" >nul
if errorlevel 1 (
    echo [ОШИБКА] Не удалось выполнить SET GLOBAL ^(нужны права root^).
    set "CODE=1"
    goto :finish
)

echo [2/5] Проверяю дампы в "%DB_DIR%"...
set "MISSING=0"
for %%f in (logon.sql mangos.sql characters.sql logs.sql) do if not exist "%DB_DIR%\%%f" set "MISSING=1"
if "%MISSING%"=="1" (
    echo       Дампов нет - скачиваю последний снимок базы с GitHub...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%TOOLS_DIR%\fetch-db-dump.ps1" -DestDir "%DB_DIR%"
    if errorlevel 1 (
        echo.
        echo [ОШИБКА] Не удалось скачать дампы.
        echo Положи вручную в "%DB_DIR%" файлы logon.sql, mangos.sql, characters.sql, logs.sql
        echo и запусти этот скрипт снова.
        set "CODE=1"
        goto :finish
    )
)
for %%f in (logon.sql mangos.sql characters.sql logs.sql) do if not exist "%DB_DIR%\%%f" (
    echo [ОШИБКА] После скачивания нет файла "%DB_DIR%\%%f".
    set "CODE=1"
    goto :finish
)

echo [3/5] Создаю базы и пользователя MySQL "%DB_USER%"...
if not defined DB_USER (
    echo [ОШИБКА] DB_USER не задан в 00-server-config.bat.
    set "CODE=1"
    goto :finish
)
if not defined DB_PASS (
    echo [ОШИБКА] DB_PASS не должен быть пустым ^(парсер ядра пропускает пустые поля^).
    set "CODE=1"
    goto :finish
)
for %%d in (realmd mangos characters logs) do (
    "%MYSQL%" %MYSQL_ARGS% -e "CREATE DATABASE IF NOT EXISTS %%d DEFAULT CHARSET utf8 COLLATE utf8_general_ci;"
    if errorlevel 1 (
        echo [ОШИБКА] Не удалось создать базу %%d.
        set "CODE=1"
        goto :finish
    )
)
"%MYSQL%" %MYSQL_ARGS% -e "CREATE USER IF NOT EXISTS '%DB_USER%'@'localhost' IDENTIFIED BY '%DB_PASS%'; SET PASSWORD FOR '%DB_USER%'@'localhost' = PASSWORD('%DB_PASS%'); CREATE USER IF NOT EXISTS '%DB_USER%'@'127.0.0.1' IDENTIFIED BY '%DB_PASS%'; SET PASSWORD FOR '%DB_USER%'@'127.0.0.1' = PASSWORD('%DB_PASS%'); GRANT ALL PRIVILEGES ON realmd.* TO '%DB_USER%'@'localhost'; GRANT ALL PRIVILEGES ON mangos.* TO '%DB_USER%'@'localhost'; GRANT ALL PRIVILEGES ON characters.* TO '%DB_USER%'@'localhost'; GRANT ALL PRIVILEGES ON logs.* TO '%DB_USER%'@'localhost'; GRANT ALL PRIVILEGES ON realmd.* TO '%DB_USER%'@'127.0.0.1'; GRANT ALL PRIVILEGES ON mangos.* TO '%DB_USER%'@'127.0.0.1'; GRANT ALL PRIVILEGES ON characters.* TO '%DB_USER%'@'127.0.0.1'; GRANT ALL PRIVILEGES ON logs.* TO '%DB_USER%'@'127.0.0.1'; FLUSH PRIVILEGES;"
if errorlevel 1 (
    echo [ОШИБКА] Не удалось создать пользователя MySQL "%DB_USER%".
    set "CODE=1"
    goto :finish
)

if "%FORCE%"=="1" (
    echo [4/5] Принудительный реимпорт: удаляю старые базы...
    for %%d in (realmd mangos characters logs) do (
        "%MYSQL%" %MYSQL_ARGS% -e "DROP DATABASE IF EXISTS %%d; CREATE DATABASE %%d DEFAULT CHARSET utf8 COLLATE utf8_general_ci;"
        if errorlevel 1 (
            echo [ОШИБКА] Не удалось пересоздать базу %%d.
            set "CODE=1"
            goto :finish
        )
    )
) else (
    echo [4/5] Импортирую дампы ^(уже заполненные базы пропускаются^)...
)

call :import_db realmd logon.sql
if errorlevel 1 (set "CODE=1" & goto :finish)
call :import_db mangos mangos.sql
if errorlevel 1 (set "CODE=1" & goto :finish)
call :import_db characters characters.sql
if errorlevel 1 (set "CODE=1" & goto :finish)
call :import_db logs logs.sql
if errorlevel 1 (set "CODE=1" & goto :finish)

echo [5/5] Прописываю realmlist и подключения в конфигах...
"%MYSQL%" %MYSQL_ARGS% realmd -e "INSERT INTO realmlist (id,name,address,localAddress,localSubnetMask,port,icon,realmflags,timezone,allowedSecurityLevel,population,realmbuilds) VALUES (%REALM_ID%,'%REALM_NAME%','%REALM_ADDRESS%','%REALM_ADDRESS%','255.255.255.0',%WORLD_PORT%,0,0,0,0,0,'') ON DUPLICATE KEY UPDATE name=VALUES(name),address=VALUES(address),localAddress=VALUES(localAddress),localSubnetMask=VALUES(localSubnetMask),port=VALUES(port),icon=VALUES(icon),realmflags=VALUES(realmflags),timezone=VALUES(timezone),allowedSecurityLevel=VALUES(allowedSecurityLevel),realmbuilds=VALUES(realmbuilds);"
if errorlevel 1 (
    echo [ОШИБКА] Не удалось записать запись в realmd.realmlist.
    set "CODE=1"
    goto :finish
)

call :prepare_configs
if errorlevel 1 (
    echo [ОШИБКА] Не удалось обновить конфиги.
    set "CODE=1"
    goto :finish
)

echo.
echo ============================================================
echo   Готово. Следующий шаг: 04-start-server.bat
echo ============================================================
goto :finish

rem ============================================================================
:import_db
set "DBNAME=%~1"
set "DUMPFILE=%~2"
set "CNT="
"%MYSQL%" %MYSQL_ARGS% -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='%DBNAME%';" > "%TEMP%\vmangos_cnt.txt" 2>nul
for /f "usebackq delims=" %%c in ("%TEMP%\vmangos_cnt.txt") do set "CNT=%%c"
if not defined CNT set "CNT=0"
if not "%CNT%"=="0" (
    echo       - %DBNAME%: уже заполнена, пропуск
    exit /b 0
)
echo       - %DBNAME%: импорт %DUMPFILE% ...
"%MYSQL%" %MYSQL_ARGS% --max_allowed_packet=134217728 --default-character-set=utf8 "%DBNAME%" < "%DB_DIR%\%DUMPFILE%"
if errorlevel 1 (
    echo       [ОШИБКА] импорт %DUMPFILE% не удался
    exit /b 1
)
echo       - %DBNAME%: готово
exit /b 0

:prepare_configs
set "NEW_MANGOSD=%ROOT%\src\mangosd\mangosd.conf.dist.in"
set "NEW_REALMD=%ROOT%\src\realmd\realmd.conf.dist.in"
set "MANGOSD_CONF=%BIN_DIR%\mangosd.conf"
set "REALMD_CONF=%BIN_DIR%\realmd.conf"

if not exist "%NEW_MANGOSD%" (
    echo       [ОШИБКА] не найден шаблон "%NEW_MANGOSD%"
    exit /b 1
)
if not exist "%NEW_REALMD%" (
    echo       [ОШИБКА] не найден шаблон "%NEW_REALMD%"
    exit /b 1
)

call :conf_version "%MANGOSD_CONF%"
if not defined CONFVER set "CONFVER=0"
if %CONFVER% LSS 2025040601 (
    echo       - mangosd.conf устарел, обновляю из шаблона ^(старый: mangosd.conf.bak^)
    if exist "%MANGOSD_CONF%" copy /Y "%MANGOSD_CONF%" "%MANGOSD_CONF%.bak" >nul
    copy /Y "%NEW_MANGOSD%" "%MANGOSD_CONF%" >nul
)

call :conf_version "%REALMD_CONF%"
if not defined CONFVER set "CONFVER=0"
if %CONFVER% LSS 2026042601 (
    echo       - realmd.conf устарел, обновляю из шаблона ^(старый: realmd.conf.bak^)
    if exist "%REALMD_CONF%" copy /Y "%REALMD_CONF%" "%REALMD_CONF%.bak" >nul
    copy /Y "%NEW_REALMD%" "%REALMD_CONF%" >nul
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%TOOLS_DIR%\patch-db-config.ps1" -MangosdConf "%MANGOSD_CONF%" -RealmdConf "%REALMD_CONF%" -HostName "%MYSQL_HOST%" -Port %MYSQL_PORT% -User "%DB_USER%" -Password "%DB_PASS%" -Address "%REALM_ADDRESS%" -WorldPort %WORLD_PORT%
if errorlevel 1 exit /b 1
exit /b 0

:conf_version
set "CONFVER="
for /f "tokens=2 delims==" %%v in ('findstr /B /C:"ConfVersion" "%~1" 2^>nul') do set "CONFVER=%%v"
set "CONFVER=%CONFVER: =%"
exit /b 0

:port_listening
set "LISTENING=0"
netstat -ano | findstr /C:":%MYSQL_PORT% " | findstr /C:"LISTENING" >nul 2>&1
if not errorlevel 1 set "LISTENING=1"
exit /b 0

:finish
echo.
if not defined VMANGOS_NO_PAUSE pause
exit /b %CODE%
