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
	set d="%example%_config_1"
	if not exist %d% mkdir %d%
	%exe% --prefix "%d%/" --n  5 --tolerance 1D-6 --t 40 --nl 2 --unilateral --nt 4001 --mr 1D-2 --operator matrix
    if "%config%" NEQ "all" goto end_switch

:config_2
	set d="%example%_config_2"
	if not exist %d% mkdir %d%
	%exe% --prefix "%d%/" --n  5 --tolerance 1D-6 --t 1D-1 --nl 1 --nt 201 --rm 1D-2 --operator matrix
    if "%config%" NEQ "all" goto end_switch

:config_3
	set d="%example%_config_3"
	if not exist %d% mkdir %d%
	%exe% --prefix "%d%/" --n 10 --tolerance 1D-6 --t 20 --nl 5 --rm 1D-4 --nu 3 --rp 2 --rq 1 --vmode U --operator matrix
    if "%config%" NEQ "all" goto end_switch

:config_4
	set d="%example%_config_4"
	if not exist %d% mkdir %d%
	%exe% --prefix "%d%/" --n 10 --tolerance 1D-4 --t 2 --nl 20 --nt 1001 --mr 1D-2 --write-eigs --alpha .1 --operator matrix 
    if "%config%" NEQ "all" goto end_switch

:end_switch


