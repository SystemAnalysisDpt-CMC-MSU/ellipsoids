SEllOptions = ellipsoids_init();
welcomeString=sprintf('Installing Ellipsoidal Toolbox version %s',...
    SEllOptions.version);
disp([welcomeString,'...']);
s_setpath;
s_setjavapath;
%
modgen.deployment.s_setjavapath
modgen.logging.log4j.Log4jConfigurator.configureSimply();
disp([welcomeString,': done']);
