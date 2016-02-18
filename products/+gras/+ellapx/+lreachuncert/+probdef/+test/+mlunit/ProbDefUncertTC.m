classdef ProbDefUncertTC < ...
    gras.ellapx.lreachplain.probdef.test.mlunit.ProbDefPlainTC
    
    methods
        function self=ProbDefUncertTC(varargin)
            self = self@gras.ellapx.lreachplain.probdef.test.mlunit.ProbDefPlainTC(varargin{:});
        end
        
        function set_up_param(self, fConstructor, confName, crm, crmSys)
            import gras.ellapx.lreachplain.probdef.test.mlunit.ProbDefConfigReader;
            self.readObj = ProbDefConfigReader(confName, crm, crmSys);
            params = self.readObj.getUncertParams();
            
            self.probObj = fConstructor(params{:});
        end
        
        function testGetters(self)
            self.testGetters@gras.ellapx.lreachplain.probdef.test.mlunit.ProbDefPlainTC();
            
            self.assert_cell_equals(self.readObj.cCMat,...
                self.probObj.getCMatDef());
            self.assert_cell_equals(self.readObj.qCVec,...
                self.probObj.getqCVec());
            self.assert_cell_equals(self.readObj.qCMat,...
                self.probObj.getQCMat());
        end
    end
end