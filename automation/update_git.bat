@echo off
setlocal
:: Update SVN tree
:: Parameters:
:: 1. svn_dir - string: location of the SVN trunk local copy

if "%~1"=="" (
	echo %0: Too few parameters 1>&2
	exit /b 1
)

set repo_dir=%1

cd %repo_dir%
git clean -f -d
git pull

:: --non-interactive
