function results=run_tests()
import modgen.containers.*;
import modgen.containers.test.*;
%
mapFactory=modgen.containers.test.DiskBasedHashMapFactory();
suiteDiskBasedHashMap=modgen.containers.test.build_basic_suite_per_factory(...
    mapFactory,{'mat','xml'});
%
runner = mlunitext.text_test_runner(1, 1);
%
loader = mlunitext.test_loader;
suiteBasic=loader.load_tests_from_test_case(...
    'modgen.containers.test.mlunit.SuiteBasic');
%
suite=mlunitext.test_suite(horzcat(...
    suiteDiskBasedHashMap.tests,suiteBasic.tests));
%    
resList{1}=runner.run(suite);
resList{2}=modgen.containers.test.ondisk.run_tests;
results=[resList{:}];