function [isThereVec,indLocVec]=getIsFieldVec(self,fieldNameList)
% GETISFIELDVEC returns whether each field with given name is
% in the field list of given CubeStruct object or not and the index of
% this field in the mentioned list
%
% Usage: [isThereVec,indLocVec]=...
%            getIsFieldVec(self,fieldNameList)
%
% Input:
%   regular:
%     self: CubeStruct [1,1] - class object
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
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-04-03 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.type.simple.lib.iscellofstrvec;
import modgen.common.throwerror;
if ~iscellofstrvec(fieldNameList)
    throwerror('wrongInput',...
        'fieldNameList is expected to be a cell array of strings');
end
[isThereVec,indLocVec]=ismember(fieldNameList,self.fieldNameList);