function results=run_tests()
import modgen.containers.*;
import modgen.containers.test.*;
%
runner = mlunit.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suiteSimpleType=loader.load_tests_from_test_case(...
    'modgen.common.type.test.mlunit.TestSuiteSimpleType');
suite = mlunit.test_suite(horzcat(...
    suiteSimpleType.tests));
%
results=runner.run(suite);
