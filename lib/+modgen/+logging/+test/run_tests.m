function results=run_tests()
import modgen.containers.*;
import modgen.containers.test.*;
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case(...
    'modgen.logging.test.mlunit_test_emaillogger');
results=runner.run(suite);