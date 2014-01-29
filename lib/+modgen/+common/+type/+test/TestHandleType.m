classdef TestHandleType<handle
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
        function setValue(self,value)
            if numel(self)~=1
                error([upper(mfilename),':wrongInput'],...
                    'method is not supported for a vectorial objects');
            end
            if numel(value)~=1
                error([upper(mfilename),':wrongInput'],...
                    'input value should be scalar');
            end
            self.value=value;
        end
        function value=getValue(self)
            value=self.value;
        end
        function self=TestHandleType(value)
            if nargin==1
                if numel(value)==1
                    if isnumeric(value)
                        self.value=value;
                    elseif isa(value,'modgen.common.type.test.TestHandleType')
                        self.value=value.value;
                    else
                        error([upper(mfilename),':wrongInput'],...
                            'unsupported way to create an object');
                    end
                else
                    error([upper(mfilename),':wrongInput'],...
                        'vectorial input is not supported');
                end
            elseif nargin==0
                self.value=0;
            end
        end
            
    end
    
end
