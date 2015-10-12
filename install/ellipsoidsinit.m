function ellipsoids_init()
%
% ELLIPSOIDS_INIT - initializes Ellipsoidal Toolbox.
import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;
%Options initialization
Properties.init();
logger=Log4jConfigurator.getLogger();
%
if Properties.getIsVerbose()
    welcomeString=sprintf(...
        'Defining settings for Ellipsoids Toolbox, ver %s',...
        Properties.getVersion());
    logger.debug([welcomeString,'...']);
end




