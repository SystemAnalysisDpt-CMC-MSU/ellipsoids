import gras.ellapx.uncertmixcalc.test.conf.MixTubeFortData
%
DirList = dir('example_*_config_*');
nDirs = numel(DirList);
%
fprintf('%d configuration(s) found\n',nDirs);
%
for iDir = 1:nDirs
    dirName = DirList(iDir).name;
    dataFileName = [dirName filesep 'data.mat'];
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