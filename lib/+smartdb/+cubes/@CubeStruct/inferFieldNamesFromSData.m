function inpArgList=inferFieldNamesFromSData(inpArgList)
isFieldNameSpec=false;
isFieldMetaDataSpec=false;
%
[reg,prop]=parseparams(inpArgList);
nReg=length(reg);
nProp=length(prop);
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'fieldnamelist',
            isFieldNameSpec=true;
        case 'fieldmetadata',
            isFieldMetaDataSpec=true;
    end
end
if nReg>0&&~isa(reg{1},'smartdb.cubes.CubeStruct')
    if isstruct(reg{1})
        if ~(isFieldNameSpec||isFieldMetaDataSpec)
            inpArgList=[inpArgList,{'fieldNameList',...
                transpose(fieldnames(reg{1}))}];
        end
    else
        sizeVec=reg{1};
        if ~(nReg==1&&isnumeric(sizeVec)&&ismatrix(sizeVec)&&...
                size(sizeVec,1)==1&&size(sizeVec,2)>=2),
            error([upper(mfilename),':wrongInput'],...
                ['the first regular argument is expected to ',...
                'be either a structure or CubeStruct object or '...
                'numeric array with size']);
        end
    end
end