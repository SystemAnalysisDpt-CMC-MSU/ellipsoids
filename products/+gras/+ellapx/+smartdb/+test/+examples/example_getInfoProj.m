ellProjObj = gras.ellapx.smartdb.test.examples.example_getProj();
%
% get the list of field descriptions
%
descr = ellProjObj.getFieldDescrList();
%
% get for given field a nested logical/cell array containing is-null 
% indicators for cell content. For example, for approxSchemaName field.
%
isNull = ellProjObj.getFieldIsNull('approxSchemaName');
%
% get for given field logical vector determining whether value of this 
% field in each cell is null or not. For example, for approxSchemaName field.
%
valueIsNull = ellProjObj.getFieldIsValueNull('approxSchemaName');
%
% get the list of field names
%
name = ellProjObj.getFieldNameList();
%
% project object with specified fields. For example, with fields that are
% not to be cut or concatenated.
%
nameList = ellProjObj.getNoCatOrCutFieldsList();
proj = ellProjObj.getFieldProjection(nameList);
%
% get the list of field types
%
type = ellProjObj.getFieldTypeList();
%
% get the list of field type specifications. Field type specification is a 
% sequence of type names corresponding to field value types starting with 
% the top level and going down into the nested content of a field (for a 
% field having a complex type).
%
typeSpec = ellProjObj.getFieldTypeSpecList();
% or
typeSpec = ellProjObj.getFieldTypeSpecList(nameList);
%
% get a matrix composed from the size vectorsfor the specified fields
%
valueSizeMat = ellProjObj.getFieldValueSizeMat(nameList);
%
% get a vector indicating whether a particular field is composed of null 
% values completely
%
valueNull = ellProjObj.getIsFieldValueNull(nameList);
%
% get a size vector for the specified dimensions. If no dimensions are 
% specified, a size vector for all dimensions up to minimum dimension is 
% returned
minDimensionSize = ellProjObj.getMinDimensionSize();
%
% get a minimum dimensionality for a given object
%
minDimensionality = ellProjObj.getMinDimensionality();
%
% get a number of elements in a given object
%
nElems = ellProjObj.getNElems();
%
% get a number of fields in a given object
%
nFiedls = ellProjObj.getNFields();
%
% get a number of tuples in a given object
%
nTuples = ellProjObj.getNTuples();
%
% get sort index for all tuples of given relation with respect to some of 
% its fields
%
sortIndex = ellProjObj.getSortIndex(nameList);
% also we can specify the direction of sorting ('asc' or 'desc')
sortIndex = ellProjObj.getSortIndex(nameList,'Direction','asc');
%
% get tuples with given indices from given relation
%
tuples = ellProjObj.getTuples(1);
%
% get tuples from given relation such that afixed index field contains 
% values from a given set of value
%
filteredTuples = ellProjObj.getTuplesFilteredBy('sTime', 1);
%
% get internal representation for a set of unique tuples for given relation
%
uniqueData = ellProjObj.getUniqueData();
%
% get a relation containing the unique tuples from the original relation
%
uniqueTuples = ellProjObj.getUniqueTuples();
