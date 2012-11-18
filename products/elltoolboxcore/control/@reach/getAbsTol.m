function absTolArr = getAbsTol(rsArr)
% GETABSTOL gives array the same size as rsArray with values of absTol properties
% for each reach set in rsArr.
% Input:
%   regular:
%       RS:reach[nDims1, nDims2,...] - reach set array
% 
% Output:
%   absTol:double[nDims1, nDims2,...]- array of absTol propertis for for each reach set in rsArr
% 
% $Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Arrhematics and Computer Science,
%            System Analysis Department 2012 $
% 
absTolArr = getProperty(rsArr,'absTol');