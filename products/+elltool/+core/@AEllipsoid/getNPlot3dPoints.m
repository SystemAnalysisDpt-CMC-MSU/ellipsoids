function nPlot3dPointsArr = getNPlot3dPoints(ellArr)
% GETNPLOT3DPOINTS - gives value of nPlot3dPoints property of ellipsoids 
%                    in ellArr
%
% Input:
%   regular:
%       ellArr: ellipsoid[nDim1, nDim2,...] - mltidimensional array  of 
%          ellipsoids
%
% Output:
%       nPlot2dPointsArr: double[nDim1, nDim2,...] - multidimension array
%           of nPlot3dPoints property for ellipsoids in ellArr
% 
% Example:
%   firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
%   secEllObj = ellipsoid([1 ;2], eye(2));
%   ellVec = [firstEllObj secEllObj];
%   ellVec.getNPlot3dPoints()
% 
%   ans =
% 
%      200   200
%
% $Author: Zakharov Eugene  <justenterrr@gmail.com> $
% $Date: 2012-11-17$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
nPlot3dPointsArr = getProperty(ellArr,'nPlot3dPoints');
