welcomeString=sprintf('Installing Ellipsoidal Toolbox');
disp([welcomeString,'...']);
s_setpath;
s_setjavapath;
%%
modgen.deployment.s_set_public_javapath
%% Configure CVX is needed
ellipsoids_init();
disp([welcomeString,': done']);

