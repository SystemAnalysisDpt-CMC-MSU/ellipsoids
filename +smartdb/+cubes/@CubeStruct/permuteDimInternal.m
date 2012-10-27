function permuteDimInternal(self,dimOrderVec,isInvPermute)
% PERMUTEDIM permutes dimensions of CubeStruct based on 
% a specified dimension order vector
%
% Input:
%   regular:
%       self: CubeStruct[1,1]
%       dimOrderVec: [n_1,...,n_k] - expected order of dimensions for
%          resulting CubeStructObject
%   optional:
%       isInvPermute: logical[1,1] - if true, permute is performed in an
%          opposite direction
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.checkIfObjectScalar();
if nargin<3
    isInvPermute=false;
end
if isInvPermute
    fPerm=@ipermute;
else
    fPerm=@permute;
end
%
minDim=self.getMinDimensionality();
if ~(modgen.common.isvec(dimOrderVec)&&...
        all(dimOrderVec==fix(dimOrderVec))&&...
        all(dimOrderVec>=1&dimOrderVec<=minDim)&&...
        length(unique(dimOrderVec))==length(dimOrderVec))
        %
    error([upper(mfilename),':wrongInput'],...
        'dimOrderVec should consist of valid dimension numbers');
end
maxDim=max(max(self.applyGetFuncInternal(@ndims)),minDim);
fieldNameList=self.getFieldNameList();
restDimNumVec=minDim+1:maxDim;
valueDimVec=[dimOrderVec, restDimNumVec];
for iField=1:length(fieldNameList)
    fieldName=fieldNameList{iField};
    %
    self.SData.(fieldName)=fPerm(...
        self.SData.(fieldName),valueDimVec);
    %
    self.SIsNull.(fieldName)=fPerm(...
        self.SIsNull.(fieldName),valueDimVec);
    %
    self.SIsValueNull.(fieldName)=fPerm(...
        self.SIsValueNull.(fieldName),dimOrderVec);
end