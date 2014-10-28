function SObjectData=saveObjInternal(self)
% SAVEOBJINTERNAL saves a current object state to a structure,
%    please note that this function is only used for implementing
%    isEqual method
%
% Input: 
%   regular:
%       self: CubeStructFieldExtendedInfo[n1,n2,...,n_k]
%   
% Output:
%   struct[n1,n2,...,n_k] -resulting structure
%
%
% $Author: Ilya Roublev  <iroublev@gmail.com> $	$Date: 2014-07-10 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2014 $
%
%

SObjectData=saveObjInternal@smartdb.cubes.CubeStructFieldInfo(self);
nElem=numel(self);
for iElem=1:nElem
    SObjectData(iElem).sizePatternVec=self(iElem).sizePatternVec;
    SObjectData(iElem).isSizeAlongAddDimsEqualOne=...
        self(iElem).isSizeAlongAddDimsEqualOne;
    SObjectData(iElem).isUniqueValues=self(iElem).isUniqueValues;
end