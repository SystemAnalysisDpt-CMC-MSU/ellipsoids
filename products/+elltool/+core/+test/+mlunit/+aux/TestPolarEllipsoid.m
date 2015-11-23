classdef TestPolarEllipsoid < elltool.core.AGenEllipsoid
   methods
       function self=TestPolarEllipsoid(varargin)    
       end
       function polarObj = getScalarPolarTest(~,ell,isRobustMethod)
           polarObj = ell.getScalarPolarInternal(isRobustMethod);
       end
   end
   methods (Access = protected, Static)
       formCompStruct(SEll,SFieldNiceNames,absTol,isPropIncluded)
   end
end