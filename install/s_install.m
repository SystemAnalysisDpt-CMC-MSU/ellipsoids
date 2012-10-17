welcomeString=sprintf('Installing Ellipsoidal Toolbox');
disp([welcomeString,'...']);
s_setpath;
s_setjavapath;
%
modgen.deployment.s_setjavapath
modgen.logging.log4j.Log4jConfigurator.configureSimply();
ellipsoids_init();
disp([welcomeString,': done']);
