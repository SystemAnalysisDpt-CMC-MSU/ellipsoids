function [ resEllVec ] = minkdiffNew_ia( ellObj1, ellObj2, dirMat)
    global ellOptions    
    import elltool.core.Ellipsoid;
    import modgen.common.throwerror
    %
    if (~isa(ellObj1,'Ellipsoid')) || (~isa(ellObj2,'Ellipsoid'))
        throwerror('wrongArgs','MINKDIFF_IA: first two arguments must be single ellipsoids');
    end
    [k1Size k2Size]=size(ellObj1);
    [m1Size m2Size]=size(ellObj2);
    if (k1Size~=1) || (k2Size~=1) || (m1Size~=1) || (m2Size~=1)
        throwerror('wrongElls','MINKDIFF_IA: first two arguments must be single ellipsoids');
    end
    %
    %Check whether one ellipsoid is bigger then the other
    ell1DiagVec=diag(ellObj1.diagMat);
    ell2DiagVec=diag(ellObj2.diagMat);
    isFirstBigger=all(ell1DiagVec>=ell2DiagVec);
    if ~isFirstBigger
        throwerror('wrongElls','MINKDIFF_IA: geometric difference of these two ellipsoids is an empty set');
    end
    %
    [mSize nDirs]=size(dirMat);
    nDimSpace=length(ell1DiagVec);
    if mSize~=nDimSpace
        throwerror('wrongDir','MINKDIFF_IA: dimension of the direction vectors must be the same as dimension of ellipsoids');
    end
    %
    resCenterVec=ellObj1.centerVec-ellObj2.centerVec;
    resEllVec(nDirs)=Ellipsoid();
    for iDir=1:nDirs
        curDir=dirMat(:,iDir);
        % Solving det(Q(p))=0
        lamMax=min(1./ell1DiagVec);
        %
        ellQ1Mat=ellObj1.eigvMat*ellObj1.diagMat*ellObj1.eigvMat.';
        ellQ2Mat=ellObj2.eigvMat*ellObj2.diagMat*ellObj2.eigvMat.';
        p1Par=sqrt(curDir.'*ellQ1Mat*curDir);
        p2Par=sqrt(curDir.'*ellQ2Mat*curDir);
        pPar=p2Par/p1Par;
        pPar=max(lamMax,pPar); %according to article
        resQMat=(1-pPar)*ellQ1Mat+(1-1/pPar)*ellQ2Mat;
        resQMat=0.5*(resQMat+resQMat.');
        resEllVec(iDir)=Ellipsoid(resCenterVec,resQMat);
    end
end

