function results = run()
% RUN executes mlunit_all_tests with the text_test_runner.
%
% Example:
%   mlunit_test.run;

% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$
import modgen.logging.log4j.test.Log4jConfigurator;
import mlunitext.*
%
lastPropStr=modgen.logging.log4j.Log4jConfigurator.getLastLogPropStr;
isLocked=modgen.logging.log4j.Log4jConfigurator.isLocked();
onCln=onCleanup(@()restoreConf(lastPropStr,isLocked));
Log4jConfigurator.unlockConfiguration();
mlunitext.assert_equals(false,Log4jConfigurator.isLocked())
NL = sprintf('\n');
appenderConfStr = ['log4j.appender.stdout=org.apache.log4j.ConsoleAppender',NL,...
    'log4j.appender.stdout.layout=org.apache.log4j.PatternLayout',NL,...
    'log4j.appender.stdout.layout.ConversionPattern=%5p %c - %m\\n'];            
confStr = ['log4j.rootLogger=WARN,stdout', NL, appenderConfStr];
evalc('Log4jConfigurator.configure(confStr)');
mlunitext.assert_equals(true,Log4jConfigurator.isConfigured());
mlunitext.assert_equals(confStr,Log4jConfigurator.getLastLogPropStr());
%
runner = text_test_runner(1, 1);
suite = mlunit_test.all_tests;
results = run(runner, suite);
end
function restoreConf(confStr,isLocked)
modgen.logging.log4j.test.Log4jConfigurator.unlockConfiguration();
modgen.logging.log4j.test.Log4jConfigurator.configure(...
    confStr,'islockafterconfigure',isLocked);
end