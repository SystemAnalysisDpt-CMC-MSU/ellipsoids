function result=run_demo_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
%
nDirs = 5;
fullFileName=modgen.common.getcallername;
demoTestDir = [fileparts(which(fullFileName)),...
    filesep,'+control'];
SFileNameArray = dir([demoTestDir,filesep,'*.m']);
nTests=numel(SFileNameArray);
testList=cell(1,nTests);
for iTest = 1 : nTests
    testName = modgen.string.splitpart...
        (SFileNameArray(iTest).name, '.', 'first');
    funcName = strcat('elltool.demo.test.control.',testName);
    testList{iTest}=elltool.demo.test.mlunit.TouchTestCase(...
        'testControl','elltool.demo.test.mlunit.TouchTestCase',...
        nDirs,funcName,'marker',testName);
end
suite = mlunitext.test_suite(testList);
%
result=runner.run(suite);