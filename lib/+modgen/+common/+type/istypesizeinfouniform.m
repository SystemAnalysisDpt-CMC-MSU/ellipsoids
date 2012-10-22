function [isOk,STypeInfo]=istypesizeinfouniform(STypeSizeInfo)
% ISTYPESIZEINFOUNIFORM check the input STypeSizeInfo structure for
%   uniformity
%
% Input:
%   STypeSizeInfo: struct[1,1]
%
% Output:
%   isOk: logical[1,1] true is the input structure is uniform
%   STypeInfo: struct[1,1] - unified type info structure compiled from
%      the input STypeSizeInfo structure by removing size information and
%      unified the type information across all the elements
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%

%
[isOk,STypeInfo]=gettypeinfonested(STypeSizeInfo);
%
STypeInfo=modgen.common.type.updatetypeinfostruct(STypeInfo);
%
function [isOk,STypeInfo]=gettypeinfonested(STypeSizeInfo)
STypeInfo=struct('type',STypeSizeInfo.type,...
    'isCell',STypeSizeInfo.isCell,'itemTypeInfo',[]);
%
if STypeSizeInfo.isCell
    isCellVec=[STypeSizeInfo.itemTypeInfo.isCell];
    isEqual=all(isCellVec==false);
    if length(STypeSizeInfo.itemTypeInfo)>1
        isEqual=isEqual&&isequal(STypeSizeInfo.itemTypeInfo.type);
    end
    if isEqual
        isOk=true;
        STypeInfo.itemTypeInfo=rmfield(STypeSizeInfo.itemTypeInfo(1),'sizeVec');
        return;
    end
    typeInfoList=mat2cell(STypeSizeInfo.itemTypeInfo(:),...
        ones(1,numel(STypeSizeInfo.itemTypeInfo)),1);
    [isOkList,typeInfoList]=cellfun(...
        @gettypeinfonested,...
        typeInfoList,'UniformOutput',false);
    isOk=all([isOkList{:}]);
    if length(typeInfoList)>1
        isOk=isOk&&isequal(typeInfoList{:});
    end
    if ~isempty(typeInfoList)
        STypeInfo.itemTypeInfo=typeInfoList{1};
    end
else
    isOk=true;
end