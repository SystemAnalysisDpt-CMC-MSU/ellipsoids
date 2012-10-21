function STypeInfo=classname2typeinfo(classNameList)
% CLASSNAME2TYPEINFO translates built-in class names into STypeInfo
% definitions
%
% Input:
%   classNameList: char/cell[1,nNestedLevels]
%
% Output:
%   STypeInfo: struct[1,1] - type information
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if ischar(classNameList)
    classNameList={classNameList};
end
%
nElem=length(classNameList);
if nElem==0
    error([upper(mfilename),':wrongInput'],...
        'at least one element is expected in classNameList');
end
%
isCellVec=strcmp(classNameList,'cell');
indLastCell=find(isCellVec,1,'last');
if isempty(indLastCell)
    if nElem==1
        STypeInfo.type=classNameList{1};
        STypeInfo.depth=0;
    else
        error([upper(mfilename),':wrongInput'],...
            'only cells are expected to have the nested types');
    end
else
    if ~all(isCellVec(1:indLastCell))
        error([upper(mfilename),':wrongInput'],...
            ['classNameList is badly formed as cells can only be ',...
            'contained in cells']);
    end
    if nElem-indLastCell>1
        error([upper(mfilename),':wrongInput'],...
            'bottom type cannot be nested');
    else
        if nElem==indLastCell
            STypeInfo.type='';
        else
            STypeInfo.type=classNameList{end};
        end
        STypeInfo.depth=indLastCell;
    end
end