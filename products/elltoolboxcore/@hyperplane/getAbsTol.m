function absTol = getAbsTol(H)
%GETABSTOL gives value of absTol property of hyperplane H
%
%Input:
%   regular:
%       H:hyperplane[1,1] - hyperplane
%
%Output:
%   absTol:double[1, 1]- value of absTol property of hyperplane H
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
absTol = H.absTol;