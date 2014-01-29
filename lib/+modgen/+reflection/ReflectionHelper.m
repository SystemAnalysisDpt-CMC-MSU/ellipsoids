classdef ReflectionHelper<handle
    %REFLECTIONHELPER - serves a single purpose: retrieving a name of 
    %                   currently constructed object
    methods
        function self=ReflectionHelper(valBox)
            if ~isa(valBox,'modgen.containers.ValueBox')
                error([upper(mfilename),':wrongInput'],...
                    'Input is expected to be a boxed value object');
            end
            valBox.setValue(metaclass(self));
        end
    end
end