function [ resEllVec ] = minkDiffEa( ellObj1, ellObj2, dirMat)
% MINKDIFFEA - computes tight external ellipsoidal approximation for
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
%       external approximation of the dirrence of first and second generalized
%       ellipsoids (may contain empty ellipsoids if in specified
%       directions approximation cannot be computed)
%
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: 2012-11$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
%
%
import elltool.core.Ellipsoid;
import modgen.common.throwerror
%
modgen.common.type.simple.checkgenext(@(x,y)isa(x,...
    'elltool.core.Ellipsoid')&&isa(y,'elltool.core.Ellipsoid'),...
    2,ellObj1,ellObj2)
%
modgen.common.type.simple.checkgenext('isscalar(x1)&&isscalar(x2)',...
    2,ellObj1,ellObj2);
%
ell1DiagVec=diag(ellObj1.diagMat);
ell2DiagVec=diag(ellObj2.diagMat);
[mSize nDirs]=size(dirMat);
nDimSpace=length(ell1DiagVec);
%
%Check whether one ellipsoid is bigger then the other
absTol=ellObj1.CHECK_TOL;
isFirstBigger=Ellipsoid.checkBigger(ellObj1,ellObj2,nDimSpace,absTol);
if ~isFirstBigger
    throwerror('wrongElls',...
        'MINKDIFF_IA: geometric difference of these two',...
        'ellipsoids is an empty set');
end
%
if mSize~=nDimSpace
    throwerror('wrongDir',...
        'MINKDIFF_EA: dimension of the direction vectors',...
        'must be the same as dimension of ellipsoids');
end
%
resCenterVec=ellObj1.centerVec-ellObj2.centerVec;
resEllVec(nDirs)=Ellipsoid();
for iDir=1:nDirs
    curDirVec=dirMat(:,iDir);
    isInf1Vec=ell1DiagVec==Inf;
    if ~all(~isInf1Vec)
        %Infinite case
        eigv1Mat=ellObj1.eigvMat;
        eigv2Mat=ellObj2.eigvMat;
        allInfDirMat=eigv1Mat(:,isInf1Vec);
        [ infBasMat,  finBasMat, infIndVec, finIndVec] =...
            Ellipsoid.findSpaceBas( allInfDirMat,absTol );
        %Find projections on nonInf directions
        isInf2Vec=ell2DiagVec==Inf;
        ell1DiagVec(isInf1Vec)=0;
        ell2DiagVec(isInf2Vec)=0;
        curProjDirVec=finBasMat.'*curDirVec;
        resProjQ1Mat=Ellipsoid.findMatProj(eigv1Mat,...
            diag(ell1DiagVec),finBasMat);
        resProjQ2Mat=Ellipsoid.findMatProj(eigv2Mat,...
            diag(ell2DiagVec),finBasMat);
        if all(abs(curProjDirVec)<absTol)
            resQMat=orthBasMat;
            diagQVec=zeros(nDimSpace,1);
            diagQVec(infIndVec)=Inf;
        else
            %Find result in finite projection
            finDimSpace=length(finIndVec);
            infDimSpace=nDimSpace-finDimSpace;
            finEllMat=findDiffEaFC(resProjQ1Mat,resProjQ2Mat,...
                curProjDirVec,absTol);
            if isempty(finEllMat)
                resQMat=[];
            else
                [diagQVec, resQMat]=Ellipsoid.findConstruction(...
                    finEllMat,finBasMat,infBasMat,finIndVec,...
                    infIndVec,Inf*ones(1,infDimSpace));
            end
        end
        if ~isempty(resQMat)
            resEllVec(iDir)=Ellipsoid(resCenterVec,diagQVec,resQMat);
        else
            resEllVec(iDir)=Ellipsoid();
        end
    else
        %Finite case
        ellQ1Mat=ellObj1.eigvMat*ellObj1.diagMat*ellObj1.eigvMat.';
        ellQ2Mat=ellObj2.eigvMat*ellObj2.diagMat*ellObj2.eigvMat.';
        if min(ell1DiagVec)>absTol
            %Non-degenerate
            resQMat=findDiffEaND(ellQ1Mat,ellQ2Mat,curDirVec,absTol);
            if isempty(resQMat)
                resEllVec(iDir)=Ellipsoid();
            else
                resEllVec(iDir)=Ellipsoid(resCenterVec,resQMat);
            end
        else
            %Degenerate
            %find projection on non-zero space of Q2
            isZeroVec=abs(ell1DiagVec)<absTol;
            eigv1Mat=ellObj1.eigvMat;
            zeroDirMat=eigv1Mat(:,isZeroVec);
            % Find basis in all space
            [ zeroBasMat,  nonZeroBasMat, zeroIndVec, nonZeroIndVec] =...
                Ellipsoid.findSpaceBas( zeroDirMat,absTol );
            projCurDirVec=nonZeroBasMat.'*curDirVec;
            projQ1Mat=Ellipsoid.findMatProj(ellObj1.eigvMat,...
                ellObj1.diagMat,nonZeroBasMat);
            projQ2Mat=Ellipsoid.findMatProj(ellObj2.eigvMat,...
                ellObj2.diagMat,nonZeroBasMat);
            resProjQMat=findDiffEaND(projQ1Mat,...
                projQ2Mat,projCurDirVec,absTol);
            if isempty(resProjQMat)
                resEllVec(iDir)=Ellipsoid();
            else
                zeroDimSpace=size(zeroBasMat,2);
                [diagQVec, resQMat]=Ellipsoid.findConstruction(...
                    resProjQMat,nonZeroBasMat,zeroBasMat,...
                    nonZeroIndVec,zeroIndVec,zeros(1,zeroDimSpace));
                resEllMat=resQMat*diag(diagQVec)*resQMat.';
                resEllMat=0.5*(resEllMat+resEllMat);
                resEllVec(iDir)=Ellipsoid(resCenterVec,resEllMat);
            end
        end
    end
end
end
%
function resEllMat=findDiffEaFC(ellQ1Mat, ellQ2Mat,curDirVec,...
    absTol)
import elltool.core.Ellipsoid;
[eigv1Mat dia1Mat]=eig(ellQ1Mat);
ell1DiagVec=diag(dia1Mat);
%
if min(ell1DiagVec)>absTol
    resEllMat=findDiffEaND(ellQ1Mat,ellQ2Mat,curDirVec,absTol);
elseif all(abs(ellQ2Mat)<absTol)
    resEllMat=ellQ1Mat;
else
    %find projection on non-zero space of Q2
    isZeroVec=abs(ell1DiagVec)<absTol;
    zeroDirMat=eigv1Mat(:,isZeroVec);
    % Find basis in all space
    [ zeroBasMat,  nonZeroBasMat, zeroIndVec, nonZeroIndVec] =...
        Ellipsoid.findSpaceBas( zeroDirMat,absTol );
    projCurDirVec=nonZeroBasMat.'*curDirVec;
    projQ1Mat=Ellipsoid.findMatProj(eye(size(ellQ1Mat)),...
        ellQ1Mat,nonZeroBasMat);
    projQ2Mat=Ellipsoid.findMatProj(eye(size(ellQ2Mat)),...
        ellQ2Mat,nonZeroBasMat);
    resProjQMat=findDiffEaND(projQ1Mat,projQ2Mat,projCurDirVec,absTol);
    if isempty(resProjQMat)
        resEllMat=[];
    else
        zeroDimSpace=size(zeroBasMat,2);
        [diagQVec, resQMat]=Ellipsoid.findConstruction(...
            resProjQMat,nonZeroBasMat,zeroBasMat,nonZeroIndVec,...
            zeroIndVec,zeros(1,zeroDimSpace));
        resEllMat=resQMat*diag(diagQVec)*resQMat.';
        resEllMat=0.5*(resEllMat+resEllMat);
    end
end
end
%
function resQMat=findDiffEaND(ellQ1Mat, ellQ2Mat,curDirVec,absTol)
%Find matrix of ellipsoids that is the result of
%external approximation of difference in direction curDirVec
import elltool.core.Ellipsoid;
if Ellipsoid.findIsGoodDir(ellQ1Mat,ellQ2Mat,curDirVec)
    ellSQR1Mat=Ellipsoid.findSqrtOfMatrix(ellQ1Mat,absTol);
    ellSQR2Mat=Ellipsoid.findSqrtOfMatrix(ellQ2Mat,absTol);
    sOrthMat=  gras.la.orthtransl(ellSQR2Mat*curDirVec,...
        ellSQR1Mat*curDirVec);
    auxMat=ellSQR1Mat-sOrthMat*ellSQR2Mat;
    resQMat=auxMat.'*auxMat;
    resQMat=0.5*(resQMat+resQMat.');
else
    resQMat=[];
end
end