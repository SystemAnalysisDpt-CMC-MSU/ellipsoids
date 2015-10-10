curDir=fileparts(which(mfilename));
EXTERNALS_URL='https://github.com/SystemAnalysisDpt-CMC-MSU/ellipsoids/releases/download/2.1/cvx2.1_b1110_mpt3_1_win32_and_win64.zip'
tmpFile=[curDir,filesep,'externals.zip'];
urlwrite(EXTERNALS_URL,tmpFile);
unzip(tmpFile,[curDir,filesep,'..',filesep,'externals']);

