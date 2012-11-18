function relTolArr = getRelTol(ellArr)
% GETRELTOL gives array the same size as ellArr with values of relTol properties
% for each ellipsoid in ellArr
% 
% Input:
%   regular:
%       ellArr:ellipsoid[nRows, nCols] - multidimension array of ellipsoids
% 
% Output:
%   relTolArr:double[nRows, nCols]- multidimension array of relTol properties for
%                                   ellipsoids in ellArr
% 
% $Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Arrhematics and Computer Science,
%            System Analysis Department 2012 $
% 
relTolArr = getProperty(ellArr,'relTol');