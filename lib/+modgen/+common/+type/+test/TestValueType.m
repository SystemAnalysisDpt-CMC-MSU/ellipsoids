classdef TestValueType
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=protected)
        value
    end
    %
    methods
        function display(self)
            fprintf('CurValue (size: %s, value: %s) \n',...
                mat2str(size(self)),...
                mat2str(reshape([self.value],size(self))));
        end
        function self=TestValueType(value)
            if nargin==1
                if numel(value)==1
                    if isnumeric(value)
                        self.value=value;
                    elseif isa(value,'modgen.common.type.test.TestValueType')
                        self=value;
                    else
                        error([upper(mfilename),':wrongInput'],...
                            'unsupported way to create an object');
                    end
                else
                    error([upper(mfilename),':wrongInput'],...
                        'vectorial type is not supported');
                end
            elseif nargin==0
                self.value=0;
            end
        end
            
    end
    
end
