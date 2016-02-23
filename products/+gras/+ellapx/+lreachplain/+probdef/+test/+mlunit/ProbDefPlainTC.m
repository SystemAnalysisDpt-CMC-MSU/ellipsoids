classdef ProbDefPlainTC < mlunitext.test_case
    properties (Access=protected)
        readObj
        pdefObj
    end
    
    methods
        function self = ProbDefPlainTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function set_up_param(self, fDefConstr, fConfReader)
            self.readObj = fConfReader();
            params = self.readObj.getPlainParams();
            self.pdefObj = fDefConstr(params{:});
        end
        
        function testGetters(self)            
            mlunitext.assert_equals(size(self.readObj.aCMat, 2),...
                self.pdefObj.getDimensionality());
            
            self.assertCellEquals(self.readObj.aCMat,...
                self.pdefObj.getAMatDef());
            self.assertCellEquals(self.readObj.bCMat,...
                self.pdefObj.getBMatDef());
            
            mlunitext.assert_equals(self.readObj.x0Mat,...
                self.pdefObj.getX0Mat());
            mlunitext.assert_equals(self.readObj.x0Vec,...
                self.pdefObj.getx0Vec());
            
            tVec = self.pdefObj.getTimeLimsVec();
            t0 = self.pdefObj.gett0();
            t1 = self.pdefObj.gett1();
            mlunitext.assert_equals(self.readObj.tLims, tVec);
            mlunitext.assert_equals(tVec(1), t0);
            mlunitext.assert_equals(tVec(2), t1);
            
            self.assertCellEquals(self.readObj.pCVec,...
                self.pdefObj.getpCVec());
            self.assertCellEquals(self.readObj.pCMat,...
                self.pdefObj.getPCMat());
        end
    end
    
    methods(Static)
        function assertCellEquals(expectedCMat, actualCMat, msg)
            if nargin < 3
                mlunitext.assert(isequal(expectedCMat, actualCMat));
            else
                mlunitext.assert(isequal(expectedCMat, actualCMat), msg);
            end
        end
    end
end