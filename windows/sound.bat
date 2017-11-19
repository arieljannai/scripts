@echo off
rem 65536 is 100%
rem device where zero is the default device
rem left and right
rem reference: http://nircmd.nirsoft.net/setvolume.html or http://nircmd.nirsoft.net/setsysvolume.html
rem supports whole numbers only therefore throws "missing operator" error when specifying 655.36

IF [%1]==[] goto usage
IF "%1"=="/?" goto usage

set /a volume=%1 * 655

IF %1==on (
	nircmd mutesysvolume 0
	echo sound on
) ELSE IF %1==off (
	nircmd mutesysvolume 1
	echo sound muted
) ELSE (
	nircmd setvolume 0 %volume% %volume%
	rem nircmd setsysvolume %volume%
	echo volume: %1
)

goto :eof

:usage
@echo Usage: sound ^<on^|off^|0-100^>
exit /b 1
