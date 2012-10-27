function renameFieldsInternal(self,fromFieldNameList,toFieldNameList,...
    toFieldDescrList)
% RENAMEFIELDSINTERNAL renames names of fields for given object
%
% Usage: renameFields(self,fromFieldNameList,toFieldNameList)
%
% Input:
%   regular:
%       self: CubeStruct [1,1]
%       fromFieldNameList: char[1,]/cell [1,nFields] of char[1,] - names 
%           of fields to be renamed
%       toFieldNameList: char[1,] cell [1,nFields] of char[1,] - names 
%           of these fields after renaming
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
import modgen.common.type.simple.*;
if nargin<4
    isDescrSpec=false;
else
    isDescrSpec=true;
    toFieldDescrList=checkcellofstr(toFieldDescrList);
end
fromFieldNameList=checkcellofstr(fromFieldNameList);
toFieldNameList=checkcellofstr(toFieldNameList);
%
if ~strcmp(class(fromFieldNameList),class(toFieldNameList))
    error([upper(mfilename),':wrongInput'],...
        'fieldLists both should be of the type cell or char');
end
nToFields=length(toFieldNameList);
nFromFields=length(fromFieldNameList);
if nToFields~=nFromFields
    error([upper(mfilename),':wrongInput'],...
        'field lists should have the same length');
end
nUniqueToFields=length(unique(toFieldNameList));
nUniqueFromFields=length(unique(fromFieldNameList));
if (nUniqueToFields~=nToFields)||(nUniqueFromFields~=nFromFields)
    error([upper(mfilename),':wrongInput'],...
        'both field lists should contain unique names');
end
%
[~,indLoc]=self.getIsFieldVecCheck(fromFieldNameList);
%
fullToFieldNameList=self.fieldNameList;
fullToFieldNameList(indLoc)=toFieldNameList;
SResData=struct();
SResIsNull=struct();
SResIsValueNull=struct();
for iField=1:self.getNFields()
    toName=fullToFieldNameList{iField};
    fromName=self.fieldNameList{iField};
    SResData.(toName)=self.SData.(fromName);
    SResIsNull.(toName)=self.SIsNull.(fromName);
    SResIsValueNull.(toName)=self.SIsValueNull.(fromName);
end
self.clearFieldsAsProps();
%
self.fieldMetaData(indLoc).setName(toFieldNameList);
%
if isDescrSpec
    self.fieldMetaData(indLoc).setDescription(toFieldDescrList);
end
%
self.SData=SResData;
self.SIsNull=SResIsNull;
self.SIsValueNull=SResIsValueNull;
%clear field definitions as properties and then recreate them
self.defineFieldsAsProps();