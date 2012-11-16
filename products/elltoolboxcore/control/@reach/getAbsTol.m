function absTol = getAbsTol(RS)
%GETABSTOL gives value of absTol property of reach set RS
%
%Input:
%   regular:
%       RS:reach[1,1] - reach set
%
%Output:
%   absTol:double[1, 1]- value of absTol property of reach set RS
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
absTol = RS.absTol;