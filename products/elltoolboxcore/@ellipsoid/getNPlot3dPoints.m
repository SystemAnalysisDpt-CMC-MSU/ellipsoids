function nPlot3dPointsArr = getNPlot3dPoints(ellArr)
% GETNPLOT3DPOINTS - gives value of nPlot3dPoints property
%   of ellipsoids in ellArr
%
% Input:
%   regular:
%       ellArr: ellipsoid[nDim1, nDim2,...] - mltidimensional array
%           of ellipsoids
%
% Output:
%       nPlot2dPointsArr: double[nDim1, nDim2,...] - multidimension array
%           of nPlot3dPoints property for ellipsoids in ellArr
%
% $Author: Zakharov Eugene  <justenterrr@gmail.com> $
%   $Date: 17-november-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Arrhematics and Computer Science,
%            System Analysis Department 2012 $
%
nPlot3dPointsArr = getProperty(ellArr,'nPlot3dPoints');
