function absTolMat = getAbsTol(ellMat)
%GETABSTOL gives matrix the same size as ellMat with values of absTol properties
%for each ellipsoid in ellMat
%
% Input:
%   regular:
%       ellMat:ellipsoid[nRows, nCols] - matrix of ellipsoids
%
% Output:
%   absTolMat:double[nRows, nCols]- matrix of absTol properties for
%                                   ellipsoids in ellMat
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
absTolMat = getProperty(ellMat,'absTol');