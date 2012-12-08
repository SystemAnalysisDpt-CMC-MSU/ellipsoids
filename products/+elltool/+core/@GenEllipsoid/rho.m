function [resRho, bndPVec] = rho(ellObj,dirVec)
import elltool.core.GenEllipsoid;
absTol=GenEllipsoid.getCheckTol();
eigvMat=ellObj.getEigvMat();
diagMat=ellObj.getDiagMat();
diagVec=diag(diagMat);
cenVec=ellObj.getCenter();
isInfVec=diagVec==Inf;
dirInfProjVec=0;
if ~all(~isInfVec)
    nDimSpace=length(diagVec);
    allInfDirMat=eigvMat(:,isInfVec);
    [orthBasMat rankInf]=ellObj.findBasRank(allInfDirMat,absTol);
    infIndVec=1:rankInf;
    finIndVec=(rankInf+1):nDimSpace;
    infBasMat = orthBasMat(:,infIndVec);
    finBasMat = orthBasMat(:,finIndVec);
    diagVec(isInfVec)=0;
    curEllMat=eigvMat*diag(diagVec)*eigvMat.';
    resProjQMat=finBasMat.'*curEllMat*finBasMat;
    ellQMat=0.5*(resProjQMat+resProjQMat.');
    dirInfProjVec=infBasMat.'*dirVec;
    dirVec=finBasMat.'*dirVec;
    cenVec=finBasMat.'*cenVec;
else
    ellQMat=eigvMat*diag(diagVec)*eigvMat.';
    ellQMat=0.5*(ellQMat+ellQMat);
end
if ~all(abs(dirInfProjVec)<absTol)
    resRho=Inf;
    scMul = sqrt(dirVec'*ellQMat*dirVec);
    if scMul > 0
        bndPFinVec = cenVec + (ellQMat*dirVec)/scMul;
    else
        bndPFinVec = cenVec;
    end
    bndPVec = finBasMat*bndPFinVec;
 
    IndProjInfVec = find(infBasMat*dirInfProjVec > 0);
    if numel(IndProjInfVec) > 0
        bndPVec(IndProjInfVec) = Inf;
    end
else
    dirVec=dirVec/norm(dirVec);
    scMul = sqrt(dirVec'*ellQMat*dirVec);
    resRho=cenVec.'*dirVec+scMul;
    if scMul > 0
        bndPVec = cenVec + (ellQMat*dirVec)/scMul;
    else
        bndPVec = cenVec;
    end
end
end