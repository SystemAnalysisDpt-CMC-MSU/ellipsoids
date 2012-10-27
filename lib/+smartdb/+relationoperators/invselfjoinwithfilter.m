function resRelObj = invselfjoinwithfilter(inpRelObj,sepByFieldList,...
    combField,valueField,combToFieldRel,varargin)
% INVSELFJOINWITHFILTER performs inverse operation to self join of given
% relation and returns the result as new relation
%
% Usage: resRelObj=invselfjoinwithfilter(inpRelObj,sepByFieldList,...
%            combField,valueField,filterToFieldRel,varargin)
%
% Input:
%   regular:
%     inpRelObj: ARelation [1,1] - class object with relation to which 
%        inverse to self join is to be applied
%
%     sepByFieldList (joinByFieldList): char cell [1,nSepFields] - list of 
%        names for fields of inpRelObj relation by which separation of tuples 
%       (inverse to join) is performed
%   
%     combField(filterField): char - name of field in combToFieldRel 
%        relation such that different value fields (i.e. the fields of 
%        inpRelObj such that
%        their names are not equal to fields from sepByFieldList) are
%        represented in resRelObj for each tuple by different tuples, 
%        this field containing identifier of value field and single value
%        field with value of the corresponding field
%
%     valueField: char - name of value field in resRelObj
%
%     combToFieldRel: ARelation [1,1] - class object with relation that
%        determines parameters of inverse to self join; it is assumed that
%        combToFieldRel must contain at least fields with names given by
%        combField and fieldNameListField and that all these fields have
%        unique values for all tuples in combToFieldRel relation; after
%        inverse join value fields corresponding to each tuple in inpRelObj
%        are represented by several tuples in resRelObj with field whose
%        name is given by combField having values equal to values
%        determined by values of the same field in combToFieldRel when
%        name of each value field in inpRelObj coincides with value of
%        field in combToFieldRel whose name is given by fieldNameListField
%
%   properties:
%     combDescr: char - description for field with name determined by
%        combField; by default, it is empty
%     valueDescr: char - description for field with name determined by
%        valueField; by default, it is empty
%     fieldNameListField: char - name of field in combToFieldRel that
%        determines names of value fields in inpRelObj
%
%
% Output:
%   regular:
%     resRelObj: ARelation [1,1] - class object obtained from inpRelObj as
%        result of inverse to self join
%
% Note: 1) All fields in inpRelObj are divided on two groups: fields from
%          sepByFieldList and value fields not contained in previous group;
%          it is assumed that all value fields are of the same type
%       2) resRelObj contains fields from sepByFieldList, field with name
%          equal to combField and single value field with name equal to
%          valueField
%       3) It is assumed that field fieldNameListField from combToFieldRel
%          contains tuples with all names of value fields in inpRelObj
%          relation.
%
% Example:
%   ---Input:
%        ------ inpRelObj= 
%       'inst_id'    'inst_name'    'AAA'           'BBB'       
%       [1]          'NULL'         [1x2 double]    'NULL'      
%       [1]          'aaa'          'NULL'          [1x2 double]
%
%        -----  sepByFieldList= {'inst_id'    'inst_name'}
%
%        ----   combField =  'metric_id'
%
%        ----   valueField = 'metric_value'
%                   
%        ----   combToFieldRel =
%       'metric_id'    'field_name_list'    'field_descr_list'
%       [1]            'AAA'                'AAAA'            
%       [2]            'BBB'                'BBBB'      
% 
%       ------ combDescr = 'metric_id'
%       ------ valueDescr ='metric_value'
%       ------- fieldNameListField = 'field_name_list
%
%  ---Output:
%      ------resRelObj=
%      'inst_id'    'inst_name'    'metric_id'    'metric_value'
%       [1]          'NULL'         [1]            [1x2 double]  
%       [1]          'NULL'         [2]            'NULL'        
%       [1]          'aaa'          [1]            'NULL'        
%       [1]          'aaa'          [2]            [1x2 double]  
%       [2]          'NULL'         [1]            [1x2 double]  
%       [2]          'NULL'         [2]            'NULL'        
%       [2]          'bbb'          [1]            'NULL'        
%       [2]          'bbb'          [2]            [1x2 double]  
%       [3]          'ccc'          [1]            'NULL'        
%       [3]          'ccc'          [2]            [1x2 double]  
%       
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-04-15 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
%% Input parameters
[~,prop]=modgen.common.parseparams(varargin,[],0);
nProp=length(prop);
%
combDescr='';
valueDescr='';
fieldNameListField='';
%
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'combdescr',
            combDescr=prop{k+1};
        case 'valuedescr',
            valueDescr=prop{k+1};
        case 'fieldnamelistfield',
            fieldNameListField=prop{k+1};
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'unidentified property name: %s ',prop{k});
    end;
end;
%
if (combToFieldRel.getNTuples()==0)
    error([upper(mfilename),':wrongInput'],...
        'Not empty combToFieldRel relation expected');
end
%
%% retrieve value fields
allFieldList=inpRelObj.getFieldNameList();
[valueFieldNameList indField]=setdiff(allFieldList,sepByFieldList);
if isempty(valueFieldNameList),
    error([upper(mfilename),':wrongInput'],...
        'inpRelObj relation must contain at least one field not from sepByFieldList');
end
allFieldTypes=inpRelObj.getFieldTypeList();
valueFieldTypeList=allFieldTypes(indField);
if (length(valueFieldTypeList)>1)&&~isequal(valueFieldTypeList{:},valueFieldTypeList{1}),
    error([upper(mfilename),':wrongInput'],...
        'All value fields in inpRelObj must be of the same type');
end
%    
%% check combToField relation
%check that combination key is actually a key
if ~combToFieldRel.isUniqueKey(combField)
    error([upper(mfilename),':wrongInput'], 'key field is expected to containt unique values');
end
%% Get values of combField in resRelObj
if isempty(fieldNameListField),
    fieldNameList=combToFieldRel.getFieldNameList();
    isField=~strcmp(fieldNameList,combField)&&...
        strcmp(combToFieldRel.getFieldTypeList().type,'char');
    if sum(isField)~=1,
        error([upper(mfilename),':wrongInput'],...
            'combToFieldRel must contain single field with names of value fields');
    end
    fieldNameListField=fieldNameList{isField};
end
[isField indField]=ismember(valueFieldNameList,combToFieldRel.(fieldNameListField));
if ~all(isField)||any(diff(sort(indField))==0),
        error([upper(mfilename),':wrongInput'],...
            'field %s in combToFieldRel must contain values coinciding with names of all value fields in inpRelObj',...
            fieldNameListField);
end
combKeyVec=combToFieldRel.(combField)(indField);
nKeys=length(combKeyVec);
%% Build SData and SIsNull
nTuples=inpRelObj.getNTuples();
SData=struct;
SIsNull=struct;
SIsValueNull=struct;
indComb=kron((1:nTuples).',ones(nKeys,1));
leadRelObj=inpRelObj.getTuples(indComb);
leadRelObj=smartdb.relations.DynamicRelation(leadRelObj);
leadRelObj.removeFields(valueFieldNameList{:});
nLeadFields=length(sepByFieldList);
for iField=1:nLeadFields,
    fieldName=sepByFieldList{iField};
    SData.(fieldName)=leadRelObj.(fieldName);
    SIsNull.(fieldName)=leadRelObj.getFieldIsNull(fieldName);
    SIsValueNull.(fieldName)=leadRelObj.getFieldIsValueNull(fieldName);
end
SData.(combField)=repmat(combKeyVec,nTuples,1);
SIsNull.(combField)=false(nKeys*nTuples,1);
SIsValueNull.(combField)=SIsNull.(combField);
%
valRelObj=smartdb.relations.DynamicRelation(inpRelObj);
valRelObj.removeFields(sepByFieldList{:});
[curSData curSIsNull curSIsValueNull]=valRelObj.getData();
fieldNameList=fieldnames(curSData);
curSData=reshape(struct2cell(curSData),1,[]);
curSIsNull=reshape(struct2cell(curSIsNull),1,[]);
curSIsValueNull=reshape(struct2cell(curSIsValueNull),1,[]);
[isField indField]=ismember(valueFieldNameList,fieldNameList);
curSData=curSData(indField);
curSIsNull=curSIsNull(indField);
curSIsValueNull=curSIsValueNull(indField);
%
curSData=reshape(horzcat(curSData{:}).',[],1);
curSIsNull=reshape(horzcat(curSIsNull{:}).',[],1);
curSIsValueNull=reshape(horzcat(curSIsValueNull{:}).',[],1);
%
SData.(valueField)=curSData;
SIsNull.(valueField)=curSIsNull;
SIsValueNull.(valueField)=curSIsValueNull;
%
fieldDescrList=[leadRelObj.getFieldDescrList {combDescr,valueDescr}];
fieldNameList=[sepByFieldList {combField,valueField}];
%% Construct resulting relation
resRelObj=smartdb.relations.DynamicRelation(SData,SIsNull,SIsValueNull,...
    'fieldNameList',fieldNameList,'fieldDescrList',fieldDescrList);
%resRelObj.toCell()