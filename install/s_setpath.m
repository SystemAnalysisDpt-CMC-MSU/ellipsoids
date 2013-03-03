% rootPathList{2}=[rmlastnpathparts(fileparts(which(mfilename)),2),filesep,'Folder1'];
rootPathList{1}=rmlastnpathparts(fileparts(which(mfilename)),1);
pathPatternToExclude='\.svn';
pathList=genpathexclusive(rootPathList,pathPatternToExclude);
restoredefaultpath;
addpath(pathList{:});
savepath;


