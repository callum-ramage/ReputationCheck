#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, RegEx 

windowDisplayed := false

#IfWinActive ahk_exe PathOfExile.*.exe

#IfWinActive

^r::
    if (windowDisplayed) {
        Gui, Destroy
        windowDisplayed := false
    } else {
        ; Send, {ShiftDown}{Home}{ShiftUp}
        ; Send, {CtrlDown}c{CtrlUp}
        ; Send, {Esc}
        CreateWindow("Win + 7")
        windowDisplayed := true
    }
return

CreateWindow(key){
    GetTextSize(key,35,Verdana,height,width)
    bgTopPadding = 40
    bgWidthPadding = 100
    bgHeight := height + bgTopPadding
    bgWidth := width + bgWidthPadding
    padding = 20
    MouseGetPos , xPlacement, yPlacement
    ; yPlacement := (1*A_ScreenHeight) – bgHeight – padding
    ; xPlacement := (1*A_ScreenWidth) – bgWidth – padding

    Gui, Color, 46bfec
    Gui, Margin, 0, 0
    ; Gui, Add, Picture, x0 y0 w%bgWidth% h%bgHeight%, C:\Users\IrisDaniela\Pictures\bg.png
    Gui, +LastFound +AlwaysOnTop -Border -SysMenu +Owner -Caption +ToolWindow
    Gui, Font, s35 cWhite, Verdana
    ; Gui, Add, Text, xm y20 x25 ,%key%
    Gui, Add, Text,, % key " y" yPlacement " x" xPlacement " " A_ScreenHeight " " bgHeight " " bgWidth
    Gui, Show, x%xPlacement% y%yPlacement%
    ; Gui, Show
}

GetTextSize(str, size, font,ByRef height,ByRef width) {
    Gui temp: Font, s%size%, %font%
    Gui temp:Add, Text, , %str%
    GuiControlGet T, temp:Pos, Static1
    Gui temp:Destroy
    height = % TH
    width = % TW
}