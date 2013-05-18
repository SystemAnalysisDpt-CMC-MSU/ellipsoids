classdef mock_test < mlunitext.test_case
    properties
        verbose = true;
    end
    methods
        function self = mock_test(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function set_up_param(self, varargin)
            import modgen.common.throwerror;
            if any(strcmpi('marker',varargin))
                throwerror('wrongState',...
                    'Oops, marker property should not get here');
            end
            nArgs = length(varargin);
            if nArgs == 1
                self.verbose = varargin{1};
                if ~isscalar(self.verbose) || ~islogical(self.verbose)
                    throwerror('wrongInput', ...
                        'Invalid size or type of parameter #1');
                end
            elseif nArgs > 1
                throwerror('wrongInput','Too many parameters');
            end
        end
        %
        function test_pass_one(self)
            if self.verbose
                logger=modgen.logging.log4j.Log4jConfigurator.getLogger();
                logger.info('test_pass_one');
            end
        end
        function test_fail_one(self)
            if self.verbose
                logger=modgen.logging.log4j.Log4jConfigurator.getLogger();
                logger.info('test_fail_one');
            end
            mlunitext.fail;
        end
        function test_pass_two(self)
            if self.verbose
                logger=modgen.logging.log4j.Log4jConfigurator.getLogger();
                logger.info('test_pass_two');
            end
        end
        function test_error_one(self)
            if self.verbose
                logger=modgen.logging.log4j.Log4jConfigurator.getLogger();
                logger.info('test_error_one');
            end
            error(' ');
        end
        function test_pass_three(self)
            if self.verbose
                logger=modgen.logging.log4j.Log4jConfigurator.getLogger();
                logger.info('test_pass_three');
            end
        end
        function test_fail_two(self)
            if self.verbose
                logger=modgen.logging.log4j.Log4jConfigurator.getLogger();
                logger.info('test_fail_two');
            end
            mlunitext.fail;
        end
        function test_pass_four(self)
            if self.verbose
                logger=modgen.logging.log4j.Log4jConfigurator.getLogger();
                logger.info('test_pass_four');
            end
        end
        function test_error_two(self)
            if self.verbose
                logger=modgen.logging.log4j.Log4jConfigurator.getLogger();
                logger.info('test_error_two');
            end
            error(' ');
        end
    end
end