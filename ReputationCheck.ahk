#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, RegEx 

#IfWinActive ahk_exe PathOfExile.*.exe

^r::
    GetReputation()
return

#IfWinActive

#IfWinActive ahk_exe ReputationCheck.*.exe
; Just in case the popup dialog gains focus
^r::
    GetReputation()
return

#IfWinActive