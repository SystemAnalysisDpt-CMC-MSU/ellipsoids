function resRelObj = selfjoin(inpRelObj,joinByFieldList,fieldNameListField,varargin)
% SELFJOIN performs self join of given relation and returns the
% result as new relation
%
% Usage: resRelObj=selfjoinwithfilter(inpRelObj,joinByFieldList,...
%            filterField,filterToFieldRel,varargin)
%
% Input:
%   regular:
%       inpRelObj: ARelation [1,1] - class object with relation to which self
%           join is to be applied
%
%       joinByFieldList: char cell [1,nJoinFields] - list of names for fields
%           of inpRelObj reltion by which join is performed
%
%       fieldNameListField: char - name of field in inpRelObj relation such that
%           tuples with different values of this field but with equal values
%           of fields from joinByFieldList are joined into single tuple so
%           that duplicates of value fields (i.e. the rest fields such that
%           their names are not equal both to filterField and to fields from
%           joinByFieldList) of inpRelObj relation corresponding to the same
%           initial field but to different tuples that are joined are
%           represented by separate fields in new relation with some new names
%           Please note that values of this field determine the names of value 
%           columns in the resulting relation
%
%   optional:
%       fieldDescrListField: char - name of field in inpRelObj that
%           determines description of each column
%
%       fieldOrderField: char - name of field that specifies an order of 
%           value fields in the resulting relation  
%
%   properties:
%
%     leadFieldList: cell[1,] of char[1,] - list of fields from the original
%       inpRelObj relation that are kept in the resulting relation
%     valueField: char[1,] - name of field value in inpRelObj, if not
%        specified it is determined automatically
%    
% output:
%   regular:
%     resRelObj: ARelation [1,1] - class object obtained from inpRelObj as
%        result of self joining
%
% Note: 1) All fields in inpRelObj are divided on three groups: fields from
%          joinByFieldList, two fields fieldNameListField and fieldDescrListField
%           and value fields not contained in previous two groups. 
%           It is assumed that inpRelObj
%          contains only one value field from the third group.
%       2) resRelObj contains fields from joinByFieldList and duplicates
%          of single value field renamed with respect to fieldNameListField
%          and does not contain fieldNameListField.
%       4) It is assumed that combination of values for fields from
%          joinByFieldList and fieldNameListField uniquely determines tuples of
%          inpRelObj relation.
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-06 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
import smartdb.*;
import modgen.common.*;
import smartdb.relationoperators.*;
%% Input parameters
[reg,isRegSpecVec,prop,isPropSpecVec]=parseparext(varargin,...
    {'leadFieldList','valueField'},...
    [0 2],...
    'regCheckList',{'isstring(x)','isstring(x)'},...
    'regDefList',{fieldNameListField},...
    'propRetMode','list');
%
fieldDescrListField=reg{1};
nRegs=length(reg);
nProps=length(prop);
if any(strcmpi(prop(1:2:nProps-1),'fieldNameListField')|...
        strcmpi(prop(1:2:nProps-1),'fieldDescrListField'))
    throwerror([upper(mfilename),':wrongInput'],...
        ['fieldNameListField and fieldDescrListField properties',...
        'are not supported']);
end
if nRegs>1
    prop=[prop,{'fieldOrderField'},reg(2)];
end
%
notFilterFieldList=setdiff(inpRelObj.getFieldNameList,...
    {fieldNameListField,fieldDescrListField});
%
filterRelObj=relations.DynamicRelation(inpRelObj);
filterRelObj.removeFields(notFilterFieldList);
filterRelObj.removeDuplicateTuples();
%
if isRegSpecVec(1)
    if ~isPropSpecVec(2)
        valueFieldList=...
            setdiff(notFilterFieldList,joinByFieldList);
        if numel(valueFieldList)~=1
            throwerror('wrongInput',...
                ['impossible to infer value field name as ',...
                'after removing joinBy fields and filter ',...
                '%d fields remains'],numel(valueFieldList));
        end
        prop=[prop,{'valueField'},valueFieldList];
    end
end
resRelObj = selfjoinwithfilter(inpRelObj,joinByFieldList,...
    fieldNameListField,filterRelObj,...
    'fieldNameListField',fieldNameListField,...
    'fieldDescrListField',fieldDescrListField,prop{:});
%