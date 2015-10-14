classdef IControlVectFunction<handle
    methods (Abstract)
        res=evaluate(self,x,timeVec)
    end
end