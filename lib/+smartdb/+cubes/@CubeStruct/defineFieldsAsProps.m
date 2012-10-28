function defineFieldsAsProps(self,fieldNameList)
% DEFINEFIELDSASPROPS adds dynamic properties for all fields of
% given CubeStruct object
%
% Usage: defineFieldsAsProps(self)
%
% Input:
%   regular:
%       self: CubeStruct [1,1] - class object
%   optional:
%       fieldNameList: cell[1,] - of char - list of field names    
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $	$Date: 2012-10-09 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
if nargin<2
    fieldNameList=self.fieldNameList;
    fieldDescrList=self.fieldDescrList;
else
    fieldDescrList=self.getFieldMetaData(fieldNameList).getDescriptionList();
end
nFields=length(fieldNameList);
for iField=1:nFields
    fieldName=fieldNameList{iField};
    p=findprop(self,fieldName);
    if isempty(p),
        p=addprop(self,fieldName);
    end
    p.Transient=true;
    p.GetMethod=@(x)getField(x,fieldName);
    p.SetMethod=@(x,y)setField(x,fieldName,y);
    p.SetAccess='public';
    p.Dependent=true;
    p.Description=fieldDescrList{iField};
    p.DetailedDescription=fieldDescrList{iField};
end