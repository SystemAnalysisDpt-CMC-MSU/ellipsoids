function renameFields(self,fromFieldNameList,toFieldNameList,varargin)
% RENAMEFIELDS renames names of fields for a given CubeStruct object
%
% Usage: renameFields(self,fromFieldNameList,toFieldNameList)
%
% Input:
%   regular:
%     self:
%     fromFieldNameList: char or char cell [1,nFields] - names of fields
%         to be renamed
%     toFieldNameList: char or char cell [1,nFields] - names of these
%         fields after renaming
%   optional:
%       toFieldDescrList: char[1,]/cell[1,nFields] of char[1,] -
%          descriptions of fields
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-04-26 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.renameFieldsInternal(fromFieldNameList,toFieldNameList,varargin{:});