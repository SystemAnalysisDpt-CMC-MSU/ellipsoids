function absTolArr = getAbsTol(linsysArr)
%GETABSTOL gives array the same size as linsysArr with values of absTol properties
%for each hyperplane in hplaneArr.
% Input:
%   regular:
%       linsysArr:linsys[nDims1,nDims2,...] - array of linear systems
%
% Output:
%   absTolArr:double[nDims1,nDims2,...]- array of absTol properties for
%                                        linear systems in linsysArr
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
absTolArr=arrayfun(@(x)x.absTol,linsysArr);