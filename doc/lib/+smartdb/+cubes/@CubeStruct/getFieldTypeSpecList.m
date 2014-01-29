function typeSpecList=getFieldTypeSpecList(self,varargin)
% GETFIELDTYPESPECLIST - returns a list of field type specifications. Field
%                        type specification is a sequence of type names 
%                        corresponding to field value types starting with 
%                        the top level and going down into the nested 
%                        content of a field (for a field having a complex 
%                        type).
%
% Input: 
%   regular:
%       self:
%   optional:
%       fieldNameList: cell [1,nFields] of char[1,] - list of field names
%   properties:
%       uniformOutput: logical[1,1] - if true, the result is concatenated
%          across all the specified fields
%
% Output:
%   typeSpecList: 
%        Case#1: uniformOutput=false
%           cell[1,nFields] of cell[1,nNestedLevels_i] of char[1,.]
%        Case#2: uniformOutput=true
%           cell[1,nFields*prod(nNestedLevelsVec)] of char[1,.]
%        - list of field type specifications
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-25 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
self.checkIfObjectScalar();
%
isUniformOutput=false;
[reg,prop]=modgen.common.parseparams(varargin);
nProp=length(prop);
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'uniformoutput',
            isUniformOutput=prop{k+1};
        otherwise
            error([upper(mfilename),':unknownProp'],...
                'property %s is not supported',prop{k});
    end
end
if numel(reg)>1
    error([upper(mfilename),':wrongInput'],...
        'too many input arguments');
elseif numel(reg)==0
    fieldNameList=self.getFieldNameList;
else
    fieldNameList=reg{1};
    if ischar(fieldNameList)
        fieldNameList={fieldNameList};
    end
end
fullFieldNameList=self.getFieldNameList();
fieldTypeSpecList=self.fieldMetaData.getTypeSpecList();
if ~isempty(fieldNameList)
    [isThereVec,indLoc]=ismember(fieldNameList,fullFieldNameList);
    if ~all(isThereVec)
        fieldNamesStr=...
            cell2sepstr([],fieldNameList(~isThereVec),...
            ',','isMatlabSyntax',true);
        error([upper(mfilename),':wrongInput'],...
            'fields %s do not exist',fieldNamesStr);
    end
    typeSpecList=fieldTypeSpecList(indLoc);
    if isUniformOutput
        typeSpecList=[typeSpecList{:}];
    end
else
    typeSpecList=cell.empty(size(fieldNameList));
end