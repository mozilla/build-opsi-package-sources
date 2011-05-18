@echo off

SET MOZ_MSVCVERSION=8

SET MOZILLABUILDDRIVE=%~d0%
SET MOZILLABUILDPATH=%~p0%
SET MOZILLABUILD=%MOZILLABUILDDRIVE%%MOZILLABUILDPATH%

set log="c:\tmp\buildbot-startup.log"

echo "Mozilla tools directory: %MOZILLABUILD%"

REM Get MSVC paths
echo "%date% %time% - About to call guess-msvc.bat" >> %log%
call "%MOZILLABUILD%\guess-msvc.bat"

REM Use the "new" moztools-static
set MOZ_TOOLS=%MOZILLABUILD%\moztools

rem append moztools to PATH
SET PATH=%PATH%;%MOZ_TOOLS%\bin

if "%VC8DIR%"=="" (
    if "%VC8EXPRESSDIR%"=="" (
        echo "%date% %time% - MSVC++8 not found" >> %log%
        ECHO "Microsoft Visual C++ version 8 was not found. Exiting."
        pause
        EXIT /B 1
    )

    if "%SDKDIR%"=="" (
        echo "%date% %time% - SDK not found" >> %log%
        ECHO "Microsoft Platform SDK was not found. Exiting."
        pause
        EXIT /B 1
    )

    rem Prepend MSVC paths
    echo "%date% %time% - About to call vcvars32.bat" >> %log%
    call "%VC8EXPRESSDIR%\Bin\vcvars32.bat"

    SET USESDK=1
    rem Don't set SDK paths in this block, because blocks are early-evaluated.
) else (
    rem Prepend MSVC paths
    echo "%date% %time% - Calling vcvars32.bat in VC8DIR" >> %log%
    call "%VC8DIR%\Bin\vcvars32.bat"

    rem If the SDK is Win2k3SP2 or higher, we want to use it
    if %SDKVER% GEQ 5 (
      SET USESDK=1
    )
)

if "%USESDK%"=="1" (
    rem Prepend SDK paths - Don't use the SDK SetEnv.cmd because it pulls in
    rem random VC paths which we don't want.
    rem Add the atlthunk compat library to the end of our LIB
    set PATH=%SDKDIR%\bin;%PATH%
    set LIB=%SDKDIR%\lib;%LIB%;%MOZILLABUILD%\atlthunk_compat
    set INCLUDE=%SDKDIR%\include;%SDKDIR%\include\atl;%INCLUDE%
)

rem Set up Direct X 10 environment
set INCLUDE=%INCLUDE%;d:\sdks\dx10\include
if "%WIN64%" == "1" (
  set LIB=%LIB%;d:\sdks\dx10\lib\x64
) else (
  set LIB=%LIB%;d:\sdks\dx10\lib\x86
)

cd "%USERPROFILE%"
:start
echo "%date% %time% - About to run runslave.py"
"%MOZILLABUILD%\python25\python" c:\runslave.py
echo "%date% %time% - runslave.py finished"
