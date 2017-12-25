classdef TReachObjFactory
   methods (Static, Access = public)
       function resObjVec = createInstance(className, varargin)
           import elltool.reach.test.mlunit.*;
           switch className
               case 'reachContinuous'
                   resObjVec = TReachContinuous(varargin{:});
               case 'reachDiscrete'
                   resObjVec = TReachDiscrete(varargin{:});
               otherwise
                   modgen.common.throwerror('wrongInput', ...
                       'Class name is unknown: %s', className);
           end
       end
   end
end