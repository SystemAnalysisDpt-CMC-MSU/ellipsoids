dt = 0.05;
w = 0.2;
A=[0 1; -w 0];
B1=[1.5 0; 0 1];
%B1=[1;0];
B2=[0.5 0;0 0.5];
C=[1 0]; 
D=0; 
syst1=ss(A,B1,C,D); 
syst2=ss(A,B2,C,D); 
systd1=c2d(syst1,dt); 
systd2=c2d(syst2,dt); 
sysStruct1=mpt_sys(systd1); 
sysStruct2=mpt_sys(systd2); 
eA = systd1.a;
eB = systd1.b;
eB2 = systd2.b;

X0 = ell_unitball(2);

U = ell_unitball(2);
U3 = ell_unitball(1);
V = ell_unitball(2);
o = [];

s = linsys(eA, eB, U, eB2, V, [], [], 'd');
%s = linsys(eA, eB, U3, [], [], [], [], 'd');

phi = 0:0.1:pi;
L = [cos(phi); sin(phi)];
%L = [1 0; 0 1; 1 1; 1 -1]';
N = 50;

rs1 = reach(s, X0, L, N, o);

o.minmax = 1;

rs2 = reach(s, X0, L, N, o);

plotByEa(rs1); hold on;
plotByEa(rs2, 'g'); hold on;
