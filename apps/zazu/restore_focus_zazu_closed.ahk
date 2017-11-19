; !A:: ; <-- use the alt-a key to grab the active window's instance ID
; WinGet, WinID, ID, A
; MyWin = ahk_id %WinID%
; MsgBox, %MyWin%
; Return

zazu:
ZazuDetails = ahk_exe Zazu.exe
IfWinActive, %ZazuDetails%
{
	WinWaitClose, %ZazuDetails%
	Send, {AltDown}{Tab}{AltUp}
}
Goto, zazu