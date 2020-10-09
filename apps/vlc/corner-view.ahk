if (%0%=0) {
	Run, vlc.exe --no-video-deco --qt-minimal-view --video-on-top --autoscale --no-qt-video-autoresize "%clipboard%"
} else {
	Run, vlc.exe --no-video-deco --qt-minimal-view --video-on-top --autoscale --no-qt-video-autoresize "%1%"
}

WinWait VLC media player
WinActivate
WinMove A,, 1300, 20, A_ScreenWidth-1300, A_ScreenHeight-700
Exit