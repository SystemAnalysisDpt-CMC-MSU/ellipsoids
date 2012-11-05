function ellInvObj = inv( ellObj )
    
    global ellOptions    
    import elltool.core.Ellipsoid;
    diagVec=diag(ellObj.diagMat);
    isInfVec=diagVec==Inf;
    isZeroVec=abs(diagVec)<ellOptions.abs_tol;
    isFinNZVec=logical((~isInfVec).*(~isZeroVec));
    diagVec(isFinNZVec)=1./diagVec(isFinNZVec);
    diagVec(isInfVec)=0;
    diagVec(isZeroVec)=Inf;
    ellInvObj=Ellipsoid(ellObj.centerVec,diagVec,ellObj.eigvMat);

end

