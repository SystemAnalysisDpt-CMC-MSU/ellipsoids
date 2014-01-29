classdef BasicTestCase < mlunitext.test_case
     methods
        function self=BasicTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
        end
        function testDemoEllCalc(~)
            s_ell_demo_ellcalc;
        end
        function testDemoEllBasic(~)
            s_ell_demo_ellbasic;
        end
        function testDemoEllVis(~)
            s_ell_demo_ellvis;
        end
        function testDemoReach(~)
            s_ell_demo_reach;
        end
        %
        function tear_down(~)
            close all;
        end
    end
end