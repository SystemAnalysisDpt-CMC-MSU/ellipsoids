classdef BasicTestCase < mlunitext.test_case
     methods
        function self=BasicTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
        end
        function testDemo1(~)
            runDemo(@ell_demo1);
        end
        function testDemo2(~)
            runDemo(@ell_demo2);
        end
        function testDemo3(~)
            runDemo(@ell_demo3);
        end
        
        function tear_down(~)
            close all;
        end
    end
end
function runDemo(fDemo)
arrayfun(@(x)evalin('caller',[x.code{:}]),fDemo());
end