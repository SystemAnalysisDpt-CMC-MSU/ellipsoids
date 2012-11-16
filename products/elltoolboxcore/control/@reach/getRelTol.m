function relTol = getRelTol(RS)
%GETRELTOL gives value of relTol property of reach set RS
%
%Input:
%   regular:
%       RS:reach[1,1] - reach set
%
%Output:
%   relTol:double[1, 1]- value of relTol property of reach set RS
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
relTol = RS.relTol;