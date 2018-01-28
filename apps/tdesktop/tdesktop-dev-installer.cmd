@ECHO OFF

setlocal EnableDelayedExpansion

:: Verify needed commands exist
where git >nul 2>&1
IF %errorlevel% NEQ 0 (
	@echo **git** was not found.
) ELSE (
	where head >nul 2>&1
	IF %errorlevel% NEQ 0 @echo **head** was not found. Usually found at git/usr/bin
	where tail >nul 2>&1
	IF %errorlevel% NEQ 0 @echo **tail** was not found. Usually found at git/usr/bin
	where grep >nul 2>&1
	IF %errorlevel% NEQ 0 @echo **grep** was not found. Usually found at git/usr/bin
)
where curl >nul 2>&1
IF %errorlevel% NEQ 0 @echo **curl** was not found.
where 7z >nul 2>&1
IF %errorlevel% NEQ 0 @echo **7z** was not found.

IF EXIST "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat" (
	set VS_DEV_INIT_BATCH="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"
) ELSE (
	@echo VsDevCmd.bat was not found in its usual location.
	@echo Expected to find **VsDevCmd.bat** at:
	@echo "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\" 
	@echo Please enter the correct location:
	set /p VS_DEV_INIT_BATCH=
)

@echo.
@echo If you had any problems or missing programs, 
@echo you can install them with chocolatey.
@echo For example, for installing all dependencies, run:
@echo.
@echo     **  cinst -y visualstudio2017community git curl 7zip  **
@echo.
@echo To install chocolatey, visit: https://chocolatey.org/install#installing-chocolatey
@echo.
@echo.
@echo If something is missing, that's the time.
@echo Abort the script with Ctrl-C, confirm, and go install everything.
@echo.
@echo.
@echo If all the dependencies are met, you can start the script^^!
@echo.
pause


call :check-admin
goto :eof
:: remove this line ^^^ to activate

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

:: TODO: Check if curl, grep, head, tail, 7z exist and if not --> download them

call :get-download-links
call :download-installation-files
call :script-start

goto script-end

:script-end
@echo Done^^!
@echo.
popd
pause
goto :eof


:: ### MAIN ###
:script-start
pushd %THIRD_PARTY%
for %%a in (*.*) do (
	set tmp=%%a
	set strt=!tmp:~0,3!
	IF "!strt!"=="Act" (
		call :install-perl !tmp!
	) ELSE IF "!strt!"=="cma" (
		call :install-cmake !tmp!
	) ELSE IF "!strt!"=="jom" (
		call :install-jom !tmp!
	) ELSE IF "!strt!"=="msy" (
		call :install-msys2 !tmp!
	) ELSE IF "!strt!"=="nas" (
		call :install-nasm !tmp!
	) ELSE IF "!strt!"=="nin" (
		call :install-ninja !tmp!
	) ELSE IF "!strt!"=="pyt" (
		call :install-python27 !tmp!
	) ELSE IF "!strt!"=="yas" (
		call :install-yasm !tmp!
	)
)
call :install-gyp
exit /b
:: ### END OF MAIN ###


:: ### GET DOWLOAD LINKS ###
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
curl --silent http://repo.msys2.org/distrib/x86_64/ 2>&1 | grep -oP "msys2.*?tar\.xz" | tail --lines=1 > tmpfile
set /p downlink= < tmpfile
set downlink=http://repo.msys2.org/distrib/x86_64/%downlink%
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

del tmpfile
set downlink=
exit /b
:: ### END OF GET DOWLOAD LINKS ###


:: ### DOWNLOAD INSTALLATION FILES ###
:download-installation-files
@echo == Downloading third party installation files: ==

for /F "tokens=*" %%l in (installation-links.txt) do (
	IF NOT "%%l" == "" (
		@echo %%l
		curl -L -O --progress-bar %%l
		@echo.
	)
)

:get-files-for-removal
for %a in (*) do @echo %a >> removal.txt

exit /b
:: ### END OF DOWNLOAD INSTALLATION FILES ###


:: ### REMOVE UNEEDED FILES ###
:remove-uneeded-files
pushd %THIRD_PARTY%
for /f %%f in ('dir /b . /A-D') do del /Q %%f
popd
exit /b
:: ### END OF REMOVE UNEEDED FILES ###


:: ### USAGE ###
:usage
@echo Usage: tdesktop-dev-installer.bat ^<tdesktop-buildpath^>
exit /b 1
:: ### END OF USAGE ###


:: ### THIRD PARTY INSTALL FUNCTIONS ###
:third-party-installations
:install-perl
@echo Installing perl
%1 /qb APPDIR="%THIRD_PARTY%\Perl"
exit /b

:install-cmake
@echo Installing cmake
>NUL 7z x -y %1
set tmp=%1
>NUL rename %tmp:~0,-4% cmake
exit /b

:install-jom
@echo Installing jom
>NUL 7z x -y -ojom %1
exit /b

:install-msys2
@echo Installing msys2
7z x %1 -so | 7z x -si -ttar
msys64\msys2_shell.cmd -c exit | head
msys64\msys2_shell.cmd -lc 'pacman --noconfirm -Syuu' | head
msys64\msys2_shell.cmd -lc 'pacman --noconfirm -Syuu' | head
msys64\msys2_shell.cmd -lc 'pacman --noconfirm -Syuu' | head
msys64\msys2_shell.cmd -lc 'pacman --noconfirm -Syuu' | head
msys64\msys2_shell.cmd -lc 'pacman --noconfirm -Syuu' | head
exit /b

:install-nasm
@echo Installing nasm
>NUL 7z x -y %1
set tmp=%1
>NUL rename %tmp:~0,-10% nasm
exit /b

:install-ninja
@echo Installing ninja
>NUL 7z x -y -oninja %1
exit /b

:install-python27
@echo Installing python27
%1 /qb TARGETDIR="%THIRD_PARTY%\Python27"
exit /b

:install-yasm
@echo Installing yasm
>NUL mkdir yasm
>NUL copy %1 yasm.exe
>NUL move yasm.exe yasm/yasm.exe
exit /b

:install-gyp
@echo installing gyp
git clone https://chromium.googlesource.com/external/gyp
git -C gyp checkout a478c1ab51
exit /b
:: ### END OF THIRD PARTY INSTALL FUNCTIONS ###


:: ### EXTRA FUNCTIONS ###
:check-admin
net session >nul 2>&1
if not %errorlevel% == 0 (
	echo No administration rights were detected.
	echo Please start the script in an elevated command line.
)
exit /b
:: ### END OF EXTRA FUNCTIONS ###