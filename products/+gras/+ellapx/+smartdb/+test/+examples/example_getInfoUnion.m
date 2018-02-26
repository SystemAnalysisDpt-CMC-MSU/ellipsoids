ellUnionObj = gras.ellapx.smartdb.test.examples.getUnion();
%
% get the list of field descriptions
%
descr = ellUnionObj.getFieldDescrList();
%
% get for given field a nested logical/cell array containing is-null 
% indicators for cell content. For example, for approxSchemaName field.
%
isNull = ellUnionObj.getFieldIsNull('approxSchemaName');
%
% get for given field logical vector determining whether value of this 
% field in each cell is null or not. For example, for approxSchemaName field.
%
valueIsNull = ellUnionObj.getFieldIsValueNull('approxSchemaName');
%
% get the list of field names
%
name = ellUnionObj.getFieldNameList();
%
% project object with specified fields. For example, with fields that are
% not to be cut or concatenated.
%
nameList = ellUnionObj.getNoCatOrCutFieldsList();
proj = ellUnionObj.getFieldProjection(nameList);
%
% get the list of field types
%
type = ellUnionObj.getFieldTypeList();
%
% get the list of field type specifications. Field type specification is a 
% sequence of type names corresponding to field value types starting with 
% the top level and going down into the nested content of a field (for a 
% field having a complex type).
%
typeSpec = ellUnionObj.getFieldTypeSpecList(); %#ok<NASGU>
% or
typeSpec = ellUnionObj.getFieldTypeSpecList(nameList);
%
% get a matrix composed from the size vectorsfor the specified fields
%
valueSizeMat = ellUnionObj.getFieldValueSizeMat(nameList);
%
% get a vector indicating whether a particular field is composed of null 
% values completely
%
valueNull = ellUnionObj.getIsFieldValueNull(nameList);
%
% get a size vector for the specified dimensions. If no dimensions are 
% specified, a size vector for all dimensions up to minimum dimension is 
% returned
minDimensionSize = ellUnionObj.getMinDimensionSize();
%
% get a minimum dimensionality for a given object
%
minDimensionality = ellUnionObj.getMinDimensionality();
%
% get a number of elements in a given object
%
nElems = ellUnionObj.getNElems();
%
% get a number of fields in a given object
%
nFiedls = ellUnionObj.getNFields();
%
% get a number of tuples in a given object
%
nTuples = ellUnionObj.getNTuples();
%
% get sort index for all tuples of given relation with respect to some of 
% its fields
%
sortIndex = ellUnionObj.getSortIndex(nameList); %#ok<NASGU>
% also we can specify the direction of sorting ('asc' or 'desc')
sortIndex = ellUnionObj.getSortIndex(nameList,'Direction','asc');
%
% get tuples with given indices from given relation
%
tuples = ellUnionObj.getTuples([1,2,3]);
%
% get tuples from given relation such that afixed index field contains 
% values from a given set of value
%
filteredTuples = ellUnionObj.getTuplesFilteredBy('sTime', 1);
%
% get internal representation for a set of unique tuples for given relation
%
uniqueData = ellUnionObj.getUniqueData();
%
% get a relation containing the unique tuples from the original relation
%
uniqueTuples = ellUnionObj.getUniqueTuples();
