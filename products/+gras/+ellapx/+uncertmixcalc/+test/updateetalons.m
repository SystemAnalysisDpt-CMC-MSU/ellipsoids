function updateetalons()
dirName=[fileparts(which(mfilename('fullpath'))),filesep,...
    '+mlunit',filesep,'TestData'];
gras.ellapx.smartdb.util.updateondiskrels(dirName);