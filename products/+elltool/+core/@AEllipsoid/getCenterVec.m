function centerVec=getCenterVec(ellObj)
% GETCENTERVEC - returns centerVec vector of given AEllipsoid
%
% Input:
%   regular:
%      self: AEllipsoid[1,1]
%
% Output:
%   centerVecVec: double[nDims,1] - centerVec of AEllipsoid
%
% Example:
%   ellObj = ellipsoid([1; 2], eye(2));
%   getCenterVec(ellObj)
%
%   ans =
%
%        1
%        2
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $
% $Date: 24-04-2013$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012-2013 $
centerVec=ellObj.centerVec;
end