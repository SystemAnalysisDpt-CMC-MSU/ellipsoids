classdef test_assert < mlunitext.test_case
    % TEST_ASSERT tests the methods assert, assert_equals and assert_not_equals.
    %
    %  Example:
    %         run(gui_test_runner, 'test_assert');

    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Applied Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$

    methods
        function self = test_assert(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end

        function self = test_fail(self)
            % TEST_ASSERT/TEST_FAIL tests invalid assertions.
            %
            % Example:
            % run(gui_test_runner, 'test_assert(''test_fail'');');
            %
            % See also ASSERT, ASSERT_EQUALS, ASSERT_NOT_EQUALS.

            failed = 0;

            % Without message
            try
                assert(0);
                fprintf(1, 'assert(0) fails to fail.');
            catch
            end;

            try
                assert(false);
                failed = 1;
            catch
            end;
            assert(failed == 0, 'assert(false) fails to fail.');

            % With message
            try
                assert(false, 'Assertion must fail.');
            catch
                assert(~isempty(strfind(lasterr, 'Assertion must fail.')));
            end;

            % Equals
            try
                assert_equals(0, 1);
                failed = 1;
            catch
            end;
            assert(failed == 0, 'assert_equals(0, 1) fails to fail.');

            % Not equals
            try
                assert_not_equals(1, 1);
                failed = 1;
            catch
            end;
            assert(failed == 0, 'assert_not_equals(1, 1) fails to fail.');
        end

        function self = test_pass(self)
            % TEST_ASSERT/TEST_PASS tests valid assertions.
            %
            %  Example:
            %         run(gui_test_runner, 'test_assert(''test_pass'');');
            %
            %  See also ASSERT, ASSERT_EQUALS, ASSERT_NOT_EQUALS.

            import mlunitext.*;

            % Without message
            assert(true);
            assert(sin(pi/2) == cos(0));

            % With message
            assert(true, 'Assertion must pass, so message is never seen.');

            % Equals
            assert_equals(1, 1);
            assert_equals('Foo', 'Foo');
            assert_equals([1 2 3], [1 2 3]);
            assert_equals(sin(1), sin(1));
            assert_equals(true, true);

            % Not equals
            assert_not_equals(0, 1)
            assert_not_equals('Foo', 'Bar');
            assert_not_equals([1 2 3], [4 5 6]);
            assert_not_equals(sin(0), sin(1));
            assert_not_equals(true, false);
        end
    end
end