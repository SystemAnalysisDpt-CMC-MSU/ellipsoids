function dtdist2

dt = 0.05;
w = 0.2;
aMat=[0 1; -w 0];
b1Mat=[1.5 0; 0 1];
b2Mat=[0.5 0;0 0.5];
cVec=[1 0]; 
d=0; 
cSys1=ss(aMat,b1Mat,cVec,d); 
cSys2=ss(aMat,b2Mat,cVec,d); 
dSys1=c2d(cSys1,dt); 
dSys2=c2d(cSys2,dt); 
sysStruct1=mpt_sys(dSys1); 
sysStruct2=mpt_sys(dSys2); 
eAMat = dSys1.a;
eBMat = dSys1.b;
eB2Mat = dSys2.b;

x0EllObj = ell_unitball(2);

uEllObj = ell_unitball(2);
u3EllObj = ell_unitball(1);
vEllObj = ell_unitball(2);

sys = elltool.linsys.LinSysDiscrete(eAMat, eBMat, uEllObj, eB2Mat, vEllObj, [], [], 'd');

phiVec = 0:0.1:pi;
dirsMat = [cos(phiVec); sin(phiVec)];
nSteps = 50;

rs1Obj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, [0 nSteps]);


rs2Obj = elltool.reach.ReachDiscrete(sys, x0EllObj, dirsMat, [0 nSteps],'isMinMax',true);

rs1Obj.plotByEa();
rs2Obj.plotByEa('g');

end