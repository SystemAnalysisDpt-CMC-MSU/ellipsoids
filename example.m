A = {'0' '-10'; '1/(2 + sin(t))' '-4/(2 + sin(t))'};
B = {'10' '0'; '0' '1/(2 + sin(t))'};
CB = ell_unitball(2);
G = [1; 0];
V.center = {'2*cos(t)'};
V.shape = {'0.09*(sin(t))^2'};
s = elltool.linsys.LinSysFactory.create(A, B, CB, G, V);
X0 = 1e-4*ell_unitball(2);
L0 = [1 0; 0 1];
rs = elltool.reach.ReachContinuous(s, X0, L0, [0 4],...
    'isJustCheck', false, 'regTol', 1e-4);