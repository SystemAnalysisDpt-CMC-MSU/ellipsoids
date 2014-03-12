function dtdist2
dt = 0.05;
w = 0.2;
aMat=[0 1; -w 0];
firstBMat=[1.5 0; 0 1];
secondBMat=[0.5 0;0 0.5];
cVec=[1 0]; 
d=0; 
syst1=ss(aMat,firstBMat,cVec,d); 
syst2=ss(aMat,secondBMat,cVec,d); 
systd1=c2d(syst1,dt); 
systd2=c2d(syst2,dt); 
eA = systd1.a;
eB = systd1.b;
eB2 = systd2.b;

X0 = ell_unitball(2);

U = ell_unitball(2);
U3 = ell_unitball(1);
V = ell_unitball(2);
o = [];

dSys = elltool.linsys.LinSysDiscrete(eA, eB, U, eB2, V, [], [], 'd');

phiVec = 0:0.1:pi;
dirsMat = [cos(phiVec); sin(phiVec)];
stepsVec = [0 50];

firstRsObj = elltool.reach.ReachDiscrete(dSys, X0, dirsMat, stepsVec);

o.minmax = 1;

secondRsObj = elltool.reach.ReachDiscrete(dSys, X0, dirsMat, stepsVec);

firstRsObj.plotByEa(); hold on;
secondRsObj.plotByEa('g'); hold on;

end