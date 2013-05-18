classdef mlunit_test_log4jconfigurator < mlunitext.test_case
    properties
        configurationProp
    end
    methods
        function self = mlunit_test_log4jconfigurator(varargin)
            [reg,prop] = modgen.common.parseparams(varargin,...
                {'parallelConfiguration'});
            nReg = length(reg);
            self = self@mlunitext.test_case(reg{1:min(nReg,2)});
            if ~isempty(prop)
                self.configurationProp = {'configuration', prop{2}};
            else
                self.configurationProp = {};
            end
        end
        %
        function test_configuration_persistence(self)
            % This test changes Log4j configuration. We'll run it in a
            % separate process, so that the changes do not affect the
            % current process.
            mlunitext.pcalc.auxdfeval(@self.aux_test_configuration_persistence,...
                 cell(0,1), 'alwaysFork', true, self.configurationProp{:});
        end
        %
        function self=test_getLogger(self)
            logger=modgen.logging.log4j.test.Log4jConfigurator.getLogger();
            loggerName=char(logger.getName());
            logger2=modgen.logging.log4j.test.Log4jConfigurator.getLogger(loggerName);
            loggerName2=char(logger2.getName());
            mlunitext.assert_equals(loggerName,loggerName2);
        end
        %
        function aux_test_configuration_persistence(~)
            % Log4jConfigurator keeps track of configuration changes. It
            % also allows the configuration to be locked, in which case
            % further attempts to change the configuration result only in a
            % warning.
            import modgen.logging.log4j.test.Log4jConfigurator;
            import org.apache.log4j.Level;
            NL = sprintf('\n');
            appenderConfStr = ['log4j.appender.stdout=org.apache.log4j.ConsoleAppender',NL,...
                'log4j.appender.stdout.layout=org.apache.log4j.PatternLayout',NL,...
                'log4j.appender.stdout.layout.ConversionPattern=%5p %c - %m\\n'];
            % Unlock and reconfigure
            Log4jConfigurator.unlockConfiguration();
            mlunitext.assert_equals(false,Log4jConfigurator.isLocked());
            confStr = ['log4j.rootLogger=WARN,stdout', NL, appenderConfStr];
            evalc('Log4jConfigurator.configure(confStr)');
            mlunitext.assert_equals(true,Log4jConfigurator.isConfigured());
            mlunitext.assert_equals(confStr,Log4jConfigurator.getLastLogPropStr());
            % Lock configuration and try to configure log4j again, using a
            % different level than it currently has. Log4jConfigurator
            % should do nothing, besides issuing a warning, and the level
            % should remain unchanged.
            Log4jConfigurator.lockConfiguration();
            mlunitext.assert_equals(true,Log4jConfigurator.isLocked());
            confStr = ['log4j.rootLogger=INFO,stdout', NL, appenderConfStr]; %#ok<NASGU>
            outputText = evalc('Log4jConfigurator.configure(confStr)');
            if isempty( strfind(outputText,'WARN') )
                mlunitext.fail('Log4jConfigurator.configure should have issued at least 1 warning');
            end
            if isempty( regexp(outputText, 'in .* at line \d+', 'once') )
                mlunitext.fail('Log4jConfigurator.configure did not print a stack trace');
            end
            % Create a logger instance and check log level
            logger=Log4jConfigurator.getLogger();
            if logger.isInfoEnabled()
                mlunitext.fail('Locked Log4jConfigurator should not allow a configuration change');
            end
            % Now try to configure using configureSimply
            outputText = evalc('Log4jConfigurator.configureSimply(''INFO'')');
            if logger.isInfoEnabled()
                mlunitext.fail('Locked Log4jConfigurator should not allow a configuration change');
            end
            if isempty( strfind(outputText,'WARN') )
                mlunitext.fail('Log4jConfigurator.configureSimply should have issued at least 1 warning');
            end
            if isempty( regexp(outputText, 'in .* at line \d+', 'once') )
                mlunitext.fail('Log4jConfigurator.configureSimply did not print a stack trace');
            end
            % Unlock the configuration and try to change it
            Log4jConfigurator.unlockConfiguration();
            evalc('Log4jConfigurator.configure(''log4j.rootLogger=INFO'',''isLockAfterConfigure'',true)');
            if ~logger.isInfoEnabled()
                mlunitext.fail('Log4jConfigurator failed to change configuration');
            end
            mlunitext.assert_equals(true,Log4jConfigurator.isLocked(),...
                'Failed to lock configuration using isLockAfterConfigure property');
            % Do the same using configureSimply
            Log4jConfigurator.unlockConfiguration();
            evalc('Log4jConfigurator.configureSimply(''WARN'',''isLockAfterConfigure'',true)');
            if logger.isInfoEnabled()
                mlunitext.fail('Log4jConfigurator failed to change configuration');
            end
            mlunitext.assert_equals(true,Log4jConfigurator.isLocked(),...
                'Failed to lock configuration using isLockAfterConfigure property');
        end
        %
        function self=test_getLoggerBySuffix(self)
            logger=modgen.logging.log4j.test.Log4jConfigurator.getLogger();
            loggerName=char(logger.getName());
            logger2=modgen.logging.log4j.test.Log4jConfigurator.getLogger(loggerName,false);
            loggerName2=char(logger2.getName());
            mlunitext.assert_equals(loggerName,loggerName2);
            logger2=modgen.logging.log4j.test.Log4jConfigurator.getLogger('suffix',true);
            loggerName2=char(logger2.getName());
            mlunitext.assert_equals([loggerName '.suffix'],loggerName2);
        end
    end
end
