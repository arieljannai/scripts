; F2::
; ; WinGetClass, Class, A
; ; MsgBox, % Class
; MouseGetPos , , , ID
; WinGetTitle T, ahk_id %ID%
; WinGetClass C, ahk_id %ID%
; WinGet P, ProcessName, ahk_id %ID%
; ToolTip Title : %T%`nWindow Class : %C%`nProcess : %P%`n%ID%
; Return

; ZAZU_ID=0x304b0
; DESKTOP_ID=0x40334
; zazu:
; ; WinGetClass, Class, A
; ; WinGetTitle, LastTitle, A
; ; MsgBox, % LastTitle
; ; WinGetClass, LastClass, A
; ; MsgBox, % LastClass
; ; WinGet, IDDA, ID
; ; WinWait, Zazu
; ; WinWaitClose, Zazu

; IfWinActive, Zazu
; {
; 	WinWaitClose, Zazu
; 	Send, {AltDown}{Tab}{AltUp}
; 	; MsgBox, lalal
; }

; ; IfWinNotActive, Zazu
; ; {
; ; 	IfWinActive, ahk_id 0x40334
; ; 	{
; ; 		IfWinActive, Zazu
; ; 		{
; ; 			WinWaitClose, Zazu
; ; 			; WinActivate, ahk_id 0x40334
; ; 			; MsgBox, woohoo
; ; 			Goto, zazu
; ; 		}
; ; 	}
; ; 	Else
; ; 	{
; ; 		IfWinActive, Zazu
; ; 		{
; ; 			WinWaitClose, Zazu
; ; 			Send, {AltDown}{Tab}{AltUp}
; ; 			; MsgBox, lalal
; ; 		}
; ; 	}
; ; }

; ; SetTitleMatchMode, RegEx
; ; MsgBox, % Class
; ; MsgBox, % IDDA
; ; IfWinNotActive, ahk_id %ID
; ; if !WinActivate, ahk_id %ID%
; ; {
; ; 	Send, {AltDown}{Tab}{AltUp}
; ; }
; Goto, zazu


; ; desktop:
; ; ID=0x40334
; ; IfWinActive, ahk_id %ID%
; ; {
; ; 	MsgBox, yo
; ; }
; ; Goto, desktop