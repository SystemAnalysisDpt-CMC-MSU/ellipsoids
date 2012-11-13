welcomeString=sprintf('Installing Ellipsoidal Toolbox');
disp([welcomeString,'...']);
s_setpath;
s_setjavapath;
%%
modgen.deployment.s_set_public_javapath
modgen.logging.log4j.Log4jConfigurator.configureSimply();
%% Configure CVX is needed
elltool.cvx.CVXController.setUpIfNot();
%%
ellipsoids_init();
disp([welcomeString,': done']);