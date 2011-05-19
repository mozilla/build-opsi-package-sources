REM take some time to warm up
D:\mozilla-build\msys\bin\sleep.exe 30

d:
cd \mozilla-build
start /min start-buildbot.bat

REM and don't close this window so quickly that a SIGBREAK will be sent to start-buildbot.bat
D:\mozilla-build\msys\bin\sleep.exe 30
