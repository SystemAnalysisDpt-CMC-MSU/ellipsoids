function nPlot2dPointsArr=getNPlot2dPoints(ellArr)
% GETNPLOT2DPOINTS - gives value of nPlot2dPoints property of AEllipsoids 
%					in ellArr
%
% Input:
%	regular:
%		ellArr: AEllipsoid[nDim1, nDim2,...] - multidimensional array of 
%			AEllipsoids
%
% Output:
%		nPlot2dPointsArr: double[nDim1, nDim2,...] - multidimensional array
%			of nPlot2dPoints property for AEllipsoids in ellArr
% Example:
%	firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
%	secEllObj = ellipsoid([1 ;2], eye(2));
%	ellVec = [firstEllObj secEllObj];
%	ellVec.getNPlot2dPoints()
% 
%	ans =
% 
%		200   200
%
% $Author: Zakharov Eugene  <justenterrr@gmail.com> $ 
% $Date: 2012-11-17$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2012 $
%
nPlot2dPointsArr=getProperty(ellArr,'nPlot2dPoints');
