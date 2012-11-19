function nPlot3dPointsArr = getNPlot3dPoints(rsArr)
% GETNPLOT3DPOINTS gives array  the same size as rsArr of value of 
% nPlot3dPoints property for each element in rsArr - array of reach sets
% 
% Input:
%   regular:
%       rsArr:reach[nDims1,nDims2,...] - reach set array
% 
% Output:
%   nPlot3dPointsArr:double[nDims1,nDims2,...]- array of values of nPlot3dPoints 
%                                         property for each reach set in
%                                         rsArr
% 
% $Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Arrhematics and Computer Science,
%            System Analysis Department 2012 $
% 
nPlot3dPointsArr = getProperty(rsArr,'nPlot3dPoints');