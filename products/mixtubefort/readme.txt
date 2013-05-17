***************************** COMPILATION *********************************

To compile the program you will need:

1.	Microsoft Visual Studio 2010 or greater
2.	Intel Visual Fortran Compiler XE 12 or greater
3.	Matlab R2012a or greater
4.	MPICH2 library 1.4 or greater (can be downloaded from 
    http://www.mpich.org/downloads)
5.	NAG library mark 21 (not greater than 21)

Instructions:

1.  Put fmpich2.lib and mpi.lib from %MPICH2_INSTALL_DIRECTORY%\lib into
	dependencies directory
2.  Put libmat.lib,libmx.lib, libmwblas.lib and libmwlapack.lib from 
	%MATLAB_INSTALL_DIRECTORY%\R2012a\extern\lib\win32\microsoft into
	dependencies directory
3.	Add directory %MATLAB_INSTALL_DIRECTORY%\R2012a\bin\win32 to your PATH
	variable or copy libmat.dll, libmx.dll, libmwblas.dll and 
	libmwlapack.dll from there into build directory
4.	Put the following NAG routines into libnag directory:
	c05adft.f	d02pdtt.f	d02pvyt.f	g05fdft.f
	c05azft.f	d02pdut.f	d02pvzt.f	p01abft.f
	d02pcft.f	d02pdvt.f	d02pwft.f	p01abzt.f
	d02pdft.f	d02pdwt.f	d02pxft.f	x01aaft.f
	d02pdmt.f	d02pdxt.f	d02pxyt.f	x02ajft.f
	d02pdpt.f	d02pdyt.f	d02pxzt.f	x02akft.f
	d02pdqt.f	d02pdzt.f	g05cayt.f	x02amft.f
	d02pdrt.f	d02pvft.f	g05cazt.f	x04aaft.f
	d02pdst.f	d02pvxt.f	g05cbft.f	x04baft.f
5.	Add directory %MATLAB_INSTALL_DIRECTORY%\R2012a\extern\include
	to Additional Include Directories of libsynthesis project
6.	Add directory %MPICH2_INSTALL_DIRECTORY%\include
	to Additional IncludeDirectories of libutil project
7.	Build the solution


****************************** RUNNING ************************************

To run the program use run.bat from run directory:

run tests				// will run test_all.exe

run example_i j			// will run example_i.exe for configuration j, 
						// where i = 1 or 2, and j = 1, 2 or 3

run example_i all       // will run example_i.exe for all configurations