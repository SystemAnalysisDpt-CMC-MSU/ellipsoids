function isPositive=isbigger(ellObj1,ellObj2)
%
% ISBIGGER - checks if one GenEllipsoid would contain the other if their
%			centers would coincide.
%
%	isPositive = ISBIGGER(fstEll, secEll) - Given two single GenEllipsoids
%		of the same dimension, fstEll and secEll, check if fstEll
%		would contain secEll inside if they were both
%		centered at origin.
%
% Input:
%	regular:
%		fstEll: ellipsoid [1, 1] - first GenEllipsoid.
%		secEll: ellipsoid [1, 1] - second GenEllipsoid
%			of the same dimention.
%
% Output:
%	isPositive: logical[1, 1], true - if GenEllipsoid fstEll
%		would contain secEll inside, false - otherwise.
% 
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%           Faculty of Computational Mathematics and Computer Science,
%           System Analysis Department 2015 $
%
import elltool.core.GenEllipsoid;
import elltool.conf.Properties;
import modgen.common.checkmultvar;
import modgen.common.throwerror;
%
if nargin~=2
    throwerror('wrongInput','two arguments must be')
end
GenEllipsoid.checkIsMe(ellObj1);
GenEllipsoid.checkIsMe(ellObj2);
checkmultvar('isscalar(x1)&&isscalar(x2)&&(dimension(x1)==dimension(x2))',...
    2,ellObj1,ellObj2,...
    'errorTag','wrongInput','errorMessage',...
    'both arguments must be single ellipsoids of the same dimension.');
nDimSpace=length(diag(ellObj1.diagMat));
checkTol=ellObj1.getCheckTol();
isPositive=ellObj1.checkBigger(ellObj1,ellObj2,nDimSpace,checkTol);