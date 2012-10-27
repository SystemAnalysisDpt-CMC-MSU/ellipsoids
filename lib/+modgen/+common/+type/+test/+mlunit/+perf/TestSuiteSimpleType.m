classdef TestSuiteSimpleType < mlunitext.test_case
    properties
    end
    
    methods
        function self = TestSuiteSimpleType(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = set_up_param(self,varargin)
            
        end
        function aux_legacy(~,inpArray)
            isnumeric(inpArray)||ischar(inpArray)||...
                modgen.common.isrow(inpArray)||isdouble(inpArray)||...
                iscellstr(inpArray)||isa(inpArray,'int32');
        end
        function aux_simpleexp(~,inpArray)
            modgen.common.type.simple.checkgen(inpArray,...
                ['isnumeric(x)||ischar(x)||isrow(x)||',...
            'isdouble(x)||iscellofstrvec(x)||isa(x,''int32'')']);
        end
        function self=test_check(self)
            N_RUNS=100;
            inpArray={'alpha','beta','gamma'};
            self.runAndCheckTime('aux_legacy(self,inpArray)','legacy','nRuns',N_RUNS);
            self.runAndCheckTime('aux_simpleexp(self,inpArray)','simpleexp','nRuns',N_RUNS);
            %

        end
    end
end