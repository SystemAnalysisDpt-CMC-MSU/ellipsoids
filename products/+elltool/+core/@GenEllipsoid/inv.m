function ellInvObj = inv( ellObj )
% INV - create generalized ellipsoid whose matrix in pseudoinverse
%       to the matrix of input generalized ellipsoid
%
% Input:
%   regular:
%       ellObj: GenEllipsoid: [1,1] - generalized ellipsoid
%
% Output:
%   ellInvObj: GenEllipsoid: [1,1] - inverse generalized ellipsoid
% 
% Example:
%   ellObj = elltool.core.GenEllipsoid([5;2], [1 0; 0 0.7]);
%   ellObj.inv()
%      |    
%      |----- q : [5 2]
%      |          -----------------
%      |----- Q : |1      |0      |
%      |          |0      |1.42857|
%      |          -----------------
%      |          -----
%      |-- QInf : |0|0|
%      |          |0|0|
%      |          -----
% 
%
%$Author: Vitaly Baranov  <vetbar42@gmail.com> $
%$Date: Nov-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import elltool.core.GenEllipsoid;
import elltool.conf.Properties;
modgen.common.type.simple.checkgenext(@(x)isa(x,'elltool.core.GenEllipsoid'),...
    1,ellObj);
modgen.common.type.simple.checkgenext('isscalar(x1)',1,ellObj);
%
absTol=ellObj.CHECK_TOL;
%
diagVec=diag(ellObj.diagMat);
isInfVec=diagVec==Inf;
isZeroVec=abs(diagVec)<absTol;
isFinNZVec=(~isInfVec) | (~isZeroVec);
diagVec(isFinNZVec)=1./diagVec(isFinNZVec);
diagVec(isInfVec)=0;
diagVec(isZeroVec)=Inf;
ellInvObj=GenEllipsoid(ellObj.centerVec,diagVec,ellObj.eigvMat);