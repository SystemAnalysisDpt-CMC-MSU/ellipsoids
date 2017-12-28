set locDir=%~dp0
rmdir /s /q "%locDir%..\..\..\doc\docs"
xcopy /f /y "%locDir%README.md" "%locDir%..\..\..\README.md"
python %locDir%prep4doxymat.py %locDir%..\.. %locDir%..\..\..\TTD\elltool-doxygen-prep %locDir%..\..\..\TTD\elltool-doxygen-garbage
for /f %%i in ('cd') do set curDir=%%i
cd %locDir%
doxygen Doxyfile_bat
echo "">%locDir%..\..\..\doc\docs\.nojekyll
cd %curDir%