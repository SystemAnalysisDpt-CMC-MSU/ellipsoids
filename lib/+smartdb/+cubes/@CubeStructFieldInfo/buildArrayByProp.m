function resArray=buildArrayByProp(self,cubeStructRefList,varargin)
% BUILDARRAYBYPROP is a helper method for filling an object array with
% the specified properties
% 
% Input:
%   regular:
%       self: CubeStructFieldInfo[1,1]
%       cubeStructRefList: cell[n1,n2,...,n_k] of CubeStruct objects
%   properties:
%       regular:
%          nameList: cell[n1,n2,...,n_k] of char[1,] - field name
%       optional:
%          descriptionList: cell[n1,n2,...,n_k] of char[1,] - field description
%          typeSpecList: cell[n1,n2,...,n_k] of cell[1,] of char - field type 
%              specification , 
%                  Example:  {'cell','char'}
%          typeList: cell[n1,n2,...,n_k] of modgen.common.type.ANestedArrayType
% 
% Output:
%   resArray[n1,n2,...,n_k] - constructed array of CubeStructFieldInfo
%      objects
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-25 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
%
import modgen.common.throwerror;
import modgen.common.type.simple.lib.iscellofstrvec;
if numel(self)~=1
    throwerror('wrongInput',...
        'self is expected to be a scalar object');
end
%
if ~iscell(cubeStructRefList)
    cubeStructRefList={cubeStructRefList};
end
%
[reg,prop]=modgen.common.parseparams(varargin);
if ~isempty(reg)
    throwerror('wrongInput',...
        'no regular arguments is expected');
end
nProp=length(prop);
isTypeSpecPassed=false;
isTypePassed=false;
isDescrPassed=false;
isNamePassed=false;
%
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'namelist',
            nameList=prop{k+1};
            isNamePassed=true;
        case 'descriptionlist',
            isDescrPassed=true;
            descrList=prop{k+1};
        case 'typespeclist',
            typeSpecList=prop{k+1};
            isTypeSpecPassed=true;
        case 'typelist',
            typeList=prop{k+1};
            isTypePassed=true;
        otherwise,
            throwerror('wrongInput','property %s is not supported',...
                lower(prop{k}));
    end
end
%
resArray=self;
%first try to use name for determining a target size, if not possible, use
%cubeStructRefList
if isNamePassed
    if ischar(nameList)
        nameList={nameList};
    end
    if ~iscellofstrvec(nameList)
        throwerror('wrongInput',...
            'nameList is expected to be a cell of strings');
    end
    if numel(nameList)~=numel(unique(nameList))
        throwerror('wrongInput',...
            'nameList should contain unique elements');
    end
    expSizeVec=size(nameList);
    nElems=numel(nameList);    
else
    expSizeVec=size(cubeStructRefList);
    nElems=numel(cubeStructRefList);
end
%
if nElems>1
    resArray(nElems)=smartdb.cubes.CubeStructFieldInfo();
    resArray=reshape(resArray,expSizeVec);
elseif nElems==0
    resArray=self.empty(expSizeVec);
end
%
if numel(cubeStructRefList)==1
    cubeStructRefList=cubeStructRefList(ones(expSizeVec));
elseif ~isequal(size(cubeStructRefList),expSizeVec)
    throwerror('wrongInput',...
        ['a size of the constructred object should coincide with ',...
        'a size of CubeStructRefList']);
end
%
isScalarVec=cellfun('prodofsize',cubeStructRefList);
if ~all(isScalarVec)
    throwerror('wrongInput',...
        'cubeStructRefList is expected to contain the scalar CubeStructs');
end
%
for iElem=1:nElems
    resArray(iElem).cubeStructRef=cubeStructRefList{iElem};
end
if ~isDescrPassed
    if isNamePassed
        descrList=nameList;
        isDescrPassed=true;
    end
else
    if ischar(descrList)
        descrList={descrList};
    end
    %
    if ~iscellofstrvec(descrList)
        throwerror('wrongInput',...
            'descrList is expected to be a cell of strings');
    end
    %
    if ~isequal(size(descrList),expSizeVec)
        throwerror('wrongInput',...
            'descrList is expected to have size %s',mat2str(expSizeVec));
    end
end
if isNamePassed
    for iElem=1:nElems
        resArray(iElem).name=nameList{iElem};
    end
end
if isDescrPassed
    for iElem=1:nElems
        resArray(iElem).description=descrList{iElem};
    end
end
if isTypePassed&&~iscell(typeList)
    typeList={typeList};
end
if isTypeSpecPassed&&~isempty(typeSpecList)&&iscellstr(typeSpecList)
    typeSpecList={typeSpecList};
end
%
if ~isTypePassed
    if isTypeSpecPassed
        if ~isequal(size(typeSpecList),expSizeVec)
            throwerror('wrongInput',...
                'typeSpecList is expected to have size %s',...
                mat2str(expSizeVec));
        end
        for iElem=1:nElems
            resArray(iElem).type=...
                smartdb.cubes.CubeStructFieldTypeFactory.fromClassName(...
                cubeStructRefList{iElem},typeSpecList{iElem});
        end
    else 
        for iElem=1:nElems
            resArray(iElem).type=...
                smartdb.cubes.CubeStructFieldTypeFactory.defaultArray(...
                    cubeStructRefList{iElem},[1 1]);
        end
    end
else
    for iElem=1:nElems
        resArray(iElem).type=typeList{iElem};
    end
end
    

