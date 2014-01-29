function isPositive=isUniqueKey(self,fieldNameList)
% ISUNIQUEKEY - checks if a specified set of fields forms a unique key
% 
% Usage: isPositive=self.isUniqueKey(fieldNameList)
%
% Input:
%   regular:
%       self: ARelation [1,1] - class object
%       fieldNameList: cell[1,nFields] - list of field names for a unique
%           key candidate
% Output:
%   isPositive: logical[1,1] - true means that a specified set of fields is
%      a unique key
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
% if ischar(fieldNameList)
%     fieldNameList={fieldNameList};
% elseif ~iscellstr(fieldNameList)
%     error([upper(mfilename),':wrongInput'],...
%         'fieldNameList is expected to be a cell array of strings');
% end
% %
% if ~auxchecksize(fieldNameList,[1,nan])
%     error([upper(mfilename),':wrongInput'],...
%         'fieldNameList is expected to be of size [1,]');
% end
%
indForward=self.getUniqueDataAlongDimInternal(1,...
    'fieldNameList',fieldNameList,'structNameList',{});
isPositive=(length(indForward)==self.getNTuples());