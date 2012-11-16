function absTol = getAbsTol(lin)
%GETABSTOL gives value of absTol property of linsys linear system lin
%
%Input:
%   regular:
%       lin:linsys[1,1] - linear system
%
%Output:
%   absTol:double[1, 1]- value of absTol property of linear system lin
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
absTol = lin.absTol;