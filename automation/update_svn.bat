@echo off
setlocal
:: Update SVN tree
:: Parameters:
:: 1. svn_dir - string: location of the SVN trunk local copy

if "%~1"=="" (
	echo %0: Too few parameters 1>&2
	exit /b 1
)

set svn_dir=%1

svn --trust-server-cert --non-interactive --quiet update %svn_dir%

:: --non-interactive
