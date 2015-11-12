classdef TestEllipsoid < elltool.core.AGenEllipsoid
   methods
       function self=TestEllipsoid(varargin)    
       end
       function polarObj = getScalarPolarTest(~, ell, isRobustMethod)
           polarObj = getScalarPolarInternal(ell, isRobustMethod);
       end
   end
   methods (Access = protected, Static)
       formCompStruct(SEll, SFieldNiceNames, absTol, isPropIncluded)
   end
end