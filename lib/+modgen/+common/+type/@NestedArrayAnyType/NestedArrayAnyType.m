classdef NestedArrayAnyType<modgen.common.type.ANestedArrayUnknownType
    methods 
        function isPositive=isIncludedInto(~,obj)
            if isa(obj,'modgen.common.type.NestedArrayAnyType')
                isPositive=true;
            else
                isPositive=false;
            end
        end
    end
    methods
        function isPositive=isCompleteTypeSet(~)
            isPositive=true;
        end        
        function isPositive=isContainedInCellType(~)
            isPositive=false;
        end        
        function isPositive=isCellTypeContained(~)
            isPositive=true;
        end
        function typeSeqString=toTypeSequenceString(~)
            typeSeqString='any';
        end
    end
end
