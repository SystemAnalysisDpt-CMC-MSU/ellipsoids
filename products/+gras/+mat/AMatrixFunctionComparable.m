classdef AMatrixFunctionComparable < gras.mat.IMatrixFunction
    properties 
        absTol
        relTol;
    end
    
    methods     
        function isOk = isequal(matObj1,matObj2)
            isOk = matObj1.isEqual(matObj2);
        end
    end
    
    methods(Abstract)
        [isOk, reportStr] = isEqual(matObj1,matObj2);
    end
    
    methods 
        SData = toStructInternal(self,isPropIncluded);
    end
    
    methods
        function abstolval = getAbsTol(varargin)
            abstolval = 'absTol';
        end;
        function reltolval = getRelTol(varargin)
            reltolval = 'relTol';
        end;
    end
end