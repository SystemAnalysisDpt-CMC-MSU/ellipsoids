function nPlot2dPointsMat = getNPlot2dPoints(rsMat)
%GETNPLOT2DPOINTS gives matrix  the same size as rsMat of value of 
%nPlot2dPoints property for each element in rsMat - matrix of reach sets
%
% Input:
%   regular:
%       rsMat:reach[nRows,nCols] - reach set matrix
%
% Output:
%   nPlot2dPointsMat:double[nRows, nCols]- matrix of values of nTimeGridPoints 
%                                         property for each reach set in
%                                         rsMat
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
nPlot2dPointsMat = getProperty(rsMat,'nPlot2dPoints');