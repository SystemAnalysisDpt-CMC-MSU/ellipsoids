function checkIsMe(ellArr,varargin)
% Example:
% ellObj = ellipsoid([1; 2], eye(2));
% ellipsoid.checkIsMe(ellObj)
% 
% 
% % $Author: Rustam Galiev <glvrst@gmail.com> $	$Date: 2012-12-27 $ 
% $Copyright: Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department 2012 $
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