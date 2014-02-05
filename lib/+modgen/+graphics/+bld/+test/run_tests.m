function testResVec=run_tests(varargin)
% Example:
%
%   modgen.graphics.bld.test.run_tests()  
%
%
%   modgen.graphics.bld.test.run_tests('nParallelProcesses',8,'parallelMode','queueBased')
%
%
import modgen.common.parseparams;
%
runnerObj = mlunitext.text_test_runner(1, 1);
%
loaderObj = mlunitext.test_loader;
%
[restArgList,testCasePropValList]=parseparams(varargin,{'reCache'});
[suiteParamList,filterPropValList]=parseparams(restArgList,{'filter'});
if isempty(filterPropValList)
    filterParamList={};
else
    filterParamList=filterPropValList{2};
end
%
suiteObj=loaderObj.load_tests_from_test_case(...
    'modgen.graphics.bld.test.mlunit.BasicTC',...
        testCasePropValList);
suiteObj=mlunitext.test_suite(suiteObj.tests,suiteParamList{:});
suiteObj=suiteObj.getCopyFiltered(filterParamList{:});
%
testResVec=runnerObj.run(suiteObj);