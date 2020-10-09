@echo off

set linkDir="%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"
set link=%~n1
set suffix=%~x1
set target="%~dp1%link%%suffix%"

pushd %linkDir%
mklink %link% %target%
popd
