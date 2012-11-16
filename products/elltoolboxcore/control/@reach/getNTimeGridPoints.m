function nTimeGridPoints = getNTimeGridPoints(RS)
%GETNTIMEGRIDPOINTS gives value of nTimeGridPoints property of reach set RS
%
%Input:
%   regular:
%       RS:reach[1,1] - reach set
%
%Output:
%   nTimeGridPoints:double[1, 1]- value of nTimeGridPoints property of reach set RS
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
nTimeGridPoints = RS.nTimeGridPoints;