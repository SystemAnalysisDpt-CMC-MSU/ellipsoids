import gras.ellapx.uncertmixcalc.test.conf.MixTubeFortData
%
[~,currentDir] = fileparts(fileparts(mfilename('fullpath')));
%
if strcmp(currentDir, 'run')
    basePath = ['products' filesep 'mixtubefort' filesep 'run'];
else
    basePath = '.';
end
%
DirList = dir([basePath filesep 'springs_*']);
nDirs = numel(DirList);
%
fprintf('%d configuration(s) found\n',nDirs);
%
for iDir = 1:nDirs
    dirName = DirList(iDir).name;
    dataFileName = [basePath filesep dirName filesep 'data.mat'];
    %
    fprintf('converting configuration "%s"\n',dirName);
    %
    mixTubeData = MixTubeFortData(dataFileName);
    mixTubeData.saveConf(dirName);
    mixTubeData.saveEllTube(dirName);
end
%
clear mixTubeData
fprintf('all done\n');