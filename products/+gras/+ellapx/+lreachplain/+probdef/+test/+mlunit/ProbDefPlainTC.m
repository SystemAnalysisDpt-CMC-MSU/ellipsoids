classdef ProbDefPlainTC < mlunitext.test_case
    properties (Access=protected)
        readObj
        probObj
    end
    
    methods
        function self = ProbDefPlainTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function set_up_param(self, fConstructor, confName, crm, crmSys)
            import gras.ellapx.lreachplain.probdef.test.mlunit.ProbDefConfigReader;
            self.readObj = ProbDefConfigReader(confName, crm, crmSys);
            params = self.readObj.getPlainParams();
            
            self.probObj = fConstructor(params{:});
        end
        
        function testGetters(self)            
            mlunitext.assert_equals(length(self.readObj.aCMat),...
                self.probObj.getDimensionality());
            
            self.assert_cell_equals(self.readObj.aCMat,...
                self.probObj.getAMatDef());
            self.assert_cell_equals(self.readObj.bCMat,...
                self.probObj.getBMatDef());
            
            mlunitext.assert_equals(self.readObj.x0Mat,...
                self.probObj.getX0Mat());
            mlunitext.assert_equals(self.readObj.x0Vec,...
                self.probObj.getx0Vec());
            
            tVec = self.probObj.getTimeLimsVec();
            t0 = self.probObj.gett0();
            t1 = self.probObj.gett1();
            mlunitext.assert_equals(size(tVec), [1 2]);
            mlunitext.assert_equals(tVec(1), t0);
            mlunitext.assert_equals(tVec(2), t1);
            
            self.assert_cell_equals(self.readObj.pCVec,...
                self.probObj.getpCVec());
            self.assert_cell_equals(self.readObj.pCMat,...
                self.probObj.getPCMat());
        end
    end
    
    methods(Static)
        function isEqual=cellcmp(c1, c2)
            import gras.ellapx.lreachplain.probdef.test.mlunit.ProbDefPlainTC.cellcmp;
            if ~all(size(c1) == size(c2)) || ~isa(c1, class(c2))
                isEqual = false;
                return
            end
            if ischar(c1)
                isEqual = strcmp(c1, c2);
            elseif isnumeric(c1)
                isEqual = all(c1 == c2);
            elseif iscell(c1)
                isEqual = all(cellfun(@(x, y) cellcmp(x, y), c1, c2));
            else
                isEqual = c1==c2;
            end
        end
        
        function assert_cell_equals(c1, c2, msg)
            import gras.ellapx.lreachplain.probdef.test.mlunit.ProbDefPlainTC.cellcmp;
            if nargin < 3
                mlunitext.assert(cellcmp(c1, c2));
            else
                mlunitext.assert(cellcmp(c1, c2, msg));
            end
        end
    end
end