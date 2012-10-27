function pathStr=rmlastnpathparts(pathStr,nPartsToRemove)
if isempty(pathStr)
    modgen.common.throwerror('wrongInput','pathStr cannot be empty');
end
ind=regexp(pathStr,filesep);
nPartsInTotal=length(ind);
if nPartsToRemove>0
    pathStr=pathStr(1:(ind(nPartsInTotal-nPartsToRemove+1)-1));
end
    