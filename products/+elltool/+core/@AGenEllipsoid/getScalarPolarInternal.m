function polarObj = getScalarPolarInternal(self, isRobustMethod)
% GETSCALARPOLARINTERNAL - calculates a polar set for a single ellipsoid
%
% Given ellipsoid E(q, Q) with center q and shape matrix Q
% the polar set for E(q, Q) is defined as follows:
% P = { l in R^n  | <l, q> + sqrt(<l, Q l>) <= 1 }
% If the origin is an internal point of ellipsoid E(q, Q)
% then its polar set P is an ellipsoid.
%
% Input:
%   regular:
% 		self: ellipsoid[1,1] - the object of class
% 		isRobustMethod: logical[1,1] - if true, then
% 			robust method is used (based on built-in "inv" function), 
%           otherwise - a more complex alternative algorithm.
%           Default value is true. 
%
%     Note: the alternative algorithm was originally used in 
%           Ellipsoidal Toolbox as more robust than the one based on "inv".
%           However multiple tests on Hilber matrix showed that the more
%           simple algorithm based on the built-in "inv" function performs
%           better (see tests in elltool.core.test.mlunit.PolarIllCondTC 
%           test case)
% 
% Output:
% 	polar: ellipsoid[1,1] - polar ellipsoid
%
% 
% $Author: Alexandr Timchenko  <timchenko.alexandr@gmail.com> $    
% $Date: 12-Oct-2015$
% $Copyright: Moscow State University,
% 			Faculty of Computational Mathematics and Computer Science,
% 			System Analysis Department 2015 $
% 
modgen.common.checkmultvar('isscalar(x1)&&islogical(x2)&&isscalar(x2)',...
    2, self, isRobustMethod, 'errorTag', 'wrongInput');
%
if nargin<2 
    isRobustMethod = true;
end
%
if isRobustMethod
    [cVec,shMat] = double(self);
    invShMat = inv(shMat);
    normConst = cVec.'*(shMat\cVec);
    polarCVec = -(shMat\cVec)/(1-normConst);
    polarShMat = invShMat/(1-normConst) + polarCVec*polarCVec.';
    polarObj = ellipsoid(polarCVec,polarShMat);
else
    [cVec,shMat] = double(self);
    isZeroInEll = cVec.'*ell_inv(shMat)*cVec<1;
    if isZeroInEll
        auxMat = ell_inv(shMat - cVec*cVec.');
        auxMat = 0.5*(auxMat + auxMat.');
        polarCVec = -auxMat * cVec;
        polarShMat = (1 + cVec.'*auxMat*cVec)*auxMat;
        polarObj = ellipsoid(polarCVec,polarShMat);
    else
        modgen.common.throwerror('degenerateEllipsoid',...
            'The resulting ellipsoid is not bounded');
    end
end