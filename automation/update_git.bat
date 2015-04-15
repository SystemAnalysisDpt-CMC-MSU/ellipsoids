@echo off
setlocal
:: Update GIT repository
:: Parameters:
:: 1. git_dir - string: location of the SVN trunk local copy

if "%~1"=="" (
	echo %0: Too few parameters 1>&2
	exit /b 1
)

set repo_dir=%1

cd %repo_dir%
@echo off
for /f %%i in ('git rev-parse --abbrev-ref --symbolic-full-name @{u}') do set remote_branch_name=%%i
@echo on
git fetch
git reset --hard %remote_branch_name%