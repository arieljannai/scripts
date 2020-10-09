;WinWait VLC media player
;WinActivate

WinGet, activeWindow, ID
;WinMove, ahk_id %activeWindow%, 1300, 20, A_ScreenWidth-1300, A_ScreenHeight-700
WinMove, A,,,, A_ScreenWidth-600
;Sleep, 500
;WinMove, A,,,, A_ScreenWidth

;WinGetPos, X, Y, Width, Height, %WinTitle%
;WinMove, ahk_id %activeWindow%,,,, (A_ScreenWidth/2)-(Width/2), (A_ScreenHeight/2)-(Height/2)
Exit