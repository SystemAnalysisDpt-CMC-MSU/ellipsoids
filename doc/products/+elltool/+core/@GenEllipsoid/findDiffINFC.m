function [ resQMat diagQVec ] = findDiffINFC(fMethod, ellObj1,ellObj2,...
    curDirVec,isInf1Vec,isInfForFinBas,absTol)
% FINDDIFFINFC - find approximation for Minkowsky difference
%                of ellipsoids (first ellipsoid is exactly infinite)
%
% Input:
%   regular:
%       fMethod: function_handle: [1,1] - specify external or internal
%           approximation
%       ellObj1: GenEllipsoid: [1,1] - generalized ellipsoid
%       ellObj2: GenEllipsoid: [1,1] - generalized ellipsoid
%       curDirVec: double: [nSize,1] - direction of calculation
%       isInf1Vec: logical: [nSize,1] - specify which directions are
%           infinite for the first ellipsoid
%       isInfForFinBas: logical[1,1] - this flag is accounted for only when
%           curDirVec is completely in the infinite subspace of the
%           approximation. Then, if isInfForFinBas=true, the approximation
%           for this finite subspace is set te be infinite 
%           (this is used for external approximations) and finite
%           otherwise.
%       absTol: double: [1,1] - absolute tolerance
%
% Output:
%   resQMat: double: [nSize,nSize]/[0,0] - matrix of eigenvectors of
%       approximation ellipsoid. Empty when for external approximation the
%       specified direction is bad.
%   diagQMat: double: [nSize,nSize]/[0,0] - matrix of eigenvalues of
%       approximation ellipsoid. Empty when for external approximation the
%       specified direction is bad.
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
import elltool.core.GenEllipsoid;
eigv1Mat=ellObj1.eigvMat;
eigv2Mat=ellObj2.eigvMat;
ell1DiagVec=diag(ellObj1.diagMat);
ell2DiagVec=diag(ellObj2.diagMat);
nDimSpace=length(ell1DiagVec);
allInfDirMat=eigv1Mat(:,isInf1Vec);
[ infBasMat,  finBasMat, infIndVec, finIndVec] =...
    GenEllipsoid.findSpaceBas( allInfDirMat,absTol );
%Find projections on nonInf directions
isInf2Vec=ell2DiagVec==Inf;
ell1DiagVec(isInf1Vec)=0;
ell2DiagVec(isInf2Vec)=0;
curProjDirVec=finBasMat.'*curDirVec;
resProjQ1Mat=GenEllipsoid.findMatProj(eigv1Mat,...
    diag(ell1DiagVec),finBasMat);
resProjQ2Mat=GenEllipsoid.findMatProj(eigv2Mat,...
    diag(ell2DiagVec),finBasMat);
if all(abs(curProjDirVec)<absTol)
    resQMat=eye(nDimSpace);
    resQMat(:,infIndVec)=infBasMat;
    resQMat(:,finIndVec)=finBasMat;
    diagQVec=zeros(nDimSpace,1);
    diagQVec(infIndVec)=Inf;
    if isInfForFinBas
        diagQVec(finIndVec)=Inf;
    end
else
    %Find result in finite projection
    finDimSpace=length(finIndVec);
    infDimSpace=nDimSpace-finDimSpace;
    finEllMat=GenEllipsoid.findDiffFC(fMethod,resProjQ1Mat,resProjQ2Mat,...
        curProjDirVec,absTol);
    if isempty(finEllMat)
        resQMat=[];
        diagQVec=[];
    else
        [diagQVec, resQMat]=GenEllipsoid.findConstruction(...
            finEllMat,finBasMat,infBasMat,finIndVec,...
            infIndVec,Inf*ones(1,infDimSpace));
    end
end
end

