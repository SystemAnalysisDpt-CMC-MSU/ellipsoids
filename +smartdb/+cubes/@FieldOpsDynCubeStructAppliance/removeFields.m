function removeFields(self,varargin)
% REMOVEFIELDS removes fields from a given CubeStruct object
%
% Usage: removeFields(self,varargin)
%
% Input:
%   regular:
%     self:
%   optional:
%     Case1:
%        fieldName1: char - name of first field
%        ...
%        fieldNameN: char - name of N-th field
%     Case2:
%        fieldNameList: cell[1,] of char - list of fileds to delete
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
import modgen.common.throwerror;
if nargin~=1
    isCharVec=cellfun('isclass',varargin,'char');
    isCellStr=cellfun(@iscellstr,varargin);
    if ~all(isCharVec|isCellStr)
        throwerror('wrongInput','all inputs should be of type char');
    end
    inpList=varargin(isCharVec);
    inpCellStr=varargin(isCellStr);
    inpList=[inpList,inpCellStr{:}];
    self.removeFieldsInternal(unique(inpList));
end