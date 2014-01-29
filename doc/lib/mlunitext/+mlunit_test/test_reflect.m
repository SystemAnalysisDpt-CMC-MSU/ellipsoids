classdef test_reflect < mlunitext.test_case
    %   TEST_REFLECT tests the class reflect.
    %
    %  Example:
    %         run(gui_test_runner, 'test_reflect');

    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$

    properties
    end

    methods
        function self = test_reflect(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end

        function self = test_get_methods(self)
            % TEST_GET_METHODS tests the method
            % GET_METHODS
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_reflect(''test_get_methods'')');
            %
            %  See also MLUNITEXT.REFLECT.GET_METHODS.

            import mlunitext.*;

            r = reflect('mlunitext.test_case');
            m = get_methods(r);
            assert(size(m, 1) > 0);
            assert(sum(strcmp(m, 'run')) == 1);
            assert(sum(strcmp(m, 'set_up')) == 1);
            assert(sum(strcmp(m, 'tear_down')) == 1);
        end

        function self = test_method_exists(self)
            % TEST_METHOD_EXISTS tests the method
            %   method_exists.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_reflect(''test_method_exists'')');
            %
            %  See also MLUNITEXT.REFLECT.METHOD_EXISTS.

            import mlunitext.*;

            r = reflect('mlunitext.test_suite');
            assert(method_exists(r, 'run'));
            assert(~method_exists(r, 'foo'));

            r = reflect('mlunit_test.mock_test');
            assert(~method_exists(r, 'foo'));
        end

        function self = test_not_instantiated(self)
            % TEST_NOT_INSTANTIATED tests the method
            %   get_methods with a not instantiated class.
            %
            %  Example:
            %         run(gui_test_runner, 
            %             'test_reflect(''test_not_instantiated'')');
            %
            %  See also MLUNITEXT.REFLECT.GET_METHODS.

            import mlunitext.*;

            r = reflect('mlunit_test.mock_test_not_instantiated');
            m = get_methods(r);
            assert(size(m, 1) >= 10);
        end
        
        function test_no_such_class(~)
            try
                mlunitext.reflect('nosuchpackage.nosuchclass');
            catch meObj
                mlunitext.assert_equals(true,...
                    ~isempty(strfind(meObj.identifier,'noSuchClass')));
                return;
            end
            mlunitext.fail('Expected exception was not thrown');
        end
    end
end
