function nPlot3dPointsMat = getNPlot3dPoints(ellMat)
%GETNPLOT3DPOINTS gives value of nPlot3dPoints property of ellipsoid E
%
% Input:
%   regular:
%       E:ellipsoid[1,1] - ellipsoid
%
% Output:
%   nPlot3dPoints:double[1, 1]- value of nPlot3dPoints property of ellipsoid E
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
nPlot3dPointsMat = getProperty(ellMat,'nPlot3dPoints');