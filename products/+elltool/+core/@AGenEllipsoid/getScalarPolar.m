function polarObj = getScalarPolar(self, isRobustMethod)
% GETSCALARPOLAR - calculating polar of a single ellipsoid, method of 
% AGenEllipsoid class.
%
%   Given ellipsoid E(q, Q) where q is its center, and Q - its shape matrix,
%   the polar set to E(q, Q) is defined as follows:
%   P = { l in R^n  | <l, q> + sqrt(<l, Q l>) <= 1 }
%   If the origin is an interior point of ellipsoid E(q, Q),
%   then its polar set P is an ellipsoid.
%
% Input:
%	regular:
%       self: ellipsoid[1,1] - the object of class
%       isRobustMethod: logical[1,1] - if true, then
%           robust method uses, else non-robust. Default value is true.
%
%
% Output:
%   polar: ellipsoid[1,1] - polar ellipsoid
%
% Example:
%   ellObj = ellipsoid([4 -1; -1 1]);
%   getScalarPolar(ellObj, true) == ellObj.inv()
%
%   ans =
% 
%       1
%
% $Author: Alexandr Timchenko  <timchenko.alexandr@gmail.com> $    
% $Date: Oct-2015$
% $Copyright: Moscow State University,
%           Faculty of Computational Mathematics and Computer Science,
%           System Analysis Department 2015 $
%
modgen.common.checkmultvar('isscalar(x1)&&islogical(x2)&&isscalar(x2)',...
    2, self, isRobustMethod, 'errorTag', 'wrongInput');
%
if nargin<2 
    isRobustMethod = true;
end

if isRobustMethod
    [cVec,shMat] = double(self);
    invShMat = inv(shMat);
    normConst = cVec'*(shMat\cVec);
    polarCVec = -(shMat\cVec)/(1-normConst);
    polarShMat = invShMat/(1-normConst) + polarCVec*polarCVec';
    polarObj = ellipsoid(polarCVec,polarShMat);
else
    [cVec,shMat] = double(self);
    isZeroInEll = cVec' * ell_inv(shMat) * cVec;
    if isZeroInEll < 1
        auxMat = ell_inv(shMat - cVec*cVec');
        auxMat = 0.5*(auxMat + auxMat');
        polarCVec = -auxMat * cVec;
        polarShMat = (1 + cVec'*auxMat*cVec)*auxMat;
        polarObj = ellipsoid(polarCVec,polarShMat);
    else
        modgen.common.throwerror('degenerateEllipsoid',...
            'The resulting ellipsoid is not bounded');
    end
end
end