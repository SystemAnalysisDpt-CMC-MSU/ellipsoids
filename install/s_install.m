welcomeString=sprintf('Installing Ellipsoidal Toolbox');
disp([welcomeString,'...']);
s_setpath;
s_setjavapath;
%
%% Configure CVX is needed
ellipsoids_init();
disp([welcomeString,': done']);

