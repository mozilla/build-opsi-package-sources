
;--- AutoIt Macro Generator V 0.21 beta ---
Opt("WinWaitDelay",100)
Opt("WinTitleMatchMode",4)
Opt("WinDetectHiddenText",1)
Opt("MouseCoordMode",0)
Run($CmdLine[1])
WinWait("Setup - KpyM Telnet/SSH Server v1.18","This will install KpyM Telnet/")
ControlClick("Setup - KpyM Telnet/SSH Server v1.18","This will install KpyM Telnet/","TNewButton1")
WinWait("Setup - KpyM Telnet/SSH Server v1.18","Please read the following impo")
ControlClick("Setup - KpyM Telnet/SSH Server v1.18","Please read the following impo","TNewRadioButton1")
ControlClick("Setup - KpyM Telnet/SSH Server v1.18","Please read the following impo","TNewButton2")
WinWait("Setup - KpyM Telnet/SSH Server v1.18","Where should KpyM Telnet/SSH S")
ControlClick("Setup - KpyM Telnet/SSH Server v1.18","Where should KpyM Telnet/SSH S","TNewButton3")
WinWait("Setup - KpyM Telnet/SSH Server v1.18","Which components should be ins")
ControlClick("Setup - KpyM Telnet/SSH Server v1.18","Which components should be ins","TNewButton3")
WinWait("Setup - KpyM Telnet/SSH Server v1.18","Where should Setup place the p")
ControlClick("Setup - KpyM Telnet/SSH Server v1.18","Where should Setup place the p","TNewButton4")
WinWait("Setup - KpyM Telnet/SSH Server v1.18","Select KTS startup type?")
ControlClick("Setup - KpyM Telnet/SSH Server v1.18","Select KTS startup type?","TNewButton4")
WinWait("Setup - KpyM Telnet/SSH Server v1.18","Setup has finished installing ")
ControlClick("Setup - KpyM Telnet/SSH Server v1.18","Setup has finished installing ","TNewButton4")

;--- End ---
