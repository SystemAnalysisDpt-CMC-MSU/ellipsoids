% Test the ability to change Log4j configuration when
% Log4jConfigurator.configure method is called in default mode or with
% confMode=allowConfChange.
% Warning: This script clobbers any existing log4j configuration!
import modgen.logging.log4j.test.Log4jConfigurator;
import org.apache.log4j.Level;
confStr = 'log4j.rootLogger=WARN';
evalc('Log4jConfigurator.configure(confStr)');
% Create a logger instance
logger=Log4jConfigurator.getLogger();
% Log4j should be configured with WARN level; therefore, INFO level should
% not be enabled
if logger.isInfoEnabled()
    error('Failed to configure Log4j');
end
confStr = 'log4j.rootLogger=INFO';
% Try to configure log4j again, using INFO level. This time specify the
% mode explicitly
evalc('Log4jConfigurator.configure(confStr,''confMode'',''allowConfChange'')');
if ~logger.isInfoEnabled()
    error('Failed to change Log4j configuration');
end