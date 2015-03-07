function nPlot2dPointsArr = getNPlot2dPoints(ellArr)
% GETNPLOT2DPOINTS - gives value of nPlot2dPoints property of ellipsoids 
%                    in ellArr
%
% Input:
%   regular:
%       ellArr: ellipsoid[nDim1, nDim2,...] - mltidimensional array of 
%           ellipsoids
%
% Output:
%       nPlot2dPointsArr: double[nDim1, nDim2,...] - multidimension array
%           of nPlot2dPoints property for ellipsoids in ellArr
% Example:
%   firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
%   secEllObj = ellipsoid([1 ;2], eye(2));
%   ellVec = [firstEllObj secEllObj];
%   ellVec.getNPlot2dPoints()
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
nPlot2dPointsArr = getProperty(ellArr,'nPlot2dPoints');
