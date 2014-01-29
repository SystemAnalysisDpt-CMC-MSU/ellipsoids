function [isThereVec,indLocVec]=getIsFieldVecCheck(self,fieldNameList)
% GETISFIELDVECCHECK returns whether each field with given name
% is in the field list of given object or not and the index
% of this field in the mentioned list; besides, this function
% raises exception in the case not all fields from the input
% list are in the field list of given object
%
% Usage: [isThereVec,indLocVec]=...
%            getIsFieldVecCheck(self,fieldNameList)
%
% Input:
%   regular:
%     self: CubeStruct [1,1]
%     fieldNameList: char or char cell [1,nFields] - list of
%         given field names
% Output:
%   regular:
%     isThereVec: logical [1,nFields] - true if given field is
%         in the field list of given object
%     indLocVec: double [1,nFields] - index of given field in
%         the field list of given object in the case it is in
%         this list, zero otherwise
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%

[isThereVec,indLocVec]=self.getIsFieldVec(fieldNameList);
if ~all(isThereVec)
    error([upper(mfilename),':wrongInput'],...
        'not all inputs correspond to the field names for this object');
end