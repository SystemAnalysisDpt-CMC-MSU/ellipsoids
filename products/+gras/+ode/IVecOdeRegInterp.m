classdef IVecOdeRegInterp
    %IVecOdeRegInterp - Interface for interpolators of ODE solution
    
    methods (Abstract)
        evaluate(self, timeVec)
        % evaluate - produce interpolation of the solution in points
        % specified by timeVec
        
        getTStart(self)
        % getTStart - returns begin of the interpolation interval
        
        getTEnd(self)
        % getTStart - returns end of the interpolation interval
    end
    
end

