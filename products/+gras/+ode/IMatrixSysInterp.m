classdef IMatrixSysFunction < handle
    methods(Abstract)
        resArrayList = evaluate(newTimeVec);
    end
    
end

