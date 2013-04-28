classdef ContinuousReachPlotTestCase < mlunitext.test_case
    
    properties (Access=private)
        reachObj
        color
        shade
        width
        isFill
    end
    
    methods
        
        function self = ContinuousReachPlotTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        
        function set_reach(self)
            sys = elltool.linsys.LinSysFactory.create([0, 1; 0, 0], eye(2),... 
                ell_unitball(2));
            self.reachObj = elltool.reach.ReachContinuous(sys, ell_unitball(2),...
                eye(2), [1 10]);
        end
        
        function set_prop_default(self, isExternal)
            self.isFill = false;
            self.width = 2;
            if isExternal
                self.color = [0, 0, 1];
                self.shade = 0.3;
            else
                self.color = [0, 1, 0];
                self.shade = 0.1; 
            end
        end

        function set_up_param(self, isEA)
            self.set_reach;
            self.set_prop_default(isEA);
        end
                
        function testPlotEA(self)
            self.set_up_param(true);
            
            plotObj = self.reachObj.plot_ea('color', [1, 0, 0]);
            self.color = [1, 0, 0];
            self.checkProp(plotObj);
            self.set_prop_default(true)
            
            plotObj = self.reachObj.plot_ea('shade', 0.5);
            self.shade = 0.5;
            self.checkProp(plotObj);
            self.set_prop_default(true);
            
            plotObj = self.reach.plot_ea('color', [1, 1, 0], 'shade', 0.7);
            self.color = [1, 1, 0];
            self.shade = 0.7;
            self.checkProp(plotObj);
            self.set_prop_default(true);
        end
        
        
        function testPlotIA(self)
            set_up_param(self, false);
            
            plotObj = self.reachObj.plot_ia('color', [1, 0, 0]);
            self.color = [1, 0, 0];
            self.checkProp(plotObj);
            self.set_prop_default(false)
            
            plotObj = self.reachObj.plot_ia('shade', 0.5);
            self.shade = 0.5;
            self.checkProp(plotObj);
            self.set_prop_default(false);
            
            plotObj = self.reach.plot_ea('color', [1, 1, 0], 'shade', 0.7);
            self.color = [1, 1, 0];
            self.shade = 0.7;
            self.checkProp(plotObj);
            self.set_prop_default(false);
        end
        
        function checkProp(self, plObj)
            SHandle =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
            [~, handleVecList] = modgen.struct.getleavelist(SHandle);
            handleVec = [handleVecList{:}];
            objCVec = get(handleVec, 'Children');
            curObj = objCVec{1}(3);
            
            reachColMat = get(curObj, 'FaceVertexCData');
            colMat = repmat(self.color, size(reachColMat, 1), 1);
            mlunit.assert_equals(reachColMat, colMat);
            
            reachShade = get(curObj, 'FaceAlpha');
            mlunit.assert_equals(reachShade, self.shade);
        end
    end
    
end
