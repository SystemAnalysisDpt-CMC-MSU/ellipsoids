function polarObj = getScalarPolar(self, isRobustMethod)
% GETSCALARPOLAR - calculating polar of a single ellipsoid,
%                       method of AGenEllipsod class
% Input:
%   regular:
%       self: ellipsoid: the object of class
%       isRobustMethod: logical: = true for default, 
%                                  determine method to use                  
% Output:
%   polar: ellipsoid
%
% $Author: Alexandr Timchenko  <timchenko.alexandr@gmail.com> $    
% $Date: Oct-2015$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
modgen.common.checkmultvar('isscalar(x1)&&islogical(x2)&&isscalar(x2)',...
    2, self, isRobustMethod, 'errorTag', 'wrongInput');
%
if nargin<2 
    isRobustMethod = true;
end
    dbstack
if isRobustMethod
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
else
    [cVec,shMat] = double(self);
    invShMat = inv(shMat);
    normConst = cVec'*(shMat\cVec);
    polarCVec = -(shMat\cVec)/(1-normConst);
    polarShMat = invShMat/(1-normConst) + polarCVec*polarCVec';
    polarObj = ellipsoid(polarCVec,polarShMat);
end
end