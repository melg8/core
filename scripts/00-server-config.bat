@echo off
rem ============================================================================
rem  VMaNGOS local server - shared settings
rem
rem  Edit this file once. Every other script reads the values from here.
rem  Do not run this file directly.
rem ============================================================================

rem The scripts live in <root>\scripts; ROOT is the repository root.
for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "BIN_DIR=%ROOT%\bin"
set "DB_DIR=%ROOT%\db"
set "TOOLS_DIR=%ROOT%\tools"

rem --- MySQL (XAMPP) ---------------------------------------------------------
rem MYSQL_HOME points to the XAMPP MySQL folder.
rem MYSQL_PASS is empty for a default XAMPP install (root without password).
set "MYSQL_HOME=C:\xampp\mysql"
set "MYSQL_BIN=%MYSQL_HOME%\bin"
set "MYSQL_HOST=127.0.0.1"
set "MYSQL_PORT=3306"
set "MYSQL_USER=root"
set "MYSQL_PASS="
set "MYSQL_SERVICE=MySQL"

rem --- Database credentials written into bin\*.conf --------------------------
rem The core's connection-string parser drops empty fields, so the server
rem cannot use an empty password. These scripts create this MySQL user
rem automatically in 03-setup-database.bat.
set "DB_USER=mangos"
set "DB_PASS=mangos"

rem --- Realm -----------------------------------------------------------------
set "REALM_ID=1"
set "REALM_NAME=Local"
set "REALM_ADDRESS=127.0.0.1"
set "WORLD_PORT=8085"
set "AUTH_PORT=3724"

rem --- WoW 1.12.1 client folder (the folder that contains wow.exe) -----------
rem Leave empty: 06-play.bat will ask once and remember the path
rem in client-dir.txt.
set "CLIENT_DIR="
if not defined CLIENT_DIR if exist "%ROOT%\client-dir.txt" for /f "usebackq delims=" %%c in ("%ROOT%\client-dir.txt") do set "CLIENT_DIR=%%c"

rem --- Default GM account for 05-create-account.bat --------------------------
set "GM_ACCOUNT=admin"
set "GM_PASSWORD=admin"

rem --- Internals -------------------------------------------------------------
set "MYSQL=%MYSQL_BIN%\mysql.exe"
set "MYSQLADMIN=%MYSQL_BIN%\mysqladmin.exe"
set "MYSQL_ARGS=--host=%MYSQL_HOST% --port=%MYSQL_PORT% --user=%MYSQL_USER% --protocol=TCP"
rem Use MYSQL_PWD instead of --password= to keep special characters working.
if defined MYSQL_PASS set "MYSQL_PWD=%MYSQL_PASS%"

exit /b 0
