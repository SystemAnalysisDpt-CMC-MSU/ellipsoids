function relTolMat = getRelTol(ellMat)
%GETRELTOL gives matrix the same size as ellMat with values of relTol properties
%for each ellipsoid in ellMat
%
%Input:
%   regular:
%       ellMat:ellipsoid[nRows, nCols] - matrix of ellipsoids
%
%Output:
%   relTolMat:double[nRows, nCols]- matrix of relTol properties for
%                                   ellipsoids in ellMat
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
[nRows, nCols] = size(ellMat);
relTolMat = zeros(nRows,nCols);
for iRows = 1:nRows
    for jCols = 1:nCols
        relTolMat(iRows,jCols) = ellMat(iRows,jCols).relTol;
    end
end