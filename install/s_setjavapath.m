deploymentDirName=fileparts(which(mfilename));
%Add jar files to static java path (Matlab restart might be required)
classPathFileName=[deploymentDirName,filesep,'javaclasspath.txt'];
%
javaPathMgr=elltool.deploy.JavaStaticPathMgr(classPathFileName);
javaPathMgr.setUp();