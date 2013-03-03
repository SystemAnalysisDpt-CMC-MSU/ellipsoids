function SObjectData=saveObjInternal(self)
% SAVEOBJINTERNAL saves a current object state to a structure,
%    please note that this function is only used for implementing
%    isEqual method
%
% Input: 
%   regular:
%       self: CubeStructFieldInfo[n1,n2,...,n_k]
%   
% Output:
%   struct[n1,n2,...,n_k] -resulting structure
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
sizeVec=size(self);
nElem=numel(self);
SObjectData=repmat(struct(),sizeVec);
for iElem=1:nElem
    SObjectData(iElem).name=self(iElem).name;
    SObjectData(iElem).description=self(iElem).description;
    SObjectData(iElem).type=self(iElem).type;
end