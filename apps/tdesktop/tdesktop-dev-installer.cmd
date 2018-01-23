@ECHO OFF

set TD_ROOT_DIR=

IF "%1"=="/?" goto usage
IF [%1]==[] (
	@echo Enter the root path for Telegram Desktop dev folder:
	@echo For example, C:\TBuild
	set /p TD_ROOT_DIR=
) ELSE (
	set TD_ROOT_DIR=%1
)

IF "%TD_ROOT_DIR%"=="" (
	@echo.
	@echo ERROR: You need to enter a path for Telegram Desktop BuildPath
	@echo.
	goto usage
)

@echo Using %TD_ROOT_DIR% as the Telegram Desktop BuildPath
@echo.
mkdir %TD_ROOT_DIR%\Libraries 2> NUL
mkdir %TD_ROOT_DIR%\ThirdParty 2> NUL

IF ERRORLEVEL 1 (
	@echo The path "%TD_ROOT_DIR%" is not empty
	goto script-end
)

set LIBS=%TD_ROOT_DIR%\Libraries
set THIRD_PARTY=%TD_ROOT_DIR%\ThirdParty

pushd %THIRD_PARTY%

@rem goto download-installation-files

:get-download-links
@rem perl
curl --silent https://www.activestate.com/activeperl/downloads 2>&1 | grep -m1 -oP "(http://downloads.*?MSWin32-x64.*?\.exe)"  | head --lines=1 > tmpfile
set /p downlink= < tmpfile
echo %downlink% > installation-links.txt

@rem nasm
curl --silent http://www.nasm.us/pub/nasm/releasebuilds/?C=M;O=D;F=0 2>&1 | grep -m1 -oP "((?:\d+\.?){3}/)" | head --lines=1 > tmpfile
set /p downlink= < tmpfile
set downlink=%downlink:~0,-1%
set downlink=http://www.nasm.us/pub/nasm/releasebuilds/%downlink%/win64/nasm-%downlink%-win64.zip
echo %downlink% >> installation-links.txt

@rem yasm
curl --silent http://yasm.tortall.net/Download.html 2>&1 | grep -m1 -oP "http(.*win64\.exe)" | head --lines=1 > tmpfile
set /p downlink= < tmpfile
echo %downlink% >> installation-links.txt

@rem msys2
curl --silent http://www.msys2.org/ 2>&1 | grep -m1 -oP "http.*msys2-x86_64.*\.exe. " | head --lines=1 > tmpfile
set /p downlink= < tmpfile
set downlink=%downlink:~0,-2%
echo %downlink% >> installation-links.txt

@rem jom
set downlink=http://download.qt.io/official_releases/jom/jom.zip
echo %downlink% >> installation-links.txt

@rem python 2.7
curl --silent https://www.python.org/downloads/ 2>&1 | grep -oP "https.*python/2.*\.msi" | head --lines=1 > tmpfile
set /p downlink= < tmpfile
echo %downlink% >> installation-links.txt

@rem cmake
curl --silent https://cmake.org/download/ 2>&1 | grep -m1 -oP "/files/.*/cmake.*win64.*\.zip.>" | head --lines=1 > tmpfile
set /p downlink= < tmpfile
set downlink=%downlink:~0,-2%
set downlink=https://cmake.org%downlink%
echo %downlink% >> installation-links.txt

@rem ninja
set downlink=https://github.com/ninja-build/ninja/releases/download/v1.7.2/ninja-win.zip
echo %downlink% >> installation-links.txt

set downlink=

:download-installation-files
@echo == Downloading third party installation files: ==

for /F "tokens=*" %%l in (installation-links.txt) do (
	IF NOT "%%l" == "" (
		@echo %%l
		curl -L -O --progress-bar %%l
		@echo.
	)
)

@rem end
del tmpfile

@echo Done!
@echo.

pause
goto script-end


:usage
@echo Usage: tdesktop-dev-installer.bat ^<tdesktop-buildpath^>
exit /b 1

:script-end
popd