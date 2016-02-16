%%Creation of GoodDirsContinuousGen class
% Here we create object of GoodDirsContinuousGen class
% where [t0, s] and [s, t1] are not singular
import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
import gras.ellapx.gen.RegProblemDynamicsFactory;
import gras.ellapx.lreachplain.GoodDirsContinuousGen;
%
At = [{'1'}, {'0'}, {'1'};
      {'0'}, {'cos(t)'}, {'0'};
      {'0'}, {'0'}, {'1'}];
Bt = [{'1'};
      {'1'};
      {'1'}];
Pt = {'1'};
pt = {'0'};
Ct = [{'0'};
      {'0'};
      {'0'};];
Qt = {'0'};
qt = {'0'};
X0 = eye(3);
x0 = zeros(3, 1);
t0 = 0;
t1 = 10;
relTol = 1e-5;
absTol = 1e-5;
%
pDynObj = LReachProblemDynamicsFactory.createByParams(...
                At, Bt, Pt, pt, Ct, Qt, qt, X0, x0, [t0, t1], relTol, absTol);
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
%
sTime = 5;
GoodDirsContinuousGen(pDynObj, sTime, lsGoodDirMat, ...
    relTol, absTol);