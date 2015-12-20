function centerVec=getCenterVec(self)
% GETCENTERVEC - returns centerVec vector of given ellipsoid
%
% Input:
%   regular:
%      self: ellipsoid[1,1]
%
% Output:
%   centerVecVec: double[nDims,1] - centerVec of ellipsoid
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
centerVec=self.centerVec;
end