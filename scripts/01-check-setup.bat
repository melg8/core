@echo off
chcp 65001 >nul
setlocal EnableExtensions
set "CODE=0"
set "HERE=%~dp0"
call "%HERE%00-server-config.bat"

set "FAILS=0"
set "WARNS=0"

echo ============================================================
echo   VMaNGOS - проверка готовности сервера
echo ============================================================
echo.

call :check_file "%BIN_DIR%\realmd.exe"   "bin\realmd.exe"
call :check_file "%BIN_DIR%\mangosd.exe"  "bin\mangosd.exe"
call :check_file "%BIN_DIR%\realmd.conf"  "bin\realmd.conf"
call :check_file "%BIN_DIR%\mangosd.conf" "bin\mangosd.conf"

if exist "%BIN_DIR%\maps\*.map"      (echo [ OK ] карты: bin\maps)        else (echo [FAIL] нет карт в bin\maps & set /a FAILS+=1)
if exist "%BIN_DIR%\vmaps\*.vmtree"  (echo [ OK ] vmaps: bin\vmaps)       else (echo [FAIL] нет vmaps в bin\vmaps & set /a FAILS+=1)
if exist "%BIN_DIR%\mmaps\*.mmap"    (echo [ OK ] mmaps: bin\mmaps)       else (echo [FAIL] нет mmaps в bin\mmaps & set /a FAILS+=1)
if exist "%BIN_DIR%\5875\dbc\Map.dbc" (echo [ OK ] DBC: bin\5875\dbc)     else (echo [FAIL] нет DBC в bin\5875\dbc & set /a FAILS+=1)

echo.
if exist "%MYSQL%" (echo [ OK ] MySQL: "%MYSQL%") else (echo [FAIL] не найден "%MYSQL%" & set /a FAILS+=1)

call :port_listening %MYSQL_PORT%
if "%LISTENING%"=="1" (
    echo [ OK ] MySQL слушает порт %MYSQL_PORT%
) else (
    echo [FAIL] MySQL не запущен ^(порт %MYSQL_PORT%^)
    set /a FAILS+=1
)

if "%LISTENING%"=="1" (
    echo.
    call :check_db mangos      "world"
    call :check_db characters  "characters"
    call :check_db realmd      "realmd"
    call :check_db logs        "logs"
    call :check_realm
    call :check_db_user
)

echo.
if not defined CLIENT_DIR (
    echo [WARN] путь к клиенту не задан - 06-play.bat спросит его при первом запуске
    set /a WARNS+=1
) else (
    if exist "%CLIENT_DIR%\wow.exe" (
        echo [ OK ] клиент: "%CLIENT_DIR%"
    ) else (
        echo [FAIL] в "%CLIENT_DIR%" нет wow.exe
        set /a FAILS+=1
    )
)

echo.
echo ============================================================
if %FAILS% GTR 0 (
    echo  Проблем: %FAILS%. Исправь и запусти проверку снова.
    echo  Обычно помогает: 02-start-mysql.bat, затем 03-setup-database.bat.
    set "CODE=1"
    goto :finish
)
if %WARNS% GTR 0 (
    echo  Всё критичное готово ^(есть предупреждения^).
) else (
    echo  Всё готово.
)
echo  Следующий шаг: 04-start-server.bat
goto :finish

rem ============================================================================
:check_file
if exist "%~1" (echo [ OK ] %~2) else (echo [FAIL] не найден %~2 & set /a FAILS+=1)
exit /b 0

:check_db
set "DBN=%~1"
set "DBL=%~2"
set "CNT="
"%MYSQL%" %MYSQL_ARGS% -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='%DBN%';" > "%TEMP%\vmangos_cnt.txt" 2>nul
for /f "usebackq delims=" %%c in ("%TEMP%\vmangos_cnt.txt") do set "CNT=%%c"
if not defined CNT set "CNT=0"
if "%CNT%"=="0" (
    echo [FAIL] база %DBL% пуста или не создана
    set /a FAILS+=1
) else (
    echo [ OK ] база %DBL%
)
exit /b 0

:check_realm
set "CNT="
"%MYSQL%" %MYSQL_ARGS% -N -B realmd -e "SELECT COUNT(*) FROM realmlist WHERE id=%REALM_ID%;" > "%TEMP%\vmangos_realm.txt" 2>nul
for /f "usebackq delims=" %%c in ("%TEMP%\vmangos_realm.txt") do set "CNT=%%c"
if "%CNT%"=="1" (echo [ OK ] запись realmlist id=%REALM_ID%) else (echo [FAIL] в realmd.realmlist нет записи id=%REALM_ID%& set /a FAILS+=1)
exit /b 0

:check_db_user
if not defined DB_USER (
    echo [FAIL] DB_USER не задан в 00-server-config.bat
    set /a FAILS+=1
    exit /b 0
)
set "OLD_PWD=%MYSQL_PWD%"
set "MYSQL_PWD=%DB_PASS%"
"%MYSQL%" --host=%MYSQL_HOST% --port=%MYSQL_PORT% --user=%DB_USER% --protocol=TCP -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo [FAIL] пользователь MySQL "%DB_USER%" не может подключиться
    set /a FAILS+=1
) else (
    echo [ OK ] пользователь MySQL "%DB_USER%"
)
set "MYSQL_PWD=%OLD_PWD%"
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
