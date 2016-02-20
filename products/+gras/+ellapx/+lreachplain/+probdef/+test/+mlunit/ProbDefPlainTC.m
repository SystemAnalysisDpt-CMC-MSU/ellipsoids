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
            
            self.assert_cell_equals(self.readObj.aCMat,...
                self.pdefObj.getAMatDef());
            self.assert_cell_equals(self.readObj.bCMat,...
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
            
            self.assert_cell_equals(self.readObj.pCVec,...
                self.pdefObj.getpCVec());
            self.assert_cell_equals(self.readObj.pCMat,...
                self.pdefObj.getPCMat());
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
                isEqual = all(c1==c2);
            elseif iscell(c1)
                isEqual = all(cellfun(@(x, y) cellcmp(x, y), c1, c2));
            else
                isEqual = all(c1==c2);
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

%function isSC = isSubClass(obj, className)
%    isSC = any(cellfun(@(sc) stcmp(sc, className), superclasses(obj)));
%end