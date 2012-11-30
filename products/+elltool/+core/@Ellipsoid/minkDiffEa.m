function [ resEllVec ] = minkDiffEa( ellObj1, ellObj2, dirMat)
% MINKDIFFEA - computes tight external ellipsoidal approximation for 
%              Minkowsky difference of two generalized ellipsoids
%
% Input:
%       ellObj1: Ellipsoid: [1,1] - first generalized ellipsoid   
%       ellObj2: Ellipsoid: [1,1] - second generalized ellipsoid       
%       dirMat: double[nDim,nDir] - matrix whose columns specify 
%       directions for which approximations should be computed
% Output:
%   resEllVec: Ellipsoid[1,nDir] - vector of generalized ellipsoids of 
%   external approximation of the dirrence of first and second generalized
%   ellipsoids (may contain empty ellipsoids if in specified 
%   directions approximation cannot be computed)
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
    absTol=Ellipsoid.CHECK_TOL;
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
    isFirstBigger=checkBigger(ellObj1,ellObj2,nDimSpace,absTol);
    if ~isFirstBigger
        throwerror('wrongElls',...
            'MINKDIFF_IA: geometric difference of these two ellipsoids is an empty set');
    end
    %
    if mSize~=nDimSpace
        throwerror('wrongDir',...
            'MINKDIFF_EA: dimension of the direction vectors must be the same as dimension of ellipsoids');
    end
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
             [orthBasMat rangInf]=findBasRang(allInfDirMat,absTol);
             infIndVec=1:rangInf;
             finIndVec=(rangInf+1):nDimSpace;
             infBasMat=orthBasMat(:,infIndVec);
             finBasMat = orthBasMat(:,finIndVec);
             %Find projections on nonInf directions
             isInf2Vec=ell2DiagVec==Inf;
             ell1DiagVec(isInf1Vec)=0;
             ell2DiagVec(isInf2Vec)=0;
             curEllMat=eigv1Mat*diag(ell1DiagVec)*eigv1Mat.';
             resProjQ1Mat=finBasMat.'*curEllMat*finBasMat;
             resProjQ1Mat=0.5*(resProjQ1Mat+resProjQ1Mat.');
             curEllMat=eigv2Mat*diag(ell2DiagVec)*eigv2Mat.';
             resProjQ2Mat=finBasMat.'*curEllMat*finBasMat;
             resProjQ2Mat=0.5*(resProjQ2Mat+resProjQ2Mat.');
             curProjDirVec=finBasMat.'*curDirVec;
             if all(abs(curProjDirVec)<absTol)
                 resQMat=orthBasMat;
                diagQVec=zeros(nDimSpace,1);
                diagQVec(infIndVec)=Inf;
             else
                 %Find result in finite projection
                 finEllMat=findDiffEaFC(resProjQ1Mat,resProjQ2Mat,...
                     curProjDirVec,nDimSpace-rangInf,absTol);
                 if isempty(finEllMat)
                     resQMat=[];
                 else
                     %Construct result
                     [eigPMat diaPMat]=eig(finEllMat);
                     resQMat=zeros(nDimSpace);
                     basNZMat=finBasMat*eigPMat;
                     resQMat(:,finIndVec)=basNZMat;
                     resQMat(:,infIndVec)=infBasMat;
                     diagQVec=zeros(nDimSpace,1);
                     diagQVec(finIndVec)=diag(diaPMat);
                     diagQVec(infIndVec)=Inf;
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
                [orthBasMat rangZ]=findBasRang(zeroDirMat,absTol);
                %rangZ>0 since there is at least one zero e.v. Q1
                zeroIndVec=1:rangZ;
                nonZeroIndVec=(rangZ+1):nDimSpace;
                zeroBasMat=orthBasMat(:,zeroIndVec);
                nonZeroBasMat = orthBasMat(:,nonZeroIndVec);
                projCurDirVec=nonZeroBasMat.'*curDirVec;
                projQ1Mat=nonZeroBasMat.'*ellQ1Mat*nonZeroBasMat;
                projQ1Mat=0.5*(projQ1Mat+projQ1Mat.');
                projQ2Mat=nonZeroBasMat.'*ellQ2Mat*nonZeroBasMat;
                projQ2Mat=0.5*(projQ2Mat+projQ2Mat.');
                resProjQMat=findDiffEaND(projQ1Mat,...
                    projQ2Mat,projCurDirVec,absTol);
                if isempty(resProjQMat)
                    resEllVec(iDir)=Ellipsoid();
                else
                    %Construct the result
                    [eigPMat diaPMat]=eig(resProjQMat);
                    resQMat=zeros(nDimSpace);
                    basNZMat=nonZeroBasMat*eigPMat;
                    resQMat(:,nonZeroIndVec)=basNZMat;
                    resQMat(:,zeroIndVec)=zeroBasMat;
                    diagQVec=zeros(nDimSpace,1);
                    diagQVec(nonZeroIndVec)=diag(diaPMat);
                    resEllMat=resQMat*diag(diagQVec)*resQMat.';
                    resEllMat=0.5*(resEllMat+resEllMat);
                    resEllVec(iDir)=Ellipsoid(resCenterVec,resEllMat);
                    %find projection of all ellipsoids on zeroBasMat
                end
             end
         end
    end
end
%
function resEllMat=findDiffEaFC(ellQ1Mat, ellQ2Mat,curDirVec,...
    nDimSpace,absTol)
    [eigv1Mat dia1Mat]=eig(ellQ1Mat);
    ell1DiagVec=diag(dia1Mat);
    %
    if min(ell1DiagVec)>absTol
        resEllMat=findDiffEaND(ellQ1Mat,ellQ2Mat,curDirVec,absTol);
    else
        %find projection on non-zero space of Q2
        isZeroVec=abs(ell1DiagVec)<absTol;
        zeroDirMat=eigv1Mat(:,isZeroVec);
        % Find basis in all space
        [orthBasMat rangZ]=findBasRang(zeroDirMat,absTol);
        %rangZ>0 since there is at least one zero e.v. Q1
        zeroIndVec=1:rangZ;
        nonZeroIndVec=(rangZ+1):nDimSpace;
        zeroBasMat=orthBasMat(:,zeroIndVec);
        nonZeroBasMat = orthBasMat(:,nonZeroIndVec);
        projCurDirVec=nonZeroBasMat.'*curDirVec;
        projQ1Mat=nonZeroBasMat.'*ellQ1Mat*nonZeroBasMat;
        projQ2Mat=nonZeroBasMat.'*ellQ2Mat*nonZeroBasMat;
        projQ1Mat=0.5*(projQ1Mat+projQ1Mat.');
        projQ2Mat=0.5*(projQ2Mat+projQ2Mat.');
        resProjQMat=findDiffEaND(projQ1Mat,projQ2Mat,projCurDirVec,absTol);
        if isempty(resProjQMat)
            resEllMat=[];
        else
            [eigPMat diaPMat]=eig(resProjQMat);
            resQMat=zeros(nDimSpace);
            basNZMat=nonZeroBasMat*eigPMat;
            resQMat(:,nonZeroIndVec)=basNZMat;
            resQMat(:,zeroIndVec)=zeroBasMat;
            diagQVec=zeros(nDimSpace,1);
            diagQVec(nonZeroIndVec)=diag(diaPMat);
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
     if isGoodDir(ellQ1Mat,ellQ2Mat,curDirVec)
        ellSQR1Mat=findSqrtOfMatrix(ellQ1Mat,absTol);
        ellSQR2Mat=findSqrtOfMatrix(ellQ2Mat,absTol);
        sOrthMat=  gras.la.orthtransl(ellSQR2Mat*curDirVec,...
            ellSQR1Mat*curDirVec);
        auxMat=ellSQR1Mat-sOrthMat*ellSQR2Mat;
        resQMat=auxMat.'*auxMat;
        resQMat=0.5*(resQMat+resQMat.');
     else
         resQMat=[];
     end
end