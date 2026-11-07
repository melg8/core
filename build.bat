@echo off
rem ============================================================================
rem  vmangos/core - one-click build script (Windows / MSVC)
rem
rem  Usage:
rem    build.bat                incremental build (RelWithDebInfo)
rem    build.bat debug          incremental build (Debug)
rem    build.bat clean          delete build dir, then full rebuild
rem    build.bat clean debug    full Debug rebuild
rem
rem  Just double-click build.bat after changing sources: it re-runs CMake and
rem  rebuilds only what changed. Results are placed in bin\ (mangosd.exe,
rem  realmd.exe), so nothing else is needed to run the server.
rem
rem  Requirements:
rem    - Visual Studio 2017+ with the "Desktop development with C++" workload
rem      (provides MSVC, Windows SDK, CMake and Ninja)
rem    - ACE and TBB next to this repository (..\ACE_wrappers and ..\tbb) or
rem      ACE_ROOT / TBB_ROOT_DIR environment variables pointing to them.
rem ============================================================================
setlocal EnableExtensions

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "BUILD_DIR=%ROOT%\build\oneclick"
set "BUILD_TYPE=RelWithDebInfo"
set "DO_CLEAN=0"
set "PAUSE_AT_END=0"
if "%~1"=="" set "PAUSE_AT_END=1"

:parse_args
if "%~1"=="" goto args_done
if /I "%~1"=="clean" set "DO_CLEAN=1"
if /I "%~1"=="debug" set "BUILD_TYPE=Debug"
if /I "%~1"=="release" set "BUILD_TYPE=RelWithDebInfo"
if /I "%~1"=="relwithdebinfo" set "BUILD_TYPE=RelWithDebInfo"
shift
goto parse_args
:args_done

set "PF86=%ProgramFiles(x86)%"
if not defined PF86 set "PF86=%ProgramFiles%"
if not defined NUMBER_OF_PROCESSORS set "NUMBER_OF_PROCESSORS=4"

echo ============================================================
echo  vmangos/core build
echo    source : %ROOT%
echo    build  : %BUILD_DIR%
echo    config : %BUILD_TYPE%
echo ============================================================
echo.

rem ---------------------------------------------------------------------------
rem Locate Visual Studio and set up the MSVC environment.
rem Prefer VS 2017-2022 (CMake 3.x); fall back to any newer VS if that is all
rem that is installed.
rem ---------------------------------------------------------------------------
set "VS_PATH="
set "VSWHERE=%PF86%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" goto vs_fallback

rem NOTE: vswhere is called through a temp file, because its path and its
rem -version range contain parentheses, which break "for /f in (`...`)".
set "VS_TMP=%TEMP%\vmangos_vswhere.txt"
"%VSWHERE%" -latest -version "[17.0,18.0)" -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath > "%VS_TMP%" 2>nul
for /f "usebackq tokens=*" %%i in ("%VS_TMP%") do if not defined VS_PATH set "VS_PATH=%%i"
if defined VS_PATH goto vs_cleanup

"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath > "%VS_TMP%" 2>nul
for /f "usebackq tokens=*" %%i in ("%VS_TMP%") do if not defined VS_PATH set "VS_PATH=%%i"

:vs_cleanup
if exist "%VS_TMP%" del "%VS_TMP%" >nul 2>nul
if defined VS_PATH goto vs_done

:vs_fallback
for %%D in (
    "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise"
    "%ProgramFiles%\Microsoft Visual Studio\2022\Professional"
    "%ProgramFiles%\Microsoft Visual Studio\2022\Community"
    "%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools"
    "%PF86%\Microsoft Visual Studio\2022\BuildTools"
    "%PF86%\Microsoft Visual Studio\2022\Community"
    "%PF86%\Microsoft Visual Studio\2019\Enterprise"
    "%PF86%\Microsoft Visual Studio\2019\Professional"
    "%PF86%\Microsoft Visual Studio\2019\Community"
    "%PF86%\Microsoft Visual Studio\2019\BuildTools"
) do if not defined VS_PATH if exist "%%~D\VC\Auxiliary\Build\vcvars64.bat" set "VS_PATH=%%~D"

:vs_done
if not defined VS_PATH (
    echo ERROR: Visual Studio with C++ tools was not found.
    echo        Install "Desktop development with C++" or run this script from a
    echo        "Developer Command Prompt for VS".
    goto fail
)

echo Using Visual Studio: %VS_PATH%
call "%VS_PATH%\VC\Auxiliary\Build\vcvars64.bat" >nul
if errorlevel 1 (
    echo ERROR: failed to initialize the MSVC environment ^(vcvars64.bat^).
    goto fail
)

rem ---------------------------------------------------------------------------
rem Locate CMake and Ninja (prefer PATH, then the copies bundled with VS)
rem ---------------------------------------------------------------------------
set "CMAKE_EXE="
for /f "delims=" %%i in ('where cmake 2^>nul') do if not defined CMAKE_EXE set "CMAKE_EXE=%%i"
if not defined CMAKE_EXE if exist "%VS_PATH%\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe" set "CMAKE_EXE=%VS_PATH%\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
if not defined CMAKE_EXE if exist "%ProgramFiles%\CMake\bin\cmake.exe" set "CMAKE_EXE=%ProgramFiles%\CMake\bin\cmake.exe"
if not defined CMAKE_EXE (
    echo ERROR: CMake was not found. Install CMake or the VS "C++ CMake tools" component.
    goto fail
)

set "NINJA_EXE="
for /f "delims=" %%i in ('where ninja 2^>nul') do if not defined NINJA_EXE set "NINJA_EXE=%%i"
if not defined NINJA_EXE if exist "%VS_PATH%\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe" set "NINJA_EXE=%VS_PATH%\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja\ninja.exe"
if not defined NINJA_EXE (
    echo ERROR: Ninja was not found. Install Ninja or the VS "C++ CMake tools" component.
    goto fail
)

rem CMake 4 removed compatibility with cmake_minimum_required(VERSION 3.1);
rem allow it explicitly so the build also works on newer VS/CMake releases.
set "CMAKE_VER="
for /f "tokens=3" %%v in ('"%CMAKE_EXE%" --version') do if not defined CMAKE_VER set "CMAKE_VER=%%v"
set "CMAKE_MAJOR=0"
for /f "tokens=1 delims=." %%m in ("%CMAKE_VER%") do set "CMAKE_MAJOR=%%m"
set "POLICY_FLAG="
if %CMAKE_MAJOR% GEQ 4 set "POLICY_FLAG=-DCMAKE_POLICY_VERSION_MINIMUM=3.5"

echo Using CMake       : %CMAKE_EXE% ^(version %CMAKE_VER%^)
echo Using Ninja       : %NINJA_EXE%
echo.

rem ---------------------------------------------------------------------------
rem Locate ACE and TBB (environment variables win, then sibling directories)
rem ---------------------------------------------------------------------------
if not defined ACE_ROOT if exist "%ROOT%\..\ACE_wrappers\ace\ACE.h" for %%i in ("%ROOT%\..\ACE_wrappers") do set "ACE_ROOT=%%~fi"
if not defined TBB_ROOT_DIR if defined TBBROOT set "TBB_ROOT_DIR=%TBBROOT%"
if not defined TBB_ROOT_DIR if exist "%ROOT%\..\tbb\include\tbb\tbb.h" for %%i in ("%ROOT%\..\tbb") do set "TBB_ROOT_DIR=%%~fi"

if not defined ACE_ROOT (
    echo ERROR: ACE was not found.
    echo        Put ACE_wrappers next to this repository ^(..\ACE_wrappers^)
    echo        or set the ACE_ROOT environment variable.
    goto fail
)
if not defined TBB_ROOT_DIR (
    echo ERROR: TBB was not found.
    echo        Put TBB next to this repository ^(..\tbb^)
    echo        or set the TBB_ROOT_DIR environment variable.
    goto fail
)

echo Using ACE         : %ACE_ROOT%
echo Using TBB         : %TBB_ROOT_DIR%
echo.

rem Let CMake read the git revision even if the repo ownership check complains.
set "GIT_SAFE=%ROOT:\=/%"
set "GIT_CONFIG_COUNT=1"
set "GIT_CONFIG_KEY_0=safe.directory"
set "GIT_CONFIG_VALUE_0=%GIT_SAFE%"

rem ---------------------------------------------------------------------------
rem Clean, configure, build
rem ---------------------------------------------------------------------------
if "%DO_CLEAN%"=="1" (
    echo Cleaning %BUILD_DIR% ...
    if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
    echo.
)

rem Reconfigure only when there is no cache or the requested config differs.
rem Ninja re-runs CMake by itself when CMakeLists.txt / *.cmake files change.
if not exist "%BUILD_DIR%\CMakeCache.txt" goto do_configure
findstr /x /c:"CMAKE_BUILD_TYPE:STRING=%BUILD_TYPE%" "%BUILD_DIR%\CMakeCache.txt" >nul 2>nul
if errorlevel 1 goto do_configure
echo Reusing existing configuration.
goto after_configure

:do_configure
echo Configuring...
"%CMAKE_EXE%" -S "%ROOT%" -B "%BUILD_DIR%" -G Ninja ^
    -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
    -DCMAKE_MAKE_PROGRAM="%NINJA_EXE%" ^
    -DACE_ROOT="%ACE_ROOT%" ^
    -DTBB_ROOT_DIR="%TBB_ROOT_DIR%" ^
    %POLICY_FLAG% ^
    -DUSE_PCH=OFF ^
    -DUSE_EXTRACTORS=OFF ^
    -DUSE_REALMMERGE=OFF
if errorlevel 1 goto fail

:after_configure
echo.
echo Building with %NUMBER_OF_PROCESSORS% parallel jobs...
"%CMAKE_EXE%" --build "%BUILD_DIR%" --parallel %NUMBER_OF_PROCESSORS%
if errorlevel 1 goto fail

echo.
echo ============================================================
echo  BUILD SUCCEEDED  (%BUILD_TYPE%)
echo    %ROOT%\bin\mangosd.exe
echo    %ROOT%\bin\realmd.exe
echo ============================================================
set "EXIT_CODE=0"
goto finish

:fail
echo.
echo ============================================================
echo  BUILD FAILED
echo ============================================================
set "EXIT_CODE=1"

:finish
if "%PAUSE_AT_END%"=="1" pause
exit /b %EXIT_CODE%
