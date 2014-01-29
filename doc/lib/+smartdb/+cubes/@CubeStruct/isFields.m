function [isPositive,isUniqueNames,isThereVec]=isFields(self,fieldList)
% ISFIELDS - returns whether all fields whose names are given in the input 
%            list are in the field list of given object or not
%
% Usage: isPositive=isFields(self,fieldList)
%
% Input:
%   regular:
%     self: CubeStruct [1,1]
%     fieldList: char or char cell [1,nFields]/[nFields,1] - input list of
%         given field names
% Output:
%   isPositive: logical [1,1] - true if all gields whose
%       names are given in the input list are in the field
%       list of given object, false otherwise
%
%   isUniqueNames: logical[1,1] - true if the specified names contain
%      unique field values
%
%   isThereVec: logical[1,nFields] - each element indicate whether the
%       corresponding field is present in the cube
%
%TODO allow for varargins
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-06-03 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.checkIfObjectScalar();
if isa(fieldList,'char')
    fieldList={fieldList};
elseif ~(iscellstr(fieldList)&&modgen.common.isvec(fieldList)&&...
        all(cellfun(@modgen.common.isrow,fieldList)))
    error([upper(mfilename),':wrongInput'],...
        'fieldList is expected to be a cell row vector of row strings');
end
% 
[isThereVec,indVec]=ismember(fieldList,self.fieldNameList);
isPositive=all(isThereVec);
if nargout>1
    isUniqueNames=length(indVec)==length(unique(indVec));
end