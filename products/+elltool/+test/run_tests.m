function results=run_tests(varargin)
logger=modgen.logging.log4j.Log4jConfigurator.getLogger();
resList{1} = lib_run_tests(varargin{:});
resList{2} = gras.test.run_tests();
resList{3} = elltool.core.test.run_tests();
resList{4} = elltool.linsys.test.run_tests();
resList{5} = elltool.demo.test.run_tests();
resList{6} = elltool.reach.test.run_tests();
%
results=[resList{:}];
[errorCount,failCount]=results.getErrorFailCount();
logger.info(sprintf([...
    '\n\n+--------------------------------------------+',...
    '\n|      ELLIPSOID TOOLBOX TEST RESULTS        |',...
    '\n|         (FAILURES: %d, ERRORS %d)            |',...
    '\n+--------------------------------------------+'],....
    failCount,errorCount));