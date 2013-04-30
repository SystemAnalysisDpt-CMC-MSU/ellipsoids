function isBigger=checkBigger(ellObj1,ellObj2,nDimSpace,absTol)
% CHECKBIGGER - check whether one generalized ellipsoid is inside the other
% Input:
%   regular:
%       ellObj1: GenEllipsoid: [1,1] - first generalized ellipsoid
%       ellObj2: GenEllipsoid: [1,1] - second generalized ellipsoid
%       nDimSpace: double: [1,1] - dimension of space
%       absTol: double: [1,1] - absolute tolerance
% Output:
%   isBigger: logical: [1,1] - true if second ellipsoid is inside the
%       other and false otherwise
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%Algorithm:
%First, construct orthogonal bases of infinite directions for both
%ellipsoids and then check that these directions are collinear.
%Then find projections on nonifinite basis, which is the same for two
%ellipsoids. Then find zero directions among this basis for each of the
%ellipsoids ans check that directions in first ellipsoid correspond
%to zero directions of the second. Finally, project every ellipsoids
%on basis that doesnt contain zero directions for first ellipsoid and
%then use simultaneos diagonalization.
%
%Find infinite directions for each of the ellipsoids
import elltool.core.GenEllipsoid;

eigv1Mat=ellObj1.eigvMat;
eigv2Mat=ellObj2.eigvMat;
diag1Mat=ellObj1.diagMat;
diag2Mat=ellObj2.diagMat;
isInf1DirVec=diag(diag1Mat)==Inf;
isInf2DirVec=diag(diag2Mat)==Inf;
allInfDir1Mat=eigv1Mat(:,isInf1DirVec);
allInfDir2Mat=eigv2Mat(:,isInf2DirVec);
%Find basis for first ell
[orthBas1Mat rank1Inf]=GenEllipsoid.findBasRank(allInfDir1Mat,absTol);
%rankZ>0 since there is at least one zero e.v. Q1
finInd1Vec=(rank1Inf+1):nDimSpace;
finBas1Mat = orthBas1Mat(:,finInd1Vec);
%Find basis for second ell
[orthBas2Mat rank2Inf]=GenEllipsoid.findBasRank(allInfDir2Mat,absTol);
%rankZ>0 since there is at least one zero e.v. Q1
infInd2Vec=1:rank2Inf;
infBas2Mat=orthBas2Mat(:,infInd2Vec);
%
if isempty(finBas1Mat)
    isBigger=true;
else
    if (isempty(infBas2Mat))
        isInf2SubSInf1=true;
    else
        isInf2SubSInf1=all(all(abs(infBas2Mat.'*finBas1Mat)<absTol));
    end
    if isInf2SubSInf1
        %Further we consider only finite directions
        %Find zero directions of first ell in NonInf Space (Z1)
        isZeroDir1Vec=abs(diag(diag1Mat))<absTol;
        isNInfDir1Vec=~isInf1DirVec;
        isNotInfAndZeroVec=isNInfDir1Vec & isZeroDir1Vec;
        allNIZero1Mat=eigv1Mat(:,isNotInfAndZeroVec);
        isNotInfAndNotZeroVec=(~isInf1DirVec) & (~isZeroDir1Vec);
        allNINZ1Mat=eigv1Mat(:,isNotInfAndNotZeroVec);
        %
        %Zero direction for second
        isZeroDir2Vec=abs(diag(diag1Mat))<absTol;
        isNInfDir2Vec=~isInf2DirVec;
        isNotInfAndZeroVec=isNInfDir2Vec & isZeroDir2Vec;
        allNIZero2Mat=eigv2Mat(:,isNotInfAndZeroVec);
        %Non zero direction in Ell2 should be orthogonal to zero
        %directions in Ell1
        if (isempty(allNIZero1Mat)) && (~isempty(allNIZero2Mat))
            isBigger=false;
        else
            if ~isempty(allNIZero2Mat)
                auxMat=allNINZ1Mat.'*allNIZero2Mat;
                isOrth=all(all(abs(auxMat)<absTol));
            else
                isOrth=true;
            end
            if (~isOrth)
                isBigger=false;
            else
                %Check that projection of ell2 on zero directions  of ell1
                %is zero:
                curDiagMat=diag2Mat;
                curDiagMat(:,isInf2DirVec)=0;
                curEllMat=eigv2Mat*curDiagMat*eigv2Mat.';
                ell2ProjMat=allNIZero1Mat.'*curEllMat*allNIZero1Mat;
                if ~all(abs(ell2ProjMat(:))<absTol)
                    isBigger=false;
                else
                    %Project ell2 on non-zero directions of ell1
                    diag1Mat(isInf1DirVec,isInf1DirVec)=0;
                    curEllMat=eigv1Mat*diag1Mat*eigv1Mat.';
                    resProjQ1Mat=allNINZ1Mat.'*curEllMat*allNINZ1Mat;
                    resProjQ1Mat=0.5*(resProjQ1Mat+resProjQ1Mat.');
                    %
                    diag2Mat(isInf2DirVec,isInf2DirVec)=0;
                    curEllMat=eigv2Mat*diag2Mat*eigv2Mat.';
                    resProjQ2Mat=allNINZ1Mat.'*curEllMat*allNINZ1Mat;
                    resProjQ2Mat=0.5*(resProjQ2Mat+resProjQ2Mat.');
                    isBigger=contains(resProjQ1Mat,resProjQ2Mat,absTol);
                end
            end
        end
    else
        isBigger=false;
    end
end
end
function isContained=contains(ellQ1Mat,ellQ2Mat,absTol)
isContained=min(eig(ellQ1Mat-ellQ2Mat))>=-absTol;
end