nTubes=5;
nPoints = 100;
timeBeg=0;
timeEnd=1;
type = 2;
ellTubeObj=...
    gras.ellapx.smartdb.test.examples.getEllTube(nTubes,timeBeg,timeEnd,type,nPoints);
%
% get the list of field descriptions
%
descr = ellTubeObj.getFieldDescrList();
%
% get for given field a nested logical/cell array containing is-null 
% indicators for cell content. For example, for approxSchemaName field.
%
isNull = ellTubeObj.getFieldIsNull('approxSchemaName');
%
% get for given field logical vector determining whether value of this 
% field in each cell is null or not. For example, for approxSchemaName field.
%
valueIsNull = ellTubeObj.getFieldIsValueNull('approxSchemaName');
%
% get the list of field names
%
name = ellTubeObj.getFieldNameList();
%
% project object with specified fields. For example, with fields that are
% not to be cut or concatenated.
%
nameList = ellTubeObj.getNoCatOrCutFieldsList();
proj = ellTubeObj.getFieldProjection(nameList);
%
% get the list of field types
%
type = ellTubeObj.getFieldTypeList();
%
% get the list of field type specifications. Field type specification is a 
% sequence of type names corresponding to field value types starting with 
% the top level and going down into the nested content of a field (for a 
% field having a complex type).
%
typeSpec = ellTubeObj.getFieldTypeSpecList();
% or
typeSpec = ellTubeObj.getFieldTypeSpecList(nameList);
%
% get a matrix composed from the size vectorsfor the specified fields
%
valueSizeMat = ellTubeObj.getFieldValueSizeMat(nameList);
%
% get a vector indicating whether a particular field is composed of null 
% values completely
%
valueNull = ellTubeObj.getIsFieldValueNull(nameList);
%
% get a size vector for the specified dimensions. If no dimensions are 
% specified, a size vector for all dimensions up to minimum dimension is 
% returned
minDimensionSize = ellTubeObj.getMinDimensionSize();
%
% get a minimum dimensionality for a given object
%
minDimensionality = ellTubeObj.getMinDimensionality();
%
% get a number of elements in a given object
%
nElems = ellTubeObj.getNElems();
%
% get a number of fields in a given object
%
nFiedls = ellTubeObj.getNFields();
%
% get a number of tuples in a given object
%
nTuples = ellTubeObj.getNTuples();
%
% get sort index for all tuples of given relation with respect to some of 
% its fields
%
sortIndex = ellTubeObj.getSortIndex(nameList);
% also we can specify the direction of sorting ('asc' or 'desc')
sortIndex = ellTubeObj.getSortIndex(nameList,'Direction','asc');
%
% get tuples with given indices from given relation
%
tuples = ellTubeObj.getTuples([1,2,3]);
%
% get tuples from given relation such that afixed index field contains 
% values from a given set of value
%
filteredTuples = ellTubeObj.getTuplesFilteredBy('sTime', 1);
%
% get internal representation for a set of unique tuples for given relation
%
uniqueData = ellTubeObj.getUniqueData();
%
% get a relation containing the unique tuples from the original relation
%
uniqueTuples = ellTubeObj.getUniqueTuples();
