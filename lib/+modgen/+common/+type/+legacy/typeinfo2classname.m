function classNameList=typeinfo2classname(STypeInfo)
%
STypeInfo=modgen.common.type.NestedArrayType.fromStruct(STypeInfo);
classNameList=STypeInfo.toClassName();