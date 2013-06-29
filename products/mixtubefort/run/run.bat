@echo off

if "%1" == "" (
	cmd
	goto :eof
)

set example=%1
set exe_dir="..\source\build"

if "%example%" == "tests" (
	%exe_dir%\test_all.exe
	goto :eof
)

set config=%2

set exe="%exe_dir%\%example%.exe"

goto config_%config%

:config_all

:config_1
	set d="springs_1"
	if not exist %d% mkdir %d%
	%exe% --prefix "%d%/" --n  2 --tolerance 1D-7 --t 0.4 --nu 1 --nv 1 --nl 4 --nt 100 --rp 1 --rq 0.1 --rm 1 --alpha 1 --beta 0 --operator matrix
    if "%config%" NEQ "all" goto end_switch

:config_2
	set d="springs_2"
	if not exist %d% mkdir %d%
	%exe% --prefix "%d%/" --n  3 --tolerance 1D-7 --t 3 --nu 3 --nv 0 --nl 10 --nt 100 --rp 2 --rq 0 --rm 3 --alpha 0.5 --beta 0 --operator matrix
    if "%config%" NEQ "all" goto end_switch

:config_3
	set d="springs_3"
	if not exist %d% mkdir %d%
	%exe% --prefix "%d%/" --n  5 --tolerance 1D-7 --t 0.8 --nu 3 --nv 3 --nl 4 --nt 100 --rp 2 --rq 0.01 --rm 3 --alpha 0.9 --beta 0 --operator matrix
    if "%config%" NEQ "all" goto end_switch

:end_switch


