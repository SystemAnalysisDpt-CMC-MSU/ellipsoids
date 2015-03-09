classdef GoodDirsTestCase < mlunitext.test_case
    %
    methods
        function self = GoodDirsTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function tear_down(~)
            close all;
        end
        %
        function testGoodDirsClassesCreation(~)
            gras.ellapx.lreachplain.test.examples.examlpe_getGoodDirsContinuousGenLeft();
            gras.ellapx.lreachplain.test.examples.examlpe_getGoodDirsContinuousGenRight();
            gras.ellapx.lreachplain.test.examples.examlpe_getGoodDirsContinuousGenMid();
            gras.ellapx.lreachplain.test.examples.examlpe_getGoodDirsContinuousLTI();
            gras.ellapx.lreachplain.test.examples.examlpe_getGoodDirsDiscrete();
        end
    end
end