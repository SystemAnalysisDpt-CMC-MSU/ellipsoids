function [ resEllVec ] = minkdiffNew_ea( ellObj1, ellObj2, dirMat)
    import elltool.core.Ellipsoid;
    import modgen.common.throwerror
    %
    if (~isa(ellObj1,'Ellipsoid')) || (~isa(ellObj2,'Ellipsoid'))
        throwerror('wrongArgs','MINKDIFF_EA: first two arguments must be single ellipsoids');
    end
    [k1Size k2Size]=size(ellObj1);
    [m1Size m2Size]=size(ellObj2);
    if (k1Size~=1) || (k2Size~=1) || (m1Size~=1) || (m2Size~=1)
        throwerror('wrongElls','MINKDIFF_EA: first two arguments must be single ellipsoids');
    end
    %
    %Check whether one ellipsoid is bigger then the other
    ell1DiagVec=diag(ellObj1.diagMat);
    ell2DiagVec=diag(ellObj2.diagMat);
    isFirstBigger=all(ell1DiagVec>=ell2DiagVec);
    if ~isFirstBigger
        throwerror('wrongElls','MINKDIFF_EA: geometric difference of these two ellipsoids is an empty set');
    end
    %
    [mSize nDirs]=size(dirMat);
    nDimSpace=length(ell1DiagVec);
    if mSize~=nDimSpace
        throwerror('wrongDir','MINKDIFF_EA: dimension of the direction vectors must be the same as dimension of ellipsoids');
    end
    %
    resCenterVec=ellObj1.centerVec-ellObj2.centerVec;
    resEllVec(nDirs)=Ellipsoid();
    isAnyComputed=false;
    ellQ1Mat=ellObj1.eigvMat*ellObj1.diagMat*ellObj1.eigvMat.';
    ellQ2Mat=ellObj2.eigvMat*ellObj2.diagMat*ellObj2.eigvMat.';
    ellSQR1Mat=ellObj1.eigvMat*(ellObj1.diagMat.^(1/2))*ellObj1.eigvMat.';
    ellSQR2Mat=ellObj2.eigvMat*(ellObj2.diagMat.^(1/2))*ellObj2.eigvMat.';
    for iDir=1:nDirs
        curDir=dirMat(:,iDir);
        minRoot=min(diag(ellObj1.diagMat));
        pPar=sqrt(curDir.'*ellQ1Mat*curDir)/sqrt(curDir.'*ellQ2Mat*curDir);
        if (pPar<minRoot)
            sOrthMat=ell_valign(ellSQR1Mat*curDir,ellSQR2Mat*curDir);
            auxMat=ellSQR1Mat-sOrthMat*ellSQR2Mat;
            resMat=auxMat.'*auxMat;
            resEllVec(iDir)=Ellipsoid(resCenterVec,resMat);
            isAnyComputed=true;
        end
    end
    if ~isAnyComputed
        throwerror('wrongDir','MINKDIF_EA: yet cannot compute in specified directions');
    end
end

