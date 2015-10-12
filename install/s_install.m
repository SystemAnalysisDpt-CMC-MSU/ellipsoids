welcomeString=sprintf('Installing Ellipsoidal Toolbox');
disp([welcomeString,'...']);
installexternals(true);
warning('on','all');
warning('off','MATLAB:dispatcher:pathWarning');
s_setpath;
s_setjavapath;
modgen.logging.log4j.Log4jConfigurator.configureSimply();
%
%% Configure CVX is needed
ellipsoidsinit();
disp([welcomeString,': done']);

