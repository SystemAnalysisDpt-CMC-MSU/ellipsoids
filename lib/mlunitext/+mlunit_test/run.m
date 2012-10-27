function results = run()
% RUN executes mlunit_all_tests with the text_test_runner.
%
% Example:
%   mlunit_test.run;

% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$

import mlunitext.*

runner = text_test_runner(1, 1);
suite = mlunit_test.all_tests;
results = run(runner, suite);