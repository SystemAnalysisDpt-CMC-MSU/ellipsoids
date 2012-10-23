function valueArray=createarraybytypeinfo(STypeInfo,sizeVec)
% CREATEARRAYBYTYPEINFO creates an array of STypeInfo structure
%
% Input:
%   regular:
%       STypeInfo: struct[1,1] - structure containing type information
%       sizeVec: double [1,nDims] - size of the array to be created
%
%
% Output:
%   valueArray: requested type of size specified by sizeVec parameter
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
import modgen.common.*
if isempty(STypeInfo.type)
    error([upper(mfilename),':wrongInput'],...
        'type field cannot be empty');
end
%    
if numel(sizeVec)==1
    sizeVec=[sizeVec,1];
end
if STypeInfo.depth==0
    valueArray=modgen.common.type.createarray(STypeInfo.type,sizeVec);
else
    nestedType=STypeInfo.type;
    valueArray=repmat(createnestedcell(STypeInfo.depth),...
        sizeVec);
end
%
    function valueArray=createnestedcell(depth)
        if depth>0
            valueArray={createnestedcell(depth-1)};
        else
            valueArray=modgen.common.type.createarray(nestedType,[0 0]);
        end
    end
end