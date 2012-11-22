function ellInvObj = inv( ellObj )
    import elltool.core.Ellipsoid;    
    import elltool.conf.Properties;    
    ABS_TOL = Properties.getAbsTol();
    diagVec=diag(ellObj.diagMat);
    isInfVec=diagVec==Inf;
    isZeroVec=abs(diagVec)<ABS_TOL;
    isFinNZVec=logical((~isInfVec).*(~isZeroVec));
    diagVec(isFinNZVec)=1./diagVec(isFinNZVec);
    diagVec(isInfVec)=0;
    diagVec(isZeroVec)=Inf;
    ellInvObj=Ellipsoid(ellObj.centerVec,diagVec,ellObj.eigvMat);

end

