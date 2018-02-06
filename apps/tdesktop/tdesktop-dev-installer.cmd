@ECHO OFF
@ECHO.
setlocal EnableDelayedExpansion
set bad=false

IF "%1"=="/?" goto usage

set TD_ROOT_DIR=C:\TBuild
set VS_DEV_CMD_REL_PATH=Common7\Tools\VsDevCmd.bat
set VS_2017_LOCATION=C:\Program Files (x86)\Microsoft Visual Studio\2017
set VS_2017_INSTANCE_NAME=Community
set QT_VSIX=https://theqtcompany.gallerycdn.vsassets.io/extensions/theqtcompany/qtvisualstudiotools-19123/2.1.2/1501755913304/273958/1/qt-vsaddin-msvc2017-2.1.2-beta-03.08.2017.vsix

REM Verify needed commands exist
where git >nul 2>&1
IF %errorlevel% NEQ 0 (
	@echo **git** was not found.
	set bad=true
) ELSE (
	where git > tmpfile
	set /p git_install_dir= < tmpfile
	set git_install_dir=!git_install_dir:~0,-12!
	
	where head >nul 2>&1
	IF !errorlevel! NEQ 0 set "path=!git_install_dir!\usr\bin;%PATH%"
	
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

set /p "VS_2017_LOCATION=Enter the location of VS installation (without specific version) or press [ENTER] for default [%VS_2017_LOCATION%]: "
set /p "VS_2017_INSTANCE_NAME=Enter the relevant instance name or press [ENTER] for default [%VS_2017_INSTANCE_NAME%]: "
set VS_DEV_INIT_BATCH=%VS_2017_LOCATION%\%VS_2017_INSTANCE_NAME%\%VS_DEV_CMD_REL_PATH%

IF NOT EXIST "%VS_DEV_INIT_BATCH%" (
	set bad=true
	@echo MISSING: VsDevCmd.bat was not found in its usual location.
	@echo Expected to find **VsDevCmd.bat** at:
	@echo "%VS_2017_LOCATION%\%VS_2017_INSTANCE_NAME%\%VS_DEV_CMD_REL_PATH%"
	@echo.
	@echo Something went wrong.
	@echo Please verify all inputed detailes and dependencies and try again.
	@echo.
)

IF NOT EXIST "%VS_2017_LOCATION%\%VS_2017_INSTANCE_NAME%\Common7\IDE\VC\VCTargets\Microsoft.Cpp.Default.props" (
	set bad=true
	@echo MISSING: Microsoft.Cpp.Default.props; Please install the visual studio feature "Windows 8.1 SDK and UCRT SDK"
	@echo.
)

IF NOT EXIST "C:\Program Files (x86)\Windows Kits\10\Include\10.0.15063.0" (
	set bad=true
	@echo MISSING: Please install the visual studio feature "Windows 10 SDK (10.0.15063.0) for Desktop C++ [x86 and x64]"
	@echo.
)

IF "%bad%" == "false" (
	call :check-admin
	IF !errorlevel! NEQ 0 @echo. && @echo. && goto usage
	@echo All the dependencies are met.
	@echo You can start the script^^!
	@echo.
	pause
	@echo.
) ELSE (
	@echo.
	@echo If you had any problems or missing programs, 
	@echo you can install them with chocolatey.
	@echo For example, for installing all dependencies, run:
	@echo.
	@echo     **  cinst -y windows-sdk-8.1 windows-sdk-10.1 visualstudio2017community git curl 7zip  **
	@echo     **  cinst -y visualstudio2017-workload-nativedesktop --package-parameters "--add includeRecommended;Microsoft.VisualStudio.Workload.NativeDesktop;Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Win81;Microsoft.VisualStudio.Component.Windows10SDK.15063.Desktop" **
	@echo.
	@echo To install chocolatey, visit: https://chocolatey.org/install#installing-chocolatey
	@echo.
	@echo.
	@echo Some things are missing, that's the time to fix it^^!
	@echo.
	goto :eof
)

where RefreshEnv.cmd >nul 2>&1
IF %errorlevel% NEQ 0 (
	curl --silent -L -O https://raw.githubusercontent.com/chocolatey/choco/fdfcd06/src/chocolatey.resources/redirects/RefreshEnv.cmd
)






REM All good, start the actual script.

IF [%1]==[] (
	set /p "TD_ROOT_DIR=Enter the root path for Telegram Desktop dev folder or press [ENTER] for default [%TD_ROOT_DIR%]: "
	
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

rem IF ERRORLEVEL 1 (
rem 	@echo The path "%TD_ROOT_DIR%" is not empty
rem 	goto script-end
rem )

set LIBS=%TD_ROOT_DIR%\Libraries
set THIRD_PARTY=%TD_ROOT_DIR%\ThirdParty






pushd %THIRD_PARTY%
call :install-all-dependencies
call :install-third-party
call :install-libraries
call :build-tdesktop
call :install-qt-vs-extension
popd
goto script-end

REM ### INSTALL THIRD PARTY ###
:install-third-party
	call :get-download-links
	call :download-installation-files
	call :install-all-third-party-folders
	call :update-path
	call :remove-sys-path-duplicates
	call RefreshEnv.cmd
	call :verify-third-party-folders
	call :remove-uneeded-files
exit /b
REM ### END OF INSTALL THIRD PARTY ###

REM ### MAIN ###
:install-all-third-party-folders
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
REM ### END OF MAIN ###


REM ### GET DOWLOAD LINKS ###
:get-download-links
	@REM perl
	curl --silent https://www.activestate.com/activeperl/downloads 2>&1 | grep -m1 -oP "(http://downloads.*?MSWin32-x64.*?\.exe)"  | head --lines=1 > tmpfile
	set /p downlink= < tmpfile
	echo %downlink% > installation-links.txt

	@REM nasm
	curl --silent http://www.nasm.us/pub/nasm/releasebuilds/?C=M;O=D;F=0 2>&1 | grep -m1 -oP "((?:\d+\.?){3}/)" | head --lines=1 > tmpfile
	set /p downlink= < tmpfile
	set downlink=%downlink:~0,-1%
	set downlink=http://www.nasm.us/pub/nasm/releasebuilds/%downlink%/win64/nasm-%downlink%-win64.zip
	echo %downlink% >> installation-links.txt

	@REM yasm
	curl --silent http://yasm.tortall.net/Download.html 2>&1 | grep -m1 -oP "http(.*win64\.exe)" | head --lines=1 > tmpfile
	set /p downlink= < tmpfile
	echo %downlink% >> installation-links.txt

	@REM msys2
	curl --silent http://repo.msys2.org/distrib/x86_64/ 2>&1 | grep -oP "msys2.*?tar\.xz" | tail --lines=1 > tmpfile
	set /p downlink= < tmpfile
	set downlink=http://repo.msys2.org/distrib/x86_64/%downlink%
	echo %downlink% >> installation-links.txt

	@REM jom
	set downlink=http://download.qt.io/official_releases/jom/jom.zip
	echo %downlink% >> installation-links.txt

	@REM python 2.7
	curl --silent https://www.python.org/downloads/ 2>&1 | grep -oP "https.*python/2.*\.msi" | head --lines=1 > tmpfile
	set /p downlink= < tmpfile
	echo %downlink% >> installation-links.txt

	@REM cmake
	curl --silent https://cmake.org/download/ 2>&1 | grep -m1 -oP "/files/.*/cmake.*win64.*\.zip.>" | head --lines=1 > tmpfile
	set /p downlink= < tmpfile
	set downlink=%downlink:~0,-2%
	set downlink=https://cmake.org%downlink%
	echo %downlink% >> installation-links.txt

	@REM ninja
	set downlink=https://github.com/ninja-build/ninja/releases/download/v1.7.2/ninja-win.zip
	echo|set /p=%downlink% >> installation-links.txt

	del tmpfile
	set downlink=
exit /b
REM ### END OF GET DOWLOAD LINKS ###


REM ### DOWNLOAD INSTALLATION FILES ###
:download-installation-files
	@echo == Downloading third party installation files: ==
	for /F "tokens=*" %%a in (installation-links.txt) do call :download-http-file %%a
exit /b

rem :get-files-for-removal
rem for %a in (*) do @echo %a >> removal.txt
rem 
rem exit /b
REM ### END OF DOWNLOAD INSTALLATION FILES ###


REM ### DOWNLOAD HTTP FILE ###
:download-http-file
	@echo %~1
	set dlURL=%~1
	for %%x in (%~1) do set currFileName=%%~nxx
	curl -L -O --progress-bar %~1
	7z t %currFileName% 2>&1 | grep ERROR >nul
	IF !errorlevel! == 0 (
		@echo Download %currFileName% failed. Trying one more time.
		curl -L -O --progress-bar !dlURL!
		7z t %currFileName% 2>&1 | grep ERROR >nul
		IF !errorlevel! == 0 (
			@echo Download failed again. Please manually download !dlURL!
			@echo And install it according to the relevant instructions at:
			@echo https://github.com/telegramdesktop/tdesktop/blob/dev/docs/building-msvc.md
			goto :eof
		)
	)
exit /b
REM ### END OF DOWNLOAD HTTP FILE ###


REM ### REMOVE UNEEDED FILES ###
:remove-uneeded-files
	pushd %THIRD_PARTY%
	@echo|set /p dummy=Searching for files to clean.. 
	for /f "tokens=*" %%f in ('dir /b . /A-D') do del /Q "%%f"
	popd
exit /b
REM ### END OF REMOVE UNEEDED FILES ###


REM ### THIRD PARTY INSTALL FUNCTIONS ###
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
REM ### END OF THIRD PARTY INSTALL FUNCTIONS ###


REM ### EXTRA FUNCTIONS ###
:check-admin
	net session >nul 2>&1
	if not %errorlevel% == 0 (
		echo No administration rights were detected.
		echo Please start the script in an elevated command line.
	)
exit /b
REM ### END OF EXTRA FUNCTIONS ###


REM ### ADD RELEVANT THIRD PARTY TO PATH ###
:update-path
	cmd /c "RefreshEnv.cmd && setx /M PATH "%PATH%;%THIRD_PARTY%\gyp;%THIRD_PARTY%\Ninja;""
	set path=%PATH%;%THIRD_PARTY%\gyp;%THIRD_PARTY%\Ninja;
exit /b
REM ### END OF ADD RELEVANT THIRD PARTY TO PATH ###


REM ### VERIFY THIRD PARTY FOLDERS EXIST ###
:verify-third-party-folders
	IF NOT EXIST "%THIRD_PARTY%\Perl" call :notify-missing-third-party-folder "%THIRD_PARTY%\Perl"
	IF NOT EXIST "%THIRD_PARTY%\NASM" call :notify-missing-third-party-folder "%THIRD_PARTY%\NASM"
	IF NOT EXIST "%THIRD_PARTY%\yasm" call :notify-missing-third-party-folder "%THIRD_PARTY%\yasm"
	IF NOT EXIST "%THIRD_PARTY%\msys64" call :notify-missing-third-party-folder "%THIRD_PARTY%\msys64"
	IF NOT EXIST "%THIRD_PARTY%\jom" call :notify-missing-third-party-folder "%THIRD_PARTY%\jom"
	IF NOT EXIST "%THIRD_PARTY%\Python27" call :notify-missing-third-party-folder "%THIRD_PARTY%\Python27"
	IF NOT EXIST "%THIRD_PARTY%\cmake" call :notify-missing-third-party-folder "%THIRD_PARTY%\cmake"
	IF NOT EXIST "%THIRD_PARTY%\Ninja" call :notify-missing-third-party-folder "%THIRD_PARTY%\Ninja"
	IF NOT EXIST "%THIRD_PARTY%\gyp" call :notify-missing-third-party-folder "%THIRD_PARTY%\gyp"
exit /b
REM ### END OF VERIFY THIRD PARTY FOLDERS EXIST ###


REM ### THIRD PARTY FOLDER IS MISSING ###
:notify-missing-third-party-folder
	@echo The folder %~1 is missing. Please fix it manually. Not continuing to install Libraries.
exit /b
REM ### END OF THIRD PARTY FOLDER IS MISSING ###


REM ### REMOVE PATH DUPLICATES ###
:remove-sys-path-duplicates
	powershell -Command "RefreshEnv.cmd; $rg='HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Environment'; $np = $($p=(Get-ItemProperty $rg Path).Path; $d=';'; ( $p -split $d | select -Unique ) -join $d); Set-ItemProperty -Path "$rg" -Name PATH -Value $np"
exit /b
REM ### REMOVE PATH DUPLICATES ###


REM ### GETTING LIBRARIES ###
:install-libraries
	pushd %TD_ROOT_DIR%
	call %VS_DEV_INIT_BATCH%

	REM ### SECTION COPIED FROM https://github.com/telegramdesktop/tdesktop/blob/dev/docs/building-msvc.md ###
	SET PATH=%cd%\ThirdParty\Perl\bin;%cd%\ThirdParty\Python27;%cd%\ThirdParty\NASM;%cd%\ThirdParty\jom;%cd%\ThirdParty\cmake\bin;%cd%\ThirdParty\yasm;%PATH%

	git clone --recursive https://github.com/telegramdesktop/tdesktop.git

	mkdir Libraries
	cd Libraries

	git clone https://github.com/Microsoft/Range-V3-VS2015 range-v3

	git clone https://github.com/telegramdesktop/lzma.git
	cd lzma\C\Util\LzmaLib
	msbuild LzmaLib.sln /property:Configuration=Debug
	msbuild LzmaLib.sln /property:Configuration=Release
	cd ..\..\..\..

	git clone https://github.com/openssl/openssl.git
	cd openssl
	git checkout OpenSSL_1_0_1-stable
	perl Configure no-shared --prefix=%cd%\Release --openssldir=%cd%\Release VC-WIN32
	ms\do_ms
	nmake -f ms\nt.mak
	nmake -f ms\nt.mak install
	xcopy tmp32\lib.pdb Release\lib\
	nmake -f ms\nt.mak clean
	perl Configure no-shared --prefix=%cd%\Debug --openssldir=%cd%\Debug debug-VC-WIN32
	ms\do_ms
	nmake -f ms\nt.mak
	nmake -f ms\nt.mak install
	xcopy tmp32.dbg\lib.pdb Debug\lib\
	cd ..

	git clone https://github.com/telegramdesktop/zlib.git
	cd zlib
	git checkout tdesktop
	cd contrib\vstudio\vc14
	msbuild zlibstat.vcxproj /property:Configuration=Debug
	msbuild zlibstat.vcxproj /property:Configuration=ReleaseWithoutAsm
	cd ..\..\..\..

	git clone git://repo.or.cz/openal-soft.git
	cd openal-soft
	git checkout 18bb46163af
	cd build
	cmake -G "Visual Studio 15 2017" -D LIBTYPE:STRING=STATIC -D FORCE_STATIC_VCRT:STRING=ON ..
	msbuild OpenAL32.vcxproj /property:Configuration=Debug
	msbuild OpenAL32.vcxproj /property:Configuration=Release
	cd ..\..

	git clone https://github.com/google/breakpad
	cd breakpad
	git checkout a1dbcdcb43
	git apply ../../tdesktop/Telegram/Patches/breakpad.diff
	cd src
	git clone https://github.com/google/googletest testing
	cd client\windows
	set GYP_MSVS_VERSION=2017
	gyp --no-circular-check breakpad_client.gyp --format=ninja
	cd ..\..
	ninja -C out/Debug common crash_generation_client exception_handler
	ninja -C out/Release common crash_generation_client exception_handler
	cd ..\..

	git clone https://github.com/telegramdesktop/opus.git
	cd opus
	git checkout tdesktop
	cd win32\VS2015
	msbuild opus.sln /property:Configuration=Debug /property:Platform="Win32"
	msbuild opus.sln /property:Configuration=Release /property:Platform="Win32"

	cd ..\..\..\..
	SET PATH_BACKUP_=%PATH%
	SET PATH=%cd%\ThirdParty\msys64\usr\bin;%PATH%
	cd Libraries

	git clone https://github.com/FFmpeg/FFmpeg.git ffmpeg
	cd ffmpeg
	git checkout release/3.4

	set CHERE_INVOKING=enabled_from_arguments
	set MSYS2_PATH_TYPE=inherit
	bash --login ../../tdesktop/Telegram/Patches/build_ffmpeg_win.sh

	SET PATH=%PATH_BACKUP_%
	cd ..

	git clone git://code.qt.io/qt/qt5.git qt5_6_2
	cd qt5_6_2
	perl init-repository --module-subset=qtbase,qtimageformats
	git checkout v5.6.2
	cd qtimageformats
	git checkout v5.6.2
	cd ..\qtbase
	git checkout v5.6.2
	git apply ../../../tdesktop/Telegram/Patches/qtbase_5_6_2.diff
	cd ..

	configure -debug-and-release -force-debug-info -opensource -confirm-license -static -I "%cd%\..\openssl\Release\include" -no-opengl -openssl-linked OPENSSL_LIBS_DEBUG="%cd%\..\openssl\Debug\lib\ssleay32.lib %cd%\..\openssl\Debug\lib\libeay32.lib" OPENSSL_LIBS_RELEASE="%cd%\..\openssl\Release\lib\ssleay32.lib %cd%\..\openssl\Release\lib\libeay32.lib" -mp -nomake examples -nomake tests -platform win32-msvc2015

	jom -j4
	jom -j4 install
	cd ..

	cd ../tdesktop/Telegram
	gyp\refresh.bat

	REM ### END OF COPIED SECTION ###
	popd
exit /b
REM ### END OF GETTING LIBRARIES ###


REM ### BUILD TDESKTOP ###
:build-tdesktop
	pushd %TD_ROOT_DIR%\tdesktop\Telegram
	msbuild Telegram.sln /property:Configuration=Debug
	msbuild Telegram.sln /property:Configuration=Release
	popd
exit /b
REM ### END OF BUILD TDESKTOP ###


REM ### INSTALL QT VS EXTENSION ###
:install-qt-vs-extension
	REM qt visual studio tools page: https://marketplace.visualstudio.com/items?itemName=TheQtCompany.QtVisualStudioTools-19123
	set B_INSTALL_QT_VS_EXT=YES
	set /p "B_INSTALL_QT_VS_EXT=Install Qt Visual Studio Tools? press [ENTER] for default [%B_INSTALL_QT_VS_EXT%]: "
	for %%x in (%QT_VSIX%) do set currFileName=%%~nxx
	IF /I "%B_INSTALL_QT_VS_EXT%"=="YES" (
		@echo Downloading %currFileName%
		curl -L -O --progress-bar "%QT_VSIX%" 2>&1
		IF !errorlevel! NEQ 0 @echo ERROR: Could not download the Qt extension vsix from "%QT_VSIX%" && goto :eof
		set VSIX_INSTALLER="%VS_2017_LOCATION%\%VS_2017_INSTANCE_NAME%\Common7\IDE\VSIXInstaller.exe"
		@echo Installing Qt Visual Studio Tools..
		start /B /wait "Installing Qt Visual Studio Tools.." cmd /c "!VSIX_INSTALLER! /quiet %currFileName%"
		del %currFileName%
	)
exit /b
REM ### END OF INSTALL QT VS EXTENSION ###


REM ### USAGE ###
:usage
	@echo Usage: tdesktop-dev-installer.bat ^<tdesktop-buildpath^>
	@echo Note: Remember to run the script with elevated permissions.
	@echo.
	@echo.
	@echo Dependencies:
	@echo  * git
	@echo  * grep
	@echo  * head
	@echo  * tail
	@echo  * curl
	@echo  * 7z
	@echo  * Visual Studio 2017
	@echo      ** VS 2017 Features:
	@echo          *# Windows development with C++ 
	@echo          *# Windows development with C++ : Windows 8.1 SDK and UCRT SDK
	@echo          *# Windows development with C++ : Windows 10 SDK (10.0.15063.0) for Desktop C++ [x86 and x64]
	@echo.
	@echo To install all dependencies with chocolatey, you can run:
	@echo.
	@echo     *#  cinst -y windows-sdk-8.1 windows-sdk-10.1 visualstudio2017community git curl 7zip
	@echo     *#  cinst -y visualstudio2017-workload-nativedesktop --package-parameters "--add includeRecommended;Microsoft.VisualStudio.Workload.NativeDesktop;Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Win81;Microsoft.VisualStudio.Component.Windows10SDK.15063.Desktop"
	@echo.
	@echo To install chocolatey, visit: https://chocolatey.org/install#installing-chocolatey
	@echo.
exit /b 1
REM ### END OF USAGE ###


:script-end
@echo.
@echo Done^^!
@echo.
pause
goto :eof
