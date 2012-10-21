classdef SuiteNegative < mlunitext.test_case
    %mlunitext.test_case
    properties (Access=private)
        crm
    end
    methods
        function self = SuiteNegative(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self = set_up_param(self)
            self.crm=modgen.configuration.test.AdpConfRepoMgrNegative();
        end        
        function test_negativeSelectConf(self)
            inpArgList={'default'};
            crm=self.crm;
            self.runAndCheckError('crm.selectConf(inpArgList{:})',...
                ':artificialPatchApplicationError','causeCheckDepth',inf);
            self.runAndCheckError('crm.selectConf(inpArgList{:})',...
                ':wrongInput','causeCheckDepth',0);            
        end
    end
end