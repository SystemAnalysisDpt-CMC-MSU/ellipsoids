classdef VecOdeRegInterpInverseTimeWrapper < gras.ode.IVecOdeRegInterp
    % VecOdeRegInterpInverseTimeWrapper - auxiliary class to handle 
    % inverse time interpolation intervals
    
    properties (Access = private)
        interpObj
    end
    
    methods
        function wrapper = VecOdeRegInterpInverseTimeWrapper(interpObj)
            wrapper.interpObj = interpObj;
        end
        
        function [tOutVec, yOutMat, dyRegMat] = evaluate(self, timeVec)
            [tOutVec, yOutMat, dyRegMat] = ...
                self.interpObj.evaluate(-timeVec);
            tOutVec = -tOutVec;
        end
        
        function [tStart] = getTStart(self)
            tStart = -self.interpObj.getTEnd();
        end
        
        function [tEnd] = getTEnd(self)
            tEnd = -self.interpObj.getTStart();
        end
    end
    
end

