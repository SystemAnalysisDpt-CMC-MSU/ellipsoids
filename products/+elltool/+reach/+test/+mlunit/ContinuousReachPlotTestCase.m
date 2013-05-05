classdef ContinuousReachPlotTestCase < mlunitext.test_case
    
    properties (Access=private)
        reachObj
    end
    
    methods
        
        function self = ContinuousReachPlotTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            self.reachObj = getReach;
        end
        
        function self = tear_down(self,varargin)
            close all;
        end     
        
        function testNegative(self)
            reachObj = self.reachObj;
            self.runAndCheckError...
                ('reachObj.plot_ea(''LineWidth'', 2)','wrongProperty');
            close all;
            self.runAndCheckError...
                ('reachObj.plot_ia(''color'', ''l'')', 'wrongColorChar');
            close all;
            self.runAndCheckError...
                ('reachObj.plot_ea(''color'', [0, 0, 1, 0])',...
                'wrongColorVecSize');
            close all;
            self.runAndCheckError...
                ('reachObj.plot_ia(''color'', [0, 1, 0], ''r'')',...
                'ConflictingColor');
            close all;
        end
        
        function testPlotEA(self)
            self.checkPlot(true);
        end
        
        function testPlotIA(self)
            self.checkPlot(false);
        end
        
        function checkPlot(self, isExternal)            
            if isExternal            
                plotObj = self.reachObj.plot_ea('color', [1, 0, 0]);
            else
                plotObj = self.reachObj.plot_ia('color', [1, 0, 0]);
            end
            propStruct = setPropDefault(isExternal);
            propStruct.color = [1, 0, 0];
            checkProp(plotObj, propStruct);
            close all;
            
            if isExternal            
                plotObj = self.reachObj.plot_ea('color', 'r');
            else
                plotObj = self.reachObj.plot_ia('color', 'r');
            end
            propStruct = setPropDefault(isExternal);
            propStruct.color = [1, 0, 0];
            checkProp(plotObj, propStruct);
            close all;
            
            if isExternal            
                plotObj = self.reachObj.plot_ea('r');
            else
                plotObj = self.reachObj.plot_ia('r');
            end
            propStruct = setPropDefault(isExternal);
            propStruct.color = [1, 0, 0];
            checkProp(plotObj, propStruct);
            close all;
            
            if isExternal            
                plotObj = self.reachObj.plot_ea('shade', 0.5);
            else
                plotObj = self.reachObj.plot_ia('shade', 0.5);
            end
            propStruct = setPropDefault(isExternal);
            propStruct.shade = 0.5;
            checkProp(plotObj, propStruct);
            close all;
            
            if isExternal            
                plotObj = self.reachObj.plot_ea('width', 3);
            else
                plotObj = self.reachObj.plot_ia('width', 3);
            end
            propStruct = setPropDefault(isExternal);
            propStruct.lineWidth = 3;
            checkProp(plotObj, propStruct);
            close all;
            
            if isExternal            
                plotObj = self.reachObj.plot_ea('color', [1, 1, 0],...
                    'shade', 0.7, 'width', 3);
            else
                plotObj = self.reachObj.plot_ia('color', [1, 1, 0],...
                    'shade', 0.7, 'width', 3);
            end
            propStruct = setPropDefault(isExternal);
            propStruct.shade = 0.7;
            propStruct.color = [1, 1, 0];
            propStruct.lineWidth = 3;
            checkProp(plotObj, propStruct);
            close all;
            
            function checkProp(plObj, propStruct)
                SHandle =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
                [~, handleVecList] = modgen.struct.getleavelist(SHandle);
                handleVec = [handleVecList{:}];
                objCVec = get(handleVec, 'Children');
                if propStruct.isExternal
                    curObj = objCVec{1}(3);
                else
                    curObj = objCVec{1}(2);
                end
                          
                reachColMat = get(curObj, 'FaceVertexCData');
                colMat = repmat(propStruct.color, size(reachColMat, 1), 1);
                mlunit.assert_equals(reachColMat, colMat);
            
                reachShade = get(curObj, 'FaceAlpha');
                mlunit.assert_equals(reachShade, propStruct.shade);
                
                curObj = objCVec{2}(2);
                reachLineWidth = get(curObj, 'lineWidth');
                mlunit.assert_equals(reachLineWidth, propStruct.lineWidth);
            end
        end
    end
end

function reachObj = getReach()
    sys = elltool.linsys.LinSysFactory.create([0, 1; 0, 0], eye(2),... 
        ell_unitball(2));
    reachObj = elltool.reach.ReachContinuous(sys, ell_unitball(2),...
        eye(2), [1 10]);
end
     
       
function propStruct = setPropDefault(isExternal)
    propStruct.isFill = false;
    propStruct.lineWidth = 2;
    propStruct.isExternal = isExternal;
    if isExternal
        propStruct.color = [0, 0, 1];
        propStruct.shade = 0.3;
    else
        propStruct.color = [0, 1, 0];
        propStruct.shade = 0.1; 
    end
end
