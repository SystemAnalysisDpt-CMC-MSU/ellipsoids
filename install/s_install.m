welcomeString=sprintf('Installing Ellipsoidal Toolbox');
disp([welcomeString,'...']);
installexternals(true);
warning('on','all');
warning('off','MATLAB:dispatcher:pathWarning');
% switch off warnings for nargchk for Matlab R2016a
SMatlabInfo=ver('Matlab');
if strcmp(SMatlabInfo.Release,'(R2016a)')
    warning('off','MATLAB:nargchk:deprecated');
end
s_setpath;
s_setjavapath;
modgen.logging.log4j.Log4jConfigurator.configureSimply();
%
%% Configure CVX is needed
ellipsoidsinit();
disp([welcomeString,': done']);

