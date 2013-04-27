classdef ContinuousReachPlotTestCase < mlunitext.test_case
    
    properties (Access=private)
        reachObj
    end
    
    methods
        
        function self = ContinuousReachPlotTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
         end

        function self = set_up_param(self)
            sys = elltool.linsys.LinSysFactory.create([0, 1; 0, 0], eye(2),... 
                ell_unitball(2));
            self.reachObj = elltool.reach.ReachContinuous(sys, ell_unitball(2),...
                eye(2), [1 10]);
        end
        
                
        function check2dCol(self, plObj, colMat)

            SHandle =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
            [~, handleVecList] = modgen.struct.getleavelist(SHandle);
            handleVec = [handleVecList{:}];
            objCVec = get(handleVec, 'Children');
            curObj = objCVec{1}(3);
            
            reachColMat = get(curObj, 'FaceVertexCData');
            colMat = repmat(colMat, size(reachColMat, 1), 1);
            mlunit.assert_equals(reachColMat, colMat);
            
%             reachShade = get(curObj, 'FaceAlpha');
%             mlunit.assert_equals(reachColMat, colMat);
        end
        
        function self = testPlotEA(self)
            self = set_up_param(self);
            plotObj = self.reachObj.plot_ea('color', [1, 0, 0]);
            self.check2dCol(plotObj, [1, 0, 0]);
        end
    end
    
end
