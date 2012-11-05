function ellipsoids_init()
%
import elltool.cvx.CVXController;
% ELLIPSOIDS_INIT - initializes Ellipsoidal Toolbox.
%
% Any routine of Ellipsoidal Toolbox can be called with user-specified values
% of different parameters. To make Ellipsoidal Toolbox as user-friendly as
% possible, we provide the option to store default values of the parameters
% in variable ellOptions, which is stored in MATLAB's workspace as a global
% variable (i.e. it stays there unless one types 'clear all').
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


