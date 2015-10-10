function results=run_tests()
import modgen.containers.*;
import modgen.containers.test.*;
%
runner = mlunitext.text_test_runner(1, 1);
suite=mlunitext.test_suite.fromTestCaseNameList(...
    {'modgen.common.test.mlunit_test_common',...
    'modgen.common.test.IsMemberTC'});
%
resList{1}=runner.run(suite);
resList{2}=modgen.common.obj.test.run_tests;
resList{3}=modgen.common.type.test.run_tests;
results=[resList{:}];