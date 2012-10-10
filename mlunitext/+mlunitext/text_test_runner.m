classdef text_test_runner<mlunit.text_test_runner
% TEXT_TEST_RUNNER class runs a test_case or test_suite and 
%  writes the results to a stream in textual form (using 
%  text_test_result).
%
%  Example:
%      runner = text_test_runner(1, 1);
%      run(runner, mlunit_all_tests);
%
%  See also MLUNIT.TEXT_TEST_RESULT.

% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Applied Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$

     methods
        function self = text_test_runner(varargin)
            self=self@mlunit.text_test_runner(varargin{:});
        end
     end
end