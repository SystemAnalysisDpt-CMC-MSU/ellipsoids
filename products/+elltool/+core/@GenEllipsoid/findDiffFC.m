function [ resEllMat ] = findDiffFC( fMethod, ellQ1Mat, ellQ2Mat,...
    curDirVec,absTol )
% FINDDIFFFC - find approximation for Minkowsky difference
%              of finite ellipsoids
%
% Input:
%   regular:
%       fMethod: function_handle: [1,1] - specify external or internal
%           approximation
%       ellQ1Mat: double: [kSize,kSize] - matrix of first ellipsoid
%       ellQ2Mat: double: [kSize,kSize] - matrix of second ellipsoid
%       curDirVec: double: [kSize,1] - direction of calculation
%       absTol: double: [1,1] - absolute tolerance
%
% Output:
%   resEllMat: double: [kSize,kSize]\[0,0] - matrix of approximating 
%       ellipsoid. Empty when for external approximation the
%       specified direction is bad.
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
import elltool.core.GenEllipsoid;
[eigv1Mat dia1Mat]=eig(ellQ1Mat);
ell1DiagVec=diag(dia1Mat);
if min(ell1DiagVec)>absTol
    resEllMat=fMethod(ellQ1Mat,ellQ2Mat,curDirVec,absTol);
elseif all(abs(ellQ2Mat)<absTol)
    resEllMat=ellQ1Mat;
else
    isZeroVec=abs(ell1DiagVec)<absTol;
    zeroDirMat=eigv1Mat(:,isZeroVec);
    % Find basis in all space
    [ zeroBasMat,  nonZeroBasMat, zeroIndVec, nonZeroIndVec] =...
        GenEllipsoid.findSpaceBas( zeroDirMat,absTol );
    projCurDirVec=nonZeroBasMat.'*curDirVec;
    projQ1Mat=GenEllipsoid.findMatProj(eye(size(ellQ1Mat)),...
        ellQ1Mat,nonZeroBasMat);
    projQ2Mat=GenEllipsoid.findMatProj(eye(size(ellQ2Mat)),...
        ellQ2Mat,nonZeroBasMat);
    resProjQMat=fMethod(projQ1Mat,projQ2Mat,projCurDirVec,absTol);
    if isempty(resProjQMat)
        resEllMat=[];
    else
        zeroDimSpace=size(zeroBasMat,2);
        [diagQVec, resQMat]=GenEllipsoid.findConstruction(...
            resProjQMat,nonZeroBasMat,zeroBasMat,nonZeroIndVec,...
            zeroIndVec,zeros(1,zeroDimSpace));
        resEllMat=resQMat*diag(diagQVec)*resQMat.';
        resEllMat=0.5*(resEllMat+resEllMat);
    end
end
end