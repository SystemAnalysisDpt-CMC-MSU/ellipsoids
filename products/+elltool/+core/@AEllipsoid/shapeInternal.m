function isModScal=shapeInternal(ellArr, modMat)
checkIsMeVirtual(ellArr);
modgen.common.checkvar(modMat, @(x)isa(x,'double'),...
    'errorMessage','second input argument must be double');
isModScal=isscalar(modMat);
[nRows,nDim]=size(modMat);
dimArr=dimension(ellArr);
modgen.common.checkmultvar('(x1==x2)&&all(x3(:)==x2)',...
    3,nRows,nDim,dimArr,'errorMessage',...
    'input matrix not square or dimensions do not match');
end