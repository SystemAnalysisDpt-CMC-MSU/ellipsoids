classdef ProbDefUncertTC < ...
    gras.ellapx.lreachplain.probdef.test.mlunit.ProbDefPlainTC
    
    methods
        function self=ProbDefUncertTC(varargin)
            self = self@gras.ellapx.lreachplain.probdef.test.mlunit.ProbDefPlainTC(varargin{:});
        end
        
        function set_up_param(self, fConstructor, fConfReader)
            self.readObj = fConfReader();
            params = self.readObj.getUncertParams();
            self.pdefObj = fConstructor(params{:});
        end
        
        function testGetters(self)
            self.testGetters@gras.ellapx.lreachplain.probdef.test.mlunit.ProbDefPlainTC();
            
            self.assertCellEquals(self.readObj.cCMat,...
                self.pdefObj.getCMatDef());
            self.assertCellEquals(self.readObj.qCVec,...
                self.pdefObj.getqCVec());
            self.assertCellEquals(self.readObj.qCMat,...
                self.pdefObj.getQCMat());
        end
    end
end