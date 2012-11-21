function ellipsoids_init()
%
% ELLIPSOIDS_INIT - initializes Ellipsoidal Toolbox.
import elltool.conf.Properties;
%Options initialisation
Properties.init();
%
if Properties.getIsVerbose()
    welcomeString=sprintf(...
        'Defining settings for Ellipsoids Toolbox, ver %s',...
        Properties.getVersion());
    disp([welcomeString,'...']);
end




