function checkIfScalar(self,errMsg)
if nargin<2
    errMsg='input argument must be single ellipsoid.';
end
modgen.common.checkvar(self,'isscalar(x)',...
    'errorMessage',errMsg);
end