function updateondiskrels(dirName)
% UPDATEONDISKRELS updates relations stored in mat files via loading and
% saving. This works when structure of relation changes due to some 
% changes in certain core superclasses like smartdb.relations.ARelation,
% smartdb.cubes.CubeStruct or others but list/type/size of files remains
% intact. In case of significant changes in the aforementioned core classes
% relations or cubes cannot be loaded as objects and are loaded as
% structures as well. If relation defines a proper loadobj static method
% then load/save procedure is able to correctly update the relations saved
% on disk
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2015-04-16 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
if ~strcmp(dirName(end),filesep)
    dirName=[dirName,filesep];
end
%
SFiles=dir([dirName,'*.mat']);
nFiles=numel(SFiles);
for iFile=1:nFiles
    fullFileName=[dirName,SFiles(iFile).name];
    SRes=load(fullFileName);
    varNameList=fieldnames(SRes);
    nVars=numel(varNameList);
    for iVar=1:nVars
        varName=varNameList{iVar};
        eval([varName,'=SRes.',varName,';']);
    end
    save(fullFileName,varNameList{:});
end