classdef EllipsoidMinksumPlotTestCase < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
        
    end
    %
    methods
        function self = EllipsoidMinksumPlotTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = testFillAndShade(self)
            testFirEll = ellipsoid(2*eye(2));
            testSecEll = ellipsoid([1, 0].', [9 2;2 4]);
            testThirdEll = ellipsoid([1 0; 0 0]);
            testForthEll = ellipsoid([0, -1, 3].', 1.5*eye(3));
            testFifthEll = ellipsoid([5,5,5]', [6 2 1; 2 4 3; 1 3 5]);
            testSixthEll = ellipsoid([1 0 0; 0 0 0; 0 0 1]);
            
            
            minksum(testFirEll,testSecEll,'fill',false,'shade',0.7);
            minksum(testFirEll,testSecEll,'fill',true,'shade',0.7);
            minksum(testFirEll,testSecEll,testThirdEll,'fill',false,'shade',1);
            minksum(testFirEll,testSecEll,testThirdEll,'fill',true,'shade',1);
            self.runAndCheckError...
                ('minksum([testFirEll,testSecEll,testThirdEll],''shade'',NaN)', ...
                'wrongShade');
            self.runAndCheckError...
                ('minksum([testFirEll,testSecEll,testThirdEll],''shade'',[0 1])', ...
                'wrongParamsNumber');
            minksum(testForthEll,testFifthEll,'fill',false,'shade',0.7);
            minksum(testForthEll,testFifthEll,'fill',true,'shade',0.3);
        end
        function self = testColor(self)
            testFirEll = ellipsoid(2*eye(2));
            testSecEll = ellipsoid([1, 0].', [9 2;2 4]);
            plObj = minksum(testFirEll,testSecEll,'color',[0,1,0]);
            check2dCol(plObj,2, [0, 1, 0]);
            
            function check2dCol(plObj,numObj, colMat)
                colMat = repmat(colMat,numObj,1);
                SHPlot =  plObj.getPlotStructure().figToAxesToHMap.toStruct();
                plEllObjVec = get(SHPlot.figure_g1.ax, 'Children');
                plEllColCMat = get(plEllObjVec, 'EdgeColor');
                if iscell(plEllColCMat)
                    plEllColMat = vertcat(plEllColCMat{:});
                else
                    plEllColMat = plEllColCMat;
                end
                mlunit.assert_equals(plEllColMat, colMat);
            end
        end
    end
end