function sqMat=findSqrtOfMatrix(qMat,absTol)
% FINDSQRTOFMATRIX - find square root of matrix using its eigenvalue
%                    decomposition
%
% Input:
%   regular:
%       qMat: double: [kSize,kSize] - square non-negative matrix
%       absTol: double: [1,1] - absolute tolerance
% Output:
%   sqMat: double: [kSize,kSize] - square root of input matrix
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
[eigvMat diagMat]=eig(qMat);
isZeroVec=diag(abs(diagMat)<absTol);
diagMat(isZeroVec,isZeroVec)=0;
sqMat=eigvMat*realsqrt(diagMat)*eigvMat.';