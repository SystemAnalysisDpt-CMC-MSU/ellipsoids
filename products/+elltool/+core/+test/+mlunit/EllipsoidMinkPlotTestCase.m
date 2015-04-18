classdef EllipsoidMinkPlotTestCase < elltool.core.test.mlunit.EllFactoryTC
    %
    properties (Access=private)
        testDataRootDir
    end
    %
    methods
        function self = EllipsoidMinkPlotTestCase(varargin)
            self = self@elltool.core.test.mlunit.EllFactoryTC(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = testFillAndShade(self)
            testFirEll = self.createEll(2*eye(2));
            testSecEll = self.createEll([1, 0].', eye(2));
            testThirdEll = self.createEll([0, -1].', 1.5*eye(2));
            minksum(testFirEll,testSecEll,'fill',false,'shade',0.7);
            minksum(testFirEll,testSecEll,'fill',true,'shade',0.7);
            minksum(testFirEll,testSecEll,testThirdEll,'fill',false,'shade',1);
            minksum(testFirEll,testSecEll,testThirdEll,'fill',true,'shade',1);
            minkdiff(testFirEll,testSecEll,'fill',false,'shade',0.7);
            minkdiff(testFirEll,testSecEll,'fill',true,'shade',0.7);
            minkmp(testFirEll,testSecEll,testThirdEll,'fill',false,'shade',0);
            minkmp(testFirEll,testSecEll,testThirdEll,'fill',true,'shade',0);
            minkpm(testFirEll,testSecEll,testThirdEll,'fill',false,'shade',0.1);
            minkpm(testFirEll,testSecEll,testThirdEll,'fill',true,'shade',0.1);
            self.runAndCheckError...
                ('minksum([testFirEll,testSecEll,testThirdEll],''shade'',NaN)', ...
                'wrongShade');
            self.runAndCheckError...
                ('minksum([testFirEll,testSecEll,testThirdEll],''shade'',[0 1])', ...
                'wrongParamsNumber');
            self.runAndCheckError...
                ('minkdiff([testFirEll,testSecEll],''shade'',inf)', ...
                'wrongShade');
            self.runAndCheckError...
                ('minkdiff([testFirEll,testSecEll],''shade'',[0 1])', ...
                'wrongParamsNumber');
            self.runAndCheckError...
                ('minkmp([testFirEll,testSecEll,testThirdEll],''shade'',NaN)', ...
                'wrongShade');
            self.runAndCheckError...
                ('minkmp([testFirEll,testSecEll,testThirdEll],''shade'',[0 1])', ...
                'wrongParamsNumber');
            self.runAndCheckError...
                ('minkpm([testFirEll,testSecEll,testThirdEll],''shade'',-inf)', ...
                'wrongShade');
            self.runAndCheckError...
                ('minkpm([testFirEll,testSecEll,testThirdEll],''shade'',[0 1])', ...
                'wrongParamsNumber');
        end
    end
end