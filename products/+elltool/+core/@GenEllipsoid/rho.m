function resRho=rho(ellObj,dirVec)
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
else
    dirVec=dirVec/norm(dirVec);
    resRho=cenVec.'*dirVec+sqrt(dirVec.'*ellQMat*dirVec);
end
end