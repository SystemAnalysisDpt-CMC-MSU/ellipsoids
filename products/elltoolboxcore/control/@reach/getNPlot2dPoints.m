function nPlot2dPointsArr = getNPlot2dPoints(rsArr)
% GETNPLOT2DPOINTS gives array  the same size as rsArr of value of 
% nPlot2dPoints property for each element in rsArr - array of reach sets
% 
% Input:
%   regular:
%       rsArr:reach[nDims1,nDims2,...] - reach set array
% 
% Output:
%   nPlot2dPointsArr:double[nDims1,nDims2,...]- array of values of nTimeGridPoints 
%                                         property for each reach set in
%                                         rsArr
% 
% $Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Arrhematics and Computer Science,
%            System Analysis Department 2012 $
% 
nPlot2dPointsArr = getProperty(rsArr,'nPlot2dPoints');