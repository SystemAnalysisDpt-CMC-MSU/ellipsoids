function addFields(self,addFieldNameList,varargin)
% ADDFIELD adds new of field to a given dynamic CubeStruct
%
% Usage: addFields(self,addFieldNameList,addFieldDescrList)
%
% input:
%   regular:
%     self:
%     addFieldNameList: char or char cell [1,nAddFields] - names of fields
%         to be added
%   optional:
%     addFieldDescrList: char or char cell [1,nAddFields] - descriptions of
%         fields to be added
%
%   properties:
%       typeSpecList: cell[1,nAddFields] - type specifications for the
%          added fields
%
%       sourceFieldNameList: cell[1,nAddFields] of char[1,] - source 
%           field name list that defines a field from which the values 
%           and copied from, if both typeSpecList and sourceFieldNameList 
%           is specified, sourceFieldNameList has the first priority, 
%           empty entries in sourceFieldNameList mean that 
%           the corresponding field has no source field
%       addInFront: logical[1,1]- if true, fields are added in front of the
%           relation, otherwise they are added to the back of the 
%           field list 
%              default value is false
%       
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-30 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.addFieldsInternal(addFieldNameList,varargin{:});