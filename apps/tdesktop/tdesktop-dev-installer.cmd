@ECHO OFF
@ECHO.
setlocal EnableDelayedExpansion
set bad=false

:: Verify needed commands exist
where git >nul 2>&1
IF %errorlevel% NEQ 0 (
	@echo **git** was not found.
	set bad=true
) ELSE (
	where head >nul 2>&1
	IF !errorlevel! NEQ 0 @echo **head** was not found. Usually found at YOUR_GIT_INSTALL_PATH/usr/bin
	where tail >nul 2>&1
	IF !errorlevel! NEQ 0 @echo **tail** was not found. Usually found at YOUR_GIT_INSTALL_PATH/usr/bin
	where grep >nul 2>&1
	IF !errorlevel! NEQ 0 @echo **grep** was not found. Usually found at YOUR_GIT_INSTALL_PATH/usr/bin
	IF !errorlevel! NEQ 0 (
		set bad=true
		@echo.
		@echo Hint: You can add YOUR_GIT_INSTALL_PATH/usr/bin to the path
		@echo fix it and try again.
	)
)

where curl >nul 2>&1
IF %errorlevel% NEQ 0 (
	@echo **curl** was not found. When installing, verify that https addresses can be fetched.
	set bad=true
) ELSE (
	curl https://google.com 2>&1 | grep -o "(60) SSL certificate problem" >nul 2>&1
	IF !errorlevel! == 0 (
		set bad=true
		@echo There's a problem with curl getting https addresses. Please fix that^^!
		@echo curl: ^(60^) SSL certificate problem: unable to get local issuer certificate
		@echo More details here: https://curl.haxx.se/docs/sslcerts.html
	)
)
where 7z >nul 2>&1
IF %errorlevel% NEQ 0 (
	set bad=true
	@echo **7z** was not found.
)

IF NOT EXIST "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat" (
	set bad=true
	@echo **"C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"** was not found.
)

IF "%bad%" == "false" (
	rem call :check-admin
	IF !errorlevel! NEQ 0 @echo. && @echo. && goto usage
	@echo All the dependencies are met.
	@echo You can start the script^^!
	@echo.
	pause
) ELSE (
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
	@echo Some things are missing, that's the time to fix it^^!
	@echo.
	goto :eof
)

IF EXIST "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat" (
	set VS_DEV_INIT_BATCH="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat
) ELSE (
	@echo VsDevCmd.bat was not found in its usual location.
	@echo Expected to find **VsDevCmd.bat** at:
	@echo "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\" 
	@echo Please enter the correct location:
	set /p VS_DEV_INIT_BATCH=
)

where RefreshEnv.cmd >nul 2>&1
IF %errorlevel% NEQ 0 (
	curl --silent -L -O https://raw.githubusercontent.com/chocolatey/choco/fdfcd06/src/chocolatey.resources/redirects/RefreshEnv.cmd
)

goto :eof
:: remove this line ^^^ to activate

:: All good, start the actual script.
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
call :update-path
RefreshEnv.cmd
call :verify-third-party-folders
call :remove-uneeded-files
goto script-end


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

:: ### THIRD PARTY INSTALL FUNCTIONS ###
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
>NUL rename %tmp:~0,-10% NASM
exit /b

:install-ninja
@echo Installing ninja
>NUL 7z x -y -oNinja %1
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

:: ### ADD RELEVANT THIRD PARTY TO PATH ###
:update-path
cmd
RefreshEnv.cmd
setx /M PATH "%PATH%;%THIRD_PARTY%\gyp;%THIRD_PARTY%\Ninja;
exit /b
:: ### END OF ADD RELEVANT THIRD PARTY TO PATH ###

:: ### VERIFY THIRD PARTY FOLDERS EXIST ###
:verify-third-party-folders
IF NOT EXIST "%THIRD_PARTY%\Perl" call :notify-missing-third-party-folder "%THIRD_PARTY%\Perl"
IF NOT EXIST "%THIRD_PARTY%\NASM" call :notify-missing-third-party-folder "%THIRD_PARTY%\Perl"
IF NOT EXIST "%THIRD_PARTY%\yasm" call :notify-missing-third-party-folder "%THIRD_PARTY%\Perl"
IF NOT EXIST "%THIRD_PARTY%\msys64" call :notify-missing-third-party-folder "%THIRD_PARTY%\Perl"
IF NOT EXIST "%THIRD_PARTY%\jom" call :notify-missing-third-party-folder "%THIRD_PARTY%\Perl"
IF NOT EXIST "%THIRD_PARTY%\Python27" call :notify-missing-third-party-folder "%THIRD_PARTY%\Perl"
IF NOT EXIST "%THIRD_PARTY%\cmake" call :notify-missing-third-party-folder "%THIRD_PARTY%\Perl"
IF NOT EXIST "%THIRD_PARTY%\Ninja" call :notify-missing-third-party-folder "%THIRD_PARTY%\Perl"
:: ### END OF VERIFY THIRD PARTY FOLDERS EXIST ###

:: ### THIRD PARTY FOLDER IS MISSING ###
:notify-missing-third-party-folder
@echo The folder %~1 is missing. Keeping all installation files - please fix it manually. Not continuing to install Libraries.
exit /b
:: ### END OF THIRD PARTY FOLDER IS MISSING ###

:: ### USAGE ###
:usage
@echo Usage: tdesktop-dev-installer.bat ^<tdesktop-buildpath^>
@echo Note: Remember to run the script with elevated permissions.
exit /b 1
:: ### END OF USAGE ###

:script-end
@echo Done^^!
@echo.
popd
pause
goto :eof
