A = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
B = {'10' '0'; '0' '1/(2 + sin(t))'};
CB = ell_unitball(2);
G = [1; 0];
V.center = {'2*cos(t)'};
V.shape = {'0.09*(sin(t))^2'};
%V.shape = {'1'};
%
s = elltool.linsys.LinSysFactory.create(A, B, CB, G, V);
X0 = 1e-4 * ell_unitball(2);
L0 = [1 0; 0 1];
try
    rs = elltool.reach.ReachContinuous(s, X0, L0, [0 4],...
        'isRegEnabled', true, 'isJustCheck', false, 'regTol', 0.009);
catch exception
    exception.identifier
end
% %%
% %
% % This demo presents functions for reachability analysis and verification of linear dynamical systems.
% import elltool.conf.Properties;
% %%
% %
% % Consider simple RLC circuit with two bounded inputs - current i(t) and voltage v(t) sources, as shown in the picture.
% % The equations of this circuit are based on Ohm's and Kirchoff's laws.
% R = 4;
% R2 = 2;
% L = 0.5;
% L2 = 1;
% C = 0.1;
% %%
% % Using capacitor voltage and inductor current as state variables, we arrive at the linear system shown above. Now we assign A and B matrix values, define control bounds CB and declare a linear system object lsys:
% %
% % >> R = 4; L = 0.5; C = 0.1;
% % >> A = [0 -1/C; 1/L -R/L];
% % >> B = [1/C 0; 0 1/L];
% % >> CB = ell_unitball(2);
% % >> lsys = elltool.linsys.LinSysFactory.create(A, B, CB);
% A = [0 -1/C; 1/L -R/L];
% B = [1/C 0; 0 1/L];
% CB = ell_unitball(2);
% A2 = [0 -1/C; 1/L2 -R2/L2];
% B2 = [1/C 0; 0 1/L2];
% X0 = 1e-5 * ell_unitball(2);
% T = 10;
% L0 = [1 0; 0 1]';
% s = elltool.linsys.LinSysFactory.create(A, B, CB);
% s2 = elltool.linsys.LinSysFactory.create(A2, B2, CB);
% %%
% % We are ready to compute the reach set approximations of this system on some time interval, say T = [0, 10], for zero initial conditions and plot them:
% %
% % >> X0 = 0.00001*ell_unitball(2);
% % >> T = 10;
% % >> L0 = [1 0; 0 1]';
% % >> rs = elltool.reach.ReachContinuous(lsys, X0, L0, T);
% % >> rs.plot_ea(); hold on;
% % >> rs.plot_ia();
% % >> ylabel('V_C'); zlabel('i_L');
% %
% % On your screen you see the reach set evolving in time from 0 to 10 (reach tube). Its external and internal approximations are computed for two directions specified by matrix L0. Function 'plot_ea' plots external (blue by default), and function 'plot_ia' - internal (green by default) approximations.
% 
% 
% try
%     rs = elltool.reach.ReachContinuous(s, X0, L0, [0 T],...
%     'isRegEnabled', false, 'isJustCheck', false, 'regTol', 1e-4);
% catch exception
%    exception.identifier
% end