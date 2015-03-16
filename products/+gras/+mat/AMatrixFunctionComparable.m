classdef AMatrixFunctionComparable < IMatrixFunction
    properties 
        absTol;
        relTol;
    end
    
    methods
        function isOk=isequal(self,otherObj)
            [isEqualArr, reportStr] = isEqual(self,otherObj);
            isOk = prod(isEqualArr);
        end
    end
    
    methods(Abstract)
        isEqual(~);
    end
end