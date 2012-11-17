function absTolMat = getAbsTol(linsysMat)
%GETABSTOL gives value of absTol property of linsys linear system lin
%
% Input:
%   regular:
%       lin:linsys[1,1] - linear system
%
% Output:
%   absTol:double[1, 1]- value of absTol property of linear system lin
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
[nRows, nCols] = size(linsysMat);
absTolMat = zeros(nRows,nCols);
for iRows = 1:nRows
    for jCols = 1:nCols
        absTolMat(iRows,jCols) = linsysMat(iRows,jCols).absTol;
    end
end