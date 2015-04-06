function result = run_tests(varargin)
% RUN_TESTS runs most of the tests based on specified patters
% for markers, test cases, tests names
%
% Input:
%   optional:
%       markerRegExp: char[1,] - regexp for marker AND/OR configuration
%           names, default is '.*' which means 'all cofigs'
%       testCaseRegExp: char[1,] - regexp for test case names, same default
%       testRegExp: char[1,] - regexp for test names, same default
%
% Output:
%   results: mlunitext.text_test_run[1,1] - test result
%
% Example:
%
%   elltool.reach.test.run_most_tests('ellipsoid')  
%
%   elltool.reach.test.run_most_tests('GenEllipsoid')
%
import elltool.core.test.EllFactory;

runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;

ellFactoryObj = EllFactory('ellipsoid');
genEllFactoryObj = EllFactory('GenEllipsoid');

confCMat = {
    'EllipsoidIntUnionTC', [1 1];
    'EllipsoidTestCase', [1 1];
    'EllipsoidSecTestCase', [1 1];
    'HyperplaneTestCase', [1 1];
    'ElliIntUnionTCMultiDim', [1 1];
    'EllTCMultiDim', [1 1];
    'EllSecTCMultiDim', [1 1];
    'MPTIntegrationTestCase', [1 1];
    'EllAuxTestCase', [1 1];
    'HyperplanePlotTestCase', [1 1];
    'EllipsoidMinkPlotTestCase', [1 1];
    'EllipsoidBasicSecondTC', [1 1];
    'HyperplaneDispStructTC', [1 1];
    'GenEllipsoidDispStructTC', [0 1];
    'GenEllipsoidPlotTestCase', [0 1];
    'GenEllipsoidTestCase', [0 1];
    'EllipsoidPlotTestCase', [1 0];
    'EllipsoidDispStructTC', [1 0];
    'EllipsoidSpecialTC', [1 0] ...
    };

nConfs = size(confCMat, 1);
suiteList = {};

for iConf = 1 : nConfs
    confName = confCMat{iConf, 1};
    confTestsVec = confCMat{iConf, 2};

    if confTestsVec(1)
        suiteList{end + 1} = loader.load_tests_from_test_case( ...
            ['elltool.core.test.mlunit.' confName], ellFactoryObj, ...
            'marker', [confName '_ellipsoid']);
    end
    if confTestsVec(2)
        suiteList{end + 1} = loader.load_tests_from_test_case( ...
            ['elltool.core.test.mlunit.' confName], genEllFactoryObj, ...
            'marker', [confName '_GenEllipsoid']);
    end
end

testLists = cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
testList=horzcat(testLists{:});
suite = mlunitext.test_suite(testList);
suite=suite.getCopyFiltered(varargin{:});
result = runner.run(suite);
