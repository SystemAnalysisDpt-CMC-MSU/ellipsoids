function inferFieldMetaData(self,fieldNameList)
if nargin==1
    fieldNameList=fieldnames(self.SData).';
end
if ischar(fieldNameList)
    fieldNameList={fieldNameList};
end
fieldDescrList=fieldNameList;
nFields=length(fieldNameList);
%
smartdb.cubes.CubeStructFieldInfoBuilder.flush();
smartdb.cubes.CubeStructFieldInfoBuilder.setCubeStructRef(self);
smartdb.cubes.CubeStructFieldInfoBuilder.setNameList(fieldNameList);
smartdb.cubes.CubeStructFieldInfoBuilder.setDescrList(fieldDescrList);
self.fieldMetaData=smartdb.cubes.CubeStructFieldInfoBuilder.build();
smartdb.cubes.CubeStructFieldInfoBuilder.flush();
%
for iField=1:nFields
    fieldName=fieldNameList{iField};
    setTypeFromValue(self.getFieldMetaData(fieldName),self.SData.(fieldName));
end