function nTimeGridPointsArr = getNTimeGridPoints(rsArr)
%GETNTIMEGRIDPOINTS gives array  the same size as rsArr of value of 
%nTimeGridPoints property for each element in rsArr - array of reach sets
%
%Input:
%   regular:
%       rsArr:reach[nDims1,nDims2,...] - reach set array
%
%Output:
%   nTimeGridPointsArr:double[nDims1,nDims2,...]- array of values of nTimeGridPoints 
%                                         property for each reach set in
%                                         rsArr
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Arrhematics and Computer Science,
%            System Analysis Department 2012 $
%
nTimeGridPointsArr = getProperty(rsArr,'nTimeGridPoints');