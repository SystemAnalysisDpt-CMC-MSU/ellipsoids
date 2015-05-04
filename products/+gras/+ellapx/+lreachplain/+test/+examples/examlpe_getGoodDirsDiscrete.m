%%Creation of GoodDirsContinuousDiscrete class
%
import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
import gras.ellapx.gen.RegProblemDynamicsFactory;
import gras.ellapx.lreachplain.GoodDirsDiscrete;
%
At = [{'1'}, {'1'}, {'1'};
      {'0'}, {'1'}, {'0'};
      {'1'}, {'t'}, {'1'}];
Bt = [{'1'};
      {'1'};
      {'t'}];
Pt = {'1'};
pt = {'0'};
Ct = [{'0'};
      {'t'};
      {'0'};];
Qt = {'0'};
qt = {'0'};
X0 = eye(3);
x0 = zeros(3, 1);
t0 = 0;
t1 = 10;
precision = 1e-5;
%
pDynObj = LReachProblemDynamicsFactory.createByParams(...
                At, Bt, Pt, pt, Ct, Qt, qt, X0, x0, [t0, t1], precision);
%
isRegEnabled = 1;
isJustCheck = 0;
regTol= 1e-5;
%
pDynObj = RegProblemDynamicsFactory.create(pDynObj,...
                isRegEnabled, isJustCheck, regTol);
%            
lsGoodDirMat = [1, 0, 0;
                1, 1, 0;
                0, 1, 1];            
normVec=sum(lsGoodDirMat.*lsGoodDirMat);
indVec=find(normVec);
normVec(indVec)=realsqrt(normVec(indVec));
lsGoodDirMat(:,indVec)=lsGoodDirMat(:,indVec)./normVec(ones(1,size(At, 1)),...
    indVec);
sTime = 5;
%
GoodDirsDiscrete(pDynObj, sTime, lsGoodDirMat, ...
    precision, precision);