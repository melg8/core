@echo off
chcp 65001 >nul
setlocal EnableExtensions
set "CODE=0"
set "HERE=%~dp0"
call "%HERE%00-server-config.bat"

echo ============================================================
echo   VMaNGOS - остановка сервера
echo ============================================================
echo.

tasklist /FI "IMAGENAME eq mangosd.exe" 2>nul | findstr /I /C:"mangosd.exe" >nul
if errorlevel 1 (
    echo mangosd не запущен.
) else (
    echo server shutdown 0| clip >nul 2>&1
    echo Команда скопирована в буфер обмена:
    echo.
    echo     server shutdown 0
    echo.
    echo Переключись в окно "VMaNGOS mangosd", вставь ^(Ctrl+V или правый клик^)
    echo и нажми Enter. Жду завершения до 60 секунд...
    call :wait_proc_exit mangosd.exe 60
    tasklist /FI "IMAGENAME eq mangosd.exe" 2>nul | findstr /I /C:"mangosd.exe" >nul
    if not errorlevel 1 (
        echo.
        echo [ВНИМАНИЕ] mangosd не завершился за 60 секунд.
        choice /C YN /N /M "Завершить принудительно? [Y/N] "
        if errorlevel 2 (
            echo Принудительное завершение отменено.
            goto :finish
        )
        taskkill /F /IM mangosd.exe >nul 2>&1
        echo mangosd завершён принудительно.
    ) else (
        echo mangosd остановлен.
    )
)

taskkill /F /IM realmd.exe >nul 2>&1
echo realmd остановлен.
echo.
echo Готово.
goto :finish

rem ============================================================================
:wait_proc_exit
set /a _tries=%~2
:wait_proc_loop
tasklist /FI "IMAGENAME eq %~1" 2>nul | findstr /I /C:"%~1" >nul
if errorlevel 1 exit /b 0
set /a _tries-=1
if %_tries% LEQ 0 exit /b 1
ping -n 2 127.0.0.1 >nul
goto wait_proc_loop

:finish
echo.
if not defined VMANGOS_NO_PAUSE pause
exit /b %CODE%
