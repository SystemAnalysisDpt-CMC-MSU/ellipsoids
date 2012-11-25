function ellInvObj = inv( ellObj )
    import elltool.core.Ellipsoid;    
    import elltool.conf.Properties;
    modgen.common.type.simple.checkgenext(@(x)isa(x,'elltool.core.Ellipsoid'),...
          1,ellObj);
    modgen.common.type.simple.checkgenext('isscalar(x1)',1,ellObj);
    %
    absTol=Ellipsoid.CHECK_TOL;
    %
    diagVec=diag(ellObj.diagMat);
    isInfVec=diagVec==Inf;
    isZeroVec=abs(diagVec)<absTol;
    isFinNZVec=(~isInfVec) | (~isZeroVec);
    diagVec(isFinNZVec)=1./diagVec(isFinNZVec);
    diagVec(isInfVec)=0;
    diagVec(isZeroVec)=Inf;
    ellInvObj=Ellipsoid(ellObj.centerVec,diagVec,ellObj.eigvMat);
end

