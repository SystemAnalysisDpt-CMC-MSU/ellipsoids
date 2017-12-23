classdef TEllipsoidFactory
   methods (Static, Access = public)
       function resObjVec = createInstance(className, varargin)
           import elltool.core.test.mlunit.*;
           switch className
               case 'ellipsoid'
                   resObjVec = TEllipsoid(varargin{:});
               case 'GenEllipsoid'
                   resObjVec = TGenEllipsoid(varargin{:});
               otherwise
                   modgen.common.throwerror('wrongInput', ...
                       'Class name is unknown: %s', className);
           end
       end
   end
end