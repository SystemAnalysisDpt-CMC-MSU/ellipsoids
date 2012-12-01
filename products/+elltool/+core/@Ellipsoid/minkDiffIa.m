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
ell2DiagVec=diag(ellObj2.diagMat);
[mSize nDirs]=size(dirMat);
nDimSpace=length(ell1DiagVec);
%Check whether one ellipsoid is bigger then the other
absTol=ellObj1.CHECK_TOL;
isFirstBigger=Ellipsoid.checkBigger(ellObj1,ellObj2,nDimSpace,absTol);
if ~isFirstBigger
    throwerror('wrongElls',...
        'MINKDIFF_IA: geometric difference of these',...
        'two ellipsoids is an empty set');
end
%
if mSize~=nDimSpace
    throwerror('wrongDir',...
        'MINKDIFF_IA: dimension of the direction vectors',...
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
        isInf2Vec=ell2DiagVec==Inf;
        ell1DiagVec(isInf1Vec)=0;
        ell2DiagVec(isInf2Vec)=0;
        resProjQ1Mat=Ellipsoid.findMatProj(eigv1Mat,...
            diag(ell1DiagVec),finBasMat);
        resProjQ2Mat=Ellipsoid.findMatProj(eigv2Mat,...
            diag(ell2DiagVec),finBasMat);
        curProjDirVec=finBasMat.'*curDirVec;
        if all(abs(curProjDirVec)<absTol)
            resQMat=eye(nDimSpace);
            resQMat(:,infIndVec)=infBasMat;
            resQMat(:,finIndVec)=finBasMat;
            diagQVec=zeros(nDimSpace,1);
            diagQVec(infIndVec)=Inf;
        else
            %Find result in finite projection
            rangFin=size(finBasMat,2);
            infDimSpace=nDimSpace-rangFin;
            finEllMat=findDiffIaFC(resProjQ1Mat,resProjQ2Mat,...
                curProjDirVec,absTol);
            [diagQVec, resQMat]=Ellipsoid.findConstruction(...
                finEllMat,finBasMat,infBasMat,finIndVec,...
                infIndVec,Inf*ones(1,infDimSpace));
        end
        resEllVec(iDir)=Ellipsoid(resCenterVec,diagQVec,resQMat);
    else
        %Finite case
        ellQ1Mat=ellObj1.eigvMat*ellObj1.diagMat*ellObj1.eigvMat.';
        ellQ2Mat=ellObj2.eigvMat*ellObj2.diagMat*ellObj2.eigvMat.';
        if min(ell1DiagVec)>absTol
            %Non-degenerate
            resQMat=findDiffIaND(ellQ1Mat,ellQ2Mat,curDirVec,absTol);
            resEllVec(iDir)=Ellipsoid(resCenterVec,resQMat);
        else
            %Degenerate
            isZeroVec=abs(ell1DiagVec)<absTol;
            eigv1Mat=ellObj1.eigvMat;
            zeroDirMat=eigv1Mat(:,isZeroVec);
            % Find basis in all space
            [ zeroBasMat,  nonZeroBasMat, zeroIndVec, nonZeroIndVec] =...
                Ellipsoid.findSpaceBas( zeroDirMat,absTol );
            projCurDirVec=nonZeroBasMat.'*curDirVec;
            projQ1Mat=Ellipsoid.findMatProj(eye(size(ellQ1Mat)),...
                ellQ1Mat,nonZeroBasMat);
            projQ2Mat=Ellipsoid.findMatProj(eye(size(ellQ2Mat)),...
                ellQ2Mat,nonZeroBasMat);
            resProjQMat=findDiffIaND(projQ1Mat,projQ2Mat,...
                projCurDirVec,absTol);
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
%
function resEllMat=findDiffIaFC(ellQ1Mat, ellQ2Mat,curDirVec,...
    absTol)
import elltool.core.Ellipsoid;
[eigv1Mat dia1Mat]=eig(ellQ1Mat);
ell1DiagVec=diag(dia1Mat);
if min(ell1DiagVec)>absTol
    resEllMat=findDiffIaND(ellQ1Mat,ellQ2Mat,curDirVec,absTol);
else
    isZeroVec=abs(ell1DiagVec)<absTol;
    zeroDirMat=eigv1Mat(:,isZeroVec);
    [ zeroBasMat,  nonZeroBasMat, zeroIndVec, nonZeroIndVec] =...
        Ellipsoid.findSpaceBas( zeroDirMat,absTol );
    projCurDirVec=nonZeroBasMat.'*curDirVec;
    projQ1Mat=Ellipsoid.findMatProj(eye(size(ellQ1Mat)),...
        ellQ1Mat,nonZeroBasMat);
    projQ2Mat=Ellipsoid.findMatProj(eye(size(ellQ2Mat)),...
        ellQ2Mat,nonZeroBasMat);
    resProjQMat=findDiffIaND(projQ1Mat,projQ2Mat,projCurDirVec,absTol);
    zeroDimSpace=size(zeroBasMat,2);
    [diagQVec, resQMat]=Ellipsoid.findConstruction(resProjQMat,...
        nonZeroBasMat,zeroBasMat,nonZeroIndVec,zeroIndVec,...
        zeros(1,zeroDimSpace));
    resEllMat=resQMat*diag(diagQVec)*resQMat.';
    resEllMat=0.5*(resEllMat+resEllMat);
end
end
function resQMat=findDiffIaND(ellQ1Mat, ellQ2Mat,curDirVec,absTol)
%Find matrix of ellipsoids that is the result of
%internal approximation of difference in direction curDirVec
%Q1>0, Q2>=0
%ellQ1Mat>0, ellQ2Mat>=0.
% Solving det((1-x)Q1+(1-1/x)*Q2)=0 for x <=>
% det(Q2Q1^{-1}-x)=0.
% We need maximal root.
ellInvQ1Mat=ellQ1Mat\eye(size(ellQ1Mat));
[~,diagMat]=eig(ellQ2Mat*ellInvQ1Mat);
lamMax=max(diag(diagMat));
%
p1Par=sqrt(curDirVec.'*ellQ1Mat*curDirVec);
p2Par=sqrt(curDirVec.'*ellQ2Mat*curDirVec);
pPar=p2Par/p1Par;
pPar=max(lamMax,pPar); %this only line is according to article
if (pPar<absTol)
    resQMat=ellQ1Mat;
else
    resQMat=(1-pPar)*ellQ1Mat+(1-1/pPar)*ellQ2Mat;
    resQMat=0.5*(resQMat+resQMat.');
end
end