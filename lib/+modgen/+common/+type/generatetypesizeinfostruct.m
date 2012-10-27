function STypeSizeInfo=generatetypesizeinfostruct(value)
% GENERATETYPESIZEINFOSTRUCT constructs a meta structure containing a
% complete (recursive for cells)
% information about type and size of input array
%
% Input: value - array of any type
% 
% Output: STypeSizeInfo structure each node of which has the following
%   fields:
%   
%   type: char[1,]
%   sizeVec: double[1,]
%   itemTypeInfo: STypeSizeInfo[1,]
%   isCell: logical[1,1]
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%

%
valueClass=class(value);
STypeSizeInfo.type=valueClass;
STypeSizeInfo.sizeVec=size(value);
STypeSizeInfo.itemTypeInfo=[];
%
STypeSizeInfo.isCell=false;
if iscell(value)
    STypeSizeInfo.isCell=true;
    if ~isempty(value)
        % try to guess structure of value
        if iscellstr(value)||modgen.common.iscelllogical(value)||modgen.common.iscellnumeric(value)
            %
            sizeVecList=cellfun(@size,value,'UniformOutput',false);
            STypeSizeInfo.itemTypeInfo=struct('sizeVec',sizeVecList,...
                'isCell',false,'type',class(value{1}),'itemTypeInfo',[]);
        else
            STypeSizeInfo.itemTypeInfo=cellfun(...
                @modgen.common.type.generatetypesizeinfostruct,value);
        end
    else
        STypeSizeInfo.itemTypeInfo=modgen.common.type.NestedArrayType.classname2typeinfo('char');        
        STypeSizeInfo.itemTypeInfo.sizeVec=[0 0];
        STypeSizeInfo.itemTypeInfo.isCell=false;
        return;
    end
end