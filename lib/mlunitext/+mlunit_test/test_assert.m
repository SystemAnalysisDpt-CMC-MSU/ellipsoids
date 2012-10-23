classdef test_assert < mlunitext.test_case
    % TEST_ASSERT tests the methods assert, assert_equals and assert_not_equals.
    %
    %  Example:
    %         run(gui_test_runner, 'test_assert');

    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
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
            import mlunitext.*;
            % Without message
            try
                assert(0);
                fprintf(1, 'assert(0) fails to fail.');
            catch meObj
                assert(~isempty(strfind(meObj.identifier, 'MLUNIT')));
            end;

            try
                assert(false);
                failed = 1;
            catch meObj
                assert(~isempty(strfind(meObj.identifier, 'MLUNIT')));                
            end;
            assert(failed == 0, 'assert(false) fails to fail.');

            % With message
            try
                assert(false, 'Assertion must fail.');
            catch meObj
                assert(~isempty(strfind(meObj.message, 'Assertion must fail.')));
            end;

            % Equals
            try
                assert_equals(0, 1);
                failed = 1;
            catch meObj
                assert(~isempty(strfind(meObj.identifier, 'MLUNIT')));               
            end;
            assert(failed == 0, 'assert_equals(0, 1) fails to fail.');

            % Not equals
            try
                assert_not_equals(1, 1);
                failed = 1;
            catch meObj
                assert(~isempty(strfind(meObj.identifier, 'MLUNIT'))); 
            end;
            assert(failed == 0, 'assert_not_equals(1, 1) fails to fail.');
            %
            % With message
            try
                assert_not_equals(true,true, 'Assertion must fail.');
            catch meObj
                assert(~isempty(strfind(meObj.message, 'Assertion must fail.')));
            end;            
            % With message
            try
                assert_equals(false,true, 'Assertion must fail.');
            catch meObj
                assert(~isempty(strfind(meObj.message, 'Assertion must fail.')));
            end;   
            try
                assert(false);
            catch meObj
                assert_equals(meObj.stack(1).line,80);
                assert_equals(meObj.stack(1).name,'test_assert.test_fail');
            end
            try
                assert_equals(false,true);
            catch meObj
                assert_equals(meObj.stack(1).line,86);
                assert_equals(meObj.stack(1).name,'test_assert.test_fail');
            end
            try
                assert_not_equals(false,false);
            catch meObj
                assert_equals(meObj.stack(1).line,92);
                assert_equals(meObj.stack(1).name,'test_assert.test_fail');
            end    
            try
                fail('test fail');
            catch meObj
                assert_equals(meObj.stack(1).line,98);
                assert_equals(meObj.stack(1).name,'test_assert.test_fail');
            end               
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