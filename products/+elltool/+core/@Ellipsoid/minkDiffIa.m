function [ resEllVec ] = minkDiffIa( ellObj1, ellObj2, dirMat)
% MINKDIFFIA - computes tight internal ellipsoidal approximation for
% Minkowsky difference of two generalized ellipsoids
%
% Input:
%   regular:
%       ellObj1: Ellipsoid: [1,1] - first generalized ellipsoid
%       ellObj2: Ellipsoid: [1,1] - second generalized ellipsoid
%       dirMat: double[nDim,nDir] - matrix whose columns specify
%           directions for which approximations should be computed
% Output:
%   resEllVec: Ellipsoid[1,nDir] - vector of generalized ellipsoids of
%       internal approximation of the dirrence of first and second generalized
%       ellipsoids
%
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: 2012-11$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
%
% Literature:
% V.V.Shiryaev, 'About internal ellipsoidal approximations of attainability
% sets of linear systems under uncertanty'. Moscow University Vestnik,
% Ser.15, Computational mathematics and cybernetics, 2012, N3, p. 20-27.
%
import modgen.common.throwerror
import elltool.core.Ellipsoid;
%
modgen.common.type.simple.checkgenext(@(x,y)isa(x,...
    'elltool.core.Ellipsoid')&&...
    isa(y,'elltool.core.Ellipsoid'),2,ellObj1,ellObj2)
%
modgen.common.type.simple.checkgenext('isscalar(x1)&&isscalar(x2)',...
    2,ellObj1,ellObj2);
%
ell1DiagVec=diag(ellObj1.diagMat);
[mSize nDirs]=size(dirMat);
nDimSpace=length(ell1DiagVec);
%Check whether one ellipsoid is bigger then the other
absTol=ellObj1.CHECK_TOL;
isFirstBigger=Ellipsoid.checkBigger(ellObj1,ellObj2,nDimSpace,absTol);
if ~isFirstBigger
    throwerror('wrongElls',...
        ['geometric difference of these ',...
        'two ellipsoids is an empty set']);
end
%
if mSize~=nDimSpace
    throwerror('wrongDir',...
        ['dimension of the direction vectors ',...
        'must be the same as dimension of ellipsoids']);
end
%
resCenterVec=ellObj1.centerVec-ellObj2.centerVec;
resEllVec(nDirs)=Ellipsoid();
for iDir=1:nDirs
    curDirVec=dirMat(:,iDir);
    isInf1Vec=ell1DiagVec==Inf;
    if ~all(~isInf1Vec)
        [ resQMat diagQVec ] = Ellipsoid.findDiffINFC(@Ellipsoid.findDiffIaND, ellObj1,ellObj2,curDirVec,isInf1Vec,...
            absTol);
        resEllVec(iDir)=Ellipsoid(resCenterVec,diagQVec,resQMat);
    else
        %Finite case
        ellQ1Mat=ellObj1.eigvMat*ellObj1.diagMat*ellObj1.eigvMat.';
        ellQ2Mat=ellObj2.eigvMat*ellObj2.diagMat*ellObj2.eigvMat.';
        resQMat=Ellipsoid.findDiffFC(@Ellipsoid.findDiffIaND,ellQ1Mat,ellQ2Mat,...
            curDirVec,absTol);
        resEllVec(iDir)=Ellipsoid(resCenterVec,resQMat);
    end
end
end
