function absTolArr = getAbsTol(hplaneArr)
%GETABSTOL gives array the same size as hplaneArr with values of absTol properties
%for each hyperplane in hplaneArr.
%
% Input:
%   regular:
%       H:hyperplane[nDims1,nDims2,...] - hyperplane array
%
% Output:
%   absTol:double[nDims1,nDims2,...]- array of absTol properties for
%                                   hyperplanes in hplaneArr
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
 absTolArr=arrayfun(@(x)x.absTol,hplaneArr);