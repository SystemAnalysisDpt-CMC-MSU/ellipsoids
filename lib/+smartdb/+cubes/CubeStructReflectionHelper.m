classdef CubeStructReflectionHelper<modgen.reflection.ReflectionHelper
    %CUBESTRUCTREFLECTIONHELPER - serves a single purpose: retrieving a name
    %                             of currently constructed object
    methods
        function self=CubeStructReflectionHelper(valBox)
            self=self@modgen.reflection.ReflectionHelper(valBox);
            value=valBox.getValue();
            valBox.setValue(value.Name);
        end
    end
end