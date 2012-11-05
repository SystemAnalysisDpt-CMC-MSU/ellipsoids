function ellipsoids_init()
%
import elltool.cvx.CVXController;
% ELLIPSOIDS_INIT - initializes Ellipsoidal Toolbox.
%

import elltool.conf.Properties;
%Options initialisation
confRepoMgr=elltool.conf.ConfRepoMgr();
confRepoMgr.selectConf('default');
elltool.conf.Properties.setConfRepoMgr(confRepoMgr);

if Properties.getIsVerbose()
    welcomeString=sprintf(...
        'Defining settings for Ellipsoids Toolbox, ver %s',...
        Properties.getVersion());
    disp([welcomeString,'...']);
end

% CVX settings.
if CVXController.isSetUp()
    CVXController.setSolver('sedumi');
    CVXController.setPrecision(Properties.getRelTol());
    CVXController.setIsVerbosityEnabled(false);
end


