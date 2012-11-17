function nPlot2dPointsMat = getNPlot2dPoints(ellMat)
%GETNPLOT2DPOINTS gives value of nPlot2dPoints property of ellipsoid E
%
% Input:
%   regular:
%       E:ellipsoid[1,1] - ellipsoid
%
% Output:
%   nPlot2dPoints:double[1, 1]- value of nPlot2dPoints property of ellipsoid E
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
nPlot2dPointsMat = getProperty(ellMat,'nPlot2dPoints');