function suite = all_tests
% ALL_TESTS creates a test_suite with all test for package mlunit_test.
%
%  Example:
%         run(gui_test_runner, 'mlunit_test.all_tests');

% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$

import mlunitext.*;

suite = test_suite;
loader = test_loader;
suite.set_name('mlunit_all_tests');
suite.add_test(load_tests_from_test_case(loader, 'mlunit_test.test_assert'));
suite.add_test(load_tests_from_test_case(loader, 'mlunit_test.test_function_test_case'));
suite.add_test(load_tests_from_test_case(loader, 'mlunit_test.test_reflect'));
suite.add_test(load_tests_from_test_case(loader, 'mlunit_test.test_test_case'));
suite.add_test(load_tests_from_test_case(loader, 'mlunit_test.test_test_result'));
suite.add_test(load_tests_from_test_case(loader, 'mlunit_test.test_test_suite'));
suite.add_test(load_tests_from_test_case(loader, 'mlunit_test.test_test_loader'));
suite.add_test(load_tests_from_test_case(loader, 'mlunit_test.test_text_test_runner'));
suite.add_test(load_tests_from_test_case(loader, 'mlunit_test.test_text_test_result'));