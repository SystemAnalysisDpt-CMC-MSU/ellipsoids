function ellInvObj = inv( ellObj )
% INV - create generalized ellipsoid whose matrix in pseudoinverse
% to the matrix of input generalized ellipsoid
%
% Input:
%   regular:
%       ellObj: Ellipsoid: [1,1] - generalized ellipsoid
%
% Output:
%   ellInvObj: Ellipsoid: [1,1] - inverse generalized ellipsoid
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
%
%
import elltool.core.Ellipsoid;
import elltool.conf.Properties;
modgen.common.type.simple.checkgenext(@(x)isa(x,'elltool.core.Ellipsoid'),...
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
ellInvObj=Ellipsoid(ellObj.centerVec,diagVec,ellObj.eigvMat);
end
