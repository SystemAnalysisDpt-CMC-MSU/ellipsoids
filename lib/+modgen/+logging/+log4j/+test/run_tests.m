function results=run_tests(varargin)
import modgen.containers.*;
import modgen.containers.test.*;
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case(...
    'modgen.logging.log4j.test.mlunit_test_log4jconfigurator', varargin{:});
results=runner.run(suite);