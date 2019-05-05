#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

global windowDisplayed := false

GetReputation() {
    if (windowDisplayed) {
        Gui, Destroy
        windowDisplayed := false
    } else {
        WinGet, ActiveId, ID, A
        clipboard = 
        Send, +{Home}
        Send, ^c
        Send, {End}
        ClipWait
        characterName := clipboard
        ; Trim @ character
        StringGetPos, startCharacterNamePos, characterName , @
        if (startCharacterNamePos == 0) {
            StringTrimLeft, characterName, characterName, 1
        }
        StringGetPos, endCharacterNamePos, characterName , %A_Space%
        if (endCharacterNamePos > 0) {
            StringLeft, characterName, characterName, endCharacterNamePos
        }
        ; Get the current datetime
        FormatTime, CurrentDateTime,, yyyyMMddHHmmss
        ; Make a request to the Reputation API
        RequestData(characterName)
        ; Make sure the response is new
        dateOk := CheckDate(characterName, CurrentDateTime)
        if dateOk {
            FileRead, Contents, repChecks/%characterName%.txt
            if not ErrorLevel  ; Successfully loaded.
            {
                CreateWindow(Contents)
                windowDisplayed := true
            } else {
                CreateWindow("An error occurred opening the characters review")
                windowDisplayed := true
            }
        } else {
            CreateWindow("Failed to get character reviews")
            windowDisplayed := true
        }
        ; Focus game window
        WinActivate, ahk_id %ActiveId%
    }
}

RequestData(characterName) {
    RunWait, characterCheck.exe %characterName%, Hide
}

CheckDate(characterName, currentDate) {
    FileGetTime, modtime , repChecks/%characterName%.txt, M
    FormatTime, mytime , %modtime%, yyyyMMddHHmmss
    return ((mytime - currentDate) >= 0)
}

CreateWindow(key){
    width = W300
    MouseGetPos , xPlacement, yPlacement

    Gui, Color, 1b1b1b
    Gui, Margin, 0, 0
    Gui, +LastFound +AlwaysOnTop -Border -SysMenu +Owner -Caption +ToolWindow
    Gui, Font, s10 cWhite, Consolas
    Gui, Add, Text, %width%, % key
    GuiControlGet T, Pos, Static1
    xPlacement := xPlacement - (TW / 2)
    ; yPlacement := yPlacement - (TH / 2)
    Gui, Show, x%xPlacement% y%yPlacement% %width%
}