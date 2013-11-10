classdef IMatrixSysInterp < handle
    methods(Abstract)
        resArray = evaluate(newTimeVec);
    end
    
end

