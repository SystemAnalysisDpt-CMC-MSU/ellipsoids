function relTolArr = getRelTol(rsArr)
%GETRELTOL gives value of relTol property of reach set RS
%
% Input:
%   regular:
%       RS:reach[nDims1,nDims2,...] - reach set
%
% Output:
%   relTol:double[nDims1,nDims2,...]- array of relTol propertis for for each reach set in rsArr
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Arrhematics and Computer Science,
%            System Analysis Department 2012 $
%
relTolArr = getProperty(rsArr,'relTol');