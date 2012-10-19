classdef mock_test_failed_set_up < mlunit_test.mock_test
    % MOCK_TEST_FAILED_SET_UP is a mock test_case with a broken set_up used 
    %for the tests in test_test_case.
    %
    %  Example:
    %         run(gui_test_runner, 
    %             'mock_test_failed_set_up(''test_method'')');

    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$

    properties
    end

    methods
        function self = mock_test_failed_set_up(varargin)
            self = self@mlunit_test.mock_test(varargin{:});
        end

        function self = set_up(self) %#ok
            % SET_UP is a mock set_up method, that 
            %   is broken as it only class error(' ').
            %
            %  Example:
            %         test = mock_test_failed_set_up('test_method');
            %         try
            %             test = run(test, default_test_result(self));
            %         catch
            %             assert(0);
            %         end;
            %         assert(strcmp('', get_log(test)));
            %
            %  See also TEST_TEST_CASE/TEST_FAILED_SET_UP.

            error(' ');
        end
    end
end

