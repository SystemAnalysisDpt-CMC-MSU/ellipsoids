classdef PrameterizedTC < mlunitext.test_case
    properties (Access=private)
        secretProperty
    end
    methods
        function self = PrameterizedTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function set_up_param(self, varargin)
            import modgen.common.throwerror;
            nArgs = numel(varargin);
            if nArgs == 1
                self.secretProperty = varargin{1};
            elseif nArgs > 1
                throwerror('wrongInput','Too many parameters');
            end
        end
        %
        function testSecretProperty(self)
            SECRET_VALUE=247;
            if ~isequal(self.secretProperty,SECRET_VALUE)
                if isempty(self.secretProperty)
                    actualVal=nan;
                else
                    actualVal=self.secretProperty;
                end
                %
                modgen.common.throwerror('wrongInput',...
                    ['wrong value of secret propety,\n',...
                    'expected %d but received %d'],...
                    SECRET_VALUE,actualVal);
            end
        end
    end
end