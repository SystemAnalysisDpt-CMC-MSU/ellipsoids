function result=run_tests(varargin)
    resList{1} = elltool.core.test.run_tests_by_factory('ellipsoid');
    %resList{2} = elltool.core.test.run_tests_by_factory('GenEllipsoid');
    result=[resList{:}];
