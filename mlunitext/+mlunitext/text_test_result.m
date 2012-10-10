classdef text_test_result < mlunit.text_test_result
% TEXT_TEST_RESULT class is inherited from test_result and prints
%  formatted test results to a stream. The constructor creates an 
%  object while the parameter verbosity defines, how much output is written. 
%  Possible values are 0, 1 and 2. 
%
%  Example:
%    Output all results to the Matlab Command Window:
%         result = text_test_result(1, 0)
%
%  See also MLUNIT.TEST_RESULT.

% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Applied Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$

    methods
        function self = text_test_result(varargin)
            self=self@mlunit.text_test_result(varargin{:});
        end
    end
end