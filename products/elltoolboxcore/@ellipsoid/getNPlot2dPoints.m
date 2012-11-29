function nPlot2dPointsArr = getNPlot2dPoints(ellArr)
% GETNPLOT2DPOINTS - gives value of nPlot2dPoints property
%   of ellipsoids in ellArr
%
% Input:
%   regular:
%       ellArr: ellipsoid[nDim1, nDim2,...] - mltidimensional array
%           of ellipsoids
%
% Output:
%       nPlot2dPointsArr: double[nDim1, nDim2,...] - multidimension array
%           of nPlot2dPoints property for ellipsoids in ellArr
%
% $Author: Zakharov Eugene  <justenterrr@gmail.com> $ 
%   $Date: 17-november-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Arrhematics and Computer Science,
%            System Analysis Department 2012 $
%
nPlot2dPointsArr = getProperty(ellArr,'nPlot2dPoints');
