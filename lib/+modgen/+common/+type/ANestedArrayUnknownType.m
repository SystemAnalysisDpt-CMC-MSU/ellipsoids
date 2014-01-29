classdef ANestedArrayUnknownType<modgen.common.type.ANestedArrayType
    
    methods
        function classNameList=toClassName(STypeInfo)
            classNameList={};
        end         
    end
    methods (Access=protected)
        function STypeInfo=getValueTypeStruct(self)
            STypeInfo=struct('type','double','depth',0);
        end
    end
end
