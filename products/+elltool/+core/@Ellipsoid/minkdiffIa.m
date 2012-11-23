function [ resEllVec ] = minkdiffIa( ellObj1, ellObj2, dirMat)
    import elltool.core.Ellipsoid;
    import modgen.common.throwerror
    CHECK_TOL=1e-9;
    %
    if (~isa(ellObj1,'Ellipsoid')) || (~isa(ellObj2,'Ellipsoid'))
        throwerror('wrongArgs',...
            'MINKDIFF_IA: first two arguments must be single ellipsoids');
    end
    [k1Size k2Size]=size(ellObj1);
    [m1Size m2Size]=size(ellObj2);
    if (k1Size~=1) || (k2Size~=1) || (m1Size~=1) || (m2Size~=1)
        throwerror('wrongElls',...
            'MINKDIFF_IA: first two arguments must be single ellipsoids');
    end
    %
    ell1DiagVec=diag(ellObj1.diagMat);
    ell2DiagVec=diag(ellObj2.diagMat);
    [mSize nDirs]=size(dirMat);
    nDimSpace=length(ell1DiagVec);
    %Check whether one ellipsoid is bigger then the other
    isFirstBigger=checkBigger(ellObj1,ellObj2,nDimSpace);
    if ~isFirstBigger
        throwerror('wrongElls',...
            'MINKDIFF_IA: geometric difference of these two ellipsoids is an empty set');
    end
    % 
    if mSize~=nDimSpace
        throwerror('wrongDir',...
            'MINKDIFF_IA: dimension of the direction vectors must be the same as dimension of ellipsoids');
    end
    %
    resCenterVec=ellObj1.centerVec-ellObj2.centerVec;
    resEllVec(nDirs)=Ellipsoid();
    for iDir=1:nDirs
         curDirVec=dirMat(:,iDir);
         isInf1Vec=ell1DiagVec==Inf;
         if ~all(isInf1Vec)
             %Infinite case
             eigv1Mat=ellObj1.eigvMat;
             eigv2Mat=ellObj2.eigvMat;   
             allInfDirMat=eigv1Mat(:,isInf1Vec);
             [orthBasMat rangInf]=findBasRang(allInfDirMat);
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
             curEllMat=eigv2Mat*diag(ell2DiagVec)*eigv2Mat.';
             resProjQ2Mat=finBasMat.'*curEllMat*finBasMat;
             curProjDirVec=finBasMat.'*curDirVec;
             if all(abs(curProjDirVec)<CHECK_TOL)
                 resQMat=orthBasMat;
                diagQVec=zeros(nDimSpace,1);
                diagQVec(infIndVec)=Inf;    
             else
                 %Find result in finite projection
                 finEllMat=findDiffIaFC(resProjQ1Mat,resProjQ2Mat,...
                     curProjDirVec,nDimSpace);
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
             resEllVec(iDir)=Ellipsoid(resCenterVec,diagQVec,resQMat);
         else
             %Finite case
             ellQ1Mat=ellObj1.eigvMat*ellObj1.diagMat*ellObj1.eigvMat.';
             ellQ2Mat=ellObj2.eigvMat*ellObj2.diagMat*ellObj2.eigvMat.';
             if min(ell1DiagVec)>CHECK_TOL
                %Non-degenerate
                resQMat=findDiffIaND(ellQ1Mat,ellQ2Mat,curDirVec);
                resEllVec(iDir)=Ellipsoid(resCenterVec,resQMat);
             else
                %Degenerate 
                %find projection on non-zero space of Q2
                isZeroVec=abs(ell1DiagVec)<CHECK_TOL;
                eigv1Mat=ellObj1.eigvMat;
                zeroDirMat=eigv1Mat(:,isZeroVec);
                % Find basis in all space
                [orthBasMat rangZ]=findBasRang(zeroDirMat);
                %rangZ>0 since there is at least one zero e.v. Q1
                zeroIndVec=1:rangZ;
                nonZeroIndVec=(rangZ+1):nDimSpace;
                zeroBasMat=orthBasMat(:,zeroIndVec);
                nonZeroBasMat = orthBasMat(:,nonZeroIndVec);
                projCurDirVec=nonZeroBasMat.'*curDirVec;
                projQ1Mat=nonZeroBasMat.'*ellQ1Mat*nonZeroBasMat;
                projQ2Mat=nonZeroBasMat.'*ellQ2Mat*nonZeroBasMat;
                resProjQMat=findDiffIaND(projQ1Mat,projQ2Mat,projCurDirVec);
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

function resEllMat=findDiffIaFC(ellQ1Mat, ellQ2Mat,curDirVec,nDimSpace)
    CHECK_TOL=1e-9;    
    [eigv1Mat dia1Mat]=eig(ellQ1Mat);
    ell1DiagVec=diag(dia1Mat);
    %
    if min(ell1DiagVec)>CHECK_TOL
        resEllMat=findDiffIaND(ellQ1Mat,ellQ2Mat,curDirVec);
    else
        %find projection on non-zero space of Q2
        isZeroVec=abs(ell1DiagVec)<CHECK_TOL;
        zeroDirMat=eigv1Mat(:,isZeroVec);
        % Find basis in all space
        [orthBasMat rangZ]=findBasRang(zeroDirMat);
        %rangZ>0 since there is at least one zero e.v. Q1
        zeroIndVec=1:rangZ;
        nonZeroIndVec=(rangZ+1):nDimSpace;
        zeroBasMat=orthBasMat(:,zeroIndVec);
        nonZeroBasMat = orthBasMat(:,nonZeroIndVec);
        projCurDirVec=nonZeroBasMat.'*curDirVec;
        projQ1Mat=nonZeroBasMat.'*ellQ1Mat*nonZeroBasMat;
        projQ2Mat=nonZeroBasMat.'*ellQ2Mat*nonZeroBasMat;
        resProjQMat=findDiffIaND(projQ1Mat,projQ2Mat,projCurDirVec);
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

function [orthBasMat rang]=findBasRang(qMat)
    CHECK_TOL=1e-9;
    [orthBasMat rBasMat]=qr(qMat);
    if size(rBasMat,2)==1
        isNeg=rBasMat(1)<0;
        orthBasMat(:,isNeg)=-orthBasMat(:,isNeg);
    else
        isNegVec=diag(rBasMat)<0;
        orthBasMat(:,isNegVec)=-orthBasMat(:,isNegVec);
    end
    tolerance = CHECK_TOL*norm(qMat,'fro');
    rang = sum(abs(diag(rBasMat)) > tolerance);
    rang = rang(1); %for case where rBasZMat is vector.
end
function isBigger=checkBigger(ellObj1,ellObj2,nDimSpace)
    %Algorithm: 
    %First construct orthogonal basises of infinite directions for both
    %ellipsoids and then check that these directions are collinear. 
    %Then find projections on nonifinite basis, whis is the same for two
    %ellipsoids. Then find zero directions among this basis for each of the
    %ellipsoids ans check that directions in first ellipsoid correspond 
    %to zero directions of the second. Finally, project every ellipsoids
    %on basis that doesnt contain zero directions for first ellipsoid and
    %then use simultaneos diagonalization. 
    %
    %
    CHECK_TOL=1e-9;
    %Find infinite directions for each of the ellipsoids
    eigv1Mat=ellObj1.eigvMat;
    eigv2Mat=ellObj2.eigvMat;
    diag1Mat=ellObj1.diagMat;
    diag2Mat=ellObj2.diagMat;
    isInf1DirVec=diag(diag1Mat)==Inf;
    isInf2DirVec=diag(diag2Mat)==Inf;
    allInfDir1Mat=eigv1Mat(:,isInf1DirVec);
    allInfDir2Mat=eigv2Mat(:,isInf2DirVec);
    %Find basis for first ell
    [orthBas1Mat rang1Inf]=findBasRang(allInfDir1Mat);
    %rangZ>0 since there is at least one zero e.v. Q1
    finInd1Vec=(rang1Inf+1):nDimSpace; 
    finBas1Mat = orthBas1Mat(:,finInd1Vec);
    %Find basis for second ell
    [orthBas2Mat rang2Inf]=findBasRang(allInfDir2Mat);
    %rangZ>0 since there is at least one zero e.v. Q1
    infInd2Vec=1:rang2Inf; 
    infBas2Mat=orthBas2Mat(:,infInd2Vec);
    %
    if isempty(finBas1Mat)
        isBigger=true;
    else
        if (isempty(infBas2Mat))
                isInf2SubSInf1=true;
        else
            isInf2SubSInf1=all(all(abs(infBas2Mat.'*finBas1Mat)<CHECK_TOL));
        end
        if isInf2SubSInf1
            %Further we consider only finite directions
            %Find zero directions of first ell in NonInf Space (Z1) 
            isZeroDir1Vec=abs(diag(diag1Mat))<CHECK_TOL;
            isNInfDir1Vec=~isInf1DirVec;
            isNotInfAndZeroVec=logical(isNInfDir1Vec.*isZeroDir1Vec);
            allNIZero1Mat=eigv1Mat(:,isNotInfAndZeroVec);
            isNotInfAndNotZeroVec=logical((~isInf1DirVec).*(~isZeroDir1Vec));
            allNINZ1Mat=eigv1Mat(:,isNotInfAndNotZeroVec);
            %
            %Zero direction for second
            isZeroDir2Vec=abs(diag(diag1Mat))<CHECK_TOL;
            isNInfDir2Vec=~isInf2DirVec;
            isNotInfAndZeroVec=logical(isNInfDir2Vec.*isZeroDir2Vec);
            allNIZero2Mat=eigv2Mat(:,isNotInfAndZeroVec);
            %Non zero direction in Ell2 should be orthogonal to zero
            %directions in Ell1
            if (isempty(allNIZero1Mat)) && (~isempty(allNIZero2Mat))
                isBigger=false;
            else
                if ~isempty(allNIZero2Mat)
                    auxMat=allNINZ1Mat.'*allNIZero2Mat;
                    isOrth=all(all(abs(auxMat)<CHECK_TOL));
                else
                    isOrth=true;
                end
                if (~isOrth)
                    isBigger=false;
                else
                    %Project ell2 on non-zero directions of ell1
                    diag1Mat(isInf1DirVec,isInf1DirVec)=0;
                    curEllMat=eigv1Mat*diag1Mat*eigv1Mat.';
                    resProjQ1Mat=allNINZ1Mat.'*curEllMat*allNINZ1Mat;
                    %
                    diag2Mat(isInf2DirVec,isInf2DirVec)=0;
                    curEllMat=eigv2Mat*diag2Mat*eigv2Mat.';
                    resProjQ2Mat=allNINZ1Mat.'*curEllMat*allNINZ1Mat;
                    isBigger=contains(resProjQ1Mat,resProjQ2Mat);
                end
            end
        else
            isBigger=false;
        end
    end
end

function resQMat=findDiffIaND(ellQ1Mat, ellQ2Mat,curDirVec)
    %Find matrix of ellipsoids that is the result of
    %internal approximation of difference in direction curDirVec
    %Q1>0, Q2>=0
    %ellQ1Mat>0, ellQ2Mat>=0.
    % Solving det((1-x)Q1+(1-1/x)*Q2)=0 for x <=>
    % det(Q2Q1^{-1}-x)=0. 
    % We need maximal root.
    CHECK_TOL=1e-9;
    ellInvQ1Mat=ellQ1Mat\eye(size(ellQ1Mat));
    [~,diagMat]=eig(ellQ2Mat*ellInvQ1Mat);
    lamMax=max(diag(diagMat));
    %
    p1Par=sqrt(curDirVec.'*ellQ1Mat*curDirVec);
    p2Par=sqrt(curDirVec.'*ellQ2Mat*curDirVec);
    pPar=p2Par/p1Par;
    pPar=max(lamMax,pPar); %this only line is according to article
    if (pPar<CHECK_TOL)
        resQMat=ellQ1Mat;
    else
        resQMat=(1-pPar)*ellQ1Mat+(1-1/pPar)*ellQ2Mat;
        resQMat=0.5*(resQMat+resQMat.');
    end
end
function isContain=contains(ellQ1Mat,ellQ2Mat)
    CHECK_TOL=1e-9;
    ellQ1Mat=0.5*(ellQ1Mat+ellQ1Mat.');
    ellQ2Mat=0.5*(ellQ2Mat+ellQ2Mat.');
    tMat = ell_simdiag(ellQ1Mat, ellQ2Mat);
    if max(abs(diag(tMat*ellQ2Mat*tMat'))) < (1 + CHECK_TOL)
        isContain = 1;
    else
        isContain = 0;
    end
end
