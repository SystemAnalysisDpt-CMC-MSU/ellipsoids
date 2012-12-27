function checkIsMe(ellArr,varargin)

nArgIn = nargin;
if nArgIn == 1
    modgen.common.checkvar(ellArr,@(x) isa(x,'ellipsoid'),...
        'errorTag','wrongInput',...
        'errorMessage','input argument must be ellipsoid.');
elseif nArgIn==2
    modgen.common.checkvar(ellArr,@(x) isa(x,'ellipsoid'),...
        'errorTag','wrongInput','errorMessage',...
        [varargin{1}, ' input argument must be ellipsoid.']);
else
    modgen.common.checkvar(ellArr,@(x) isa(x,'ellipsoid'),varargin{:});
end