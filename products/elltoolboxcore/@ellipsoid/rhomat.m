function [supArr, bpMat] = rhomat(ellShapeMat,ellCenterVec,absTol, dirsMat)
%
% RHOMAT - computes the values of the support function for given
% ellipsoid's shape matrix and center vector and given direction.
%
%
%	[supArr, bpMat] = RHO(ellShapeMat, ellCenterVec,absTol, dirstMat)
%       Computes the support function
%       of the ellipsoid in directions specified by the columns of
%       matrix dirsMat, and boundary points bpMat of this ellipsoid that
%       correspond to directions in dirsMat.
%
%	The support function is defined as
%   (1)  rho(l | E) = sup { <l, x> : x belongs to E }.
%	For ellipsoid E(q,Q), where q is its center and Q - shape matrix,
%   it is simplified to
%   (2)  rho(l | E) = <q, l> + sqrt(<l, Ql>)
%   Vector x, at which the maximum at (1) is achieved is defined by
%   (3)  q + Ql/sqrt(<l, Ql>)
%
% Input:
%   regular:
%       ellShapeMat: double[nDim,nDim] - shape matrix
%       ellCenterVec: double[nDim,1] - center matrix
%       absTol: double[1,1] - if ellipsoid is degenerate
%       dirsMat: double[nDim,nDirs] - matrix of directions.
%
% Output:
%	supArr: double [nDims1,nDims2,...,nDimsN] - support function
%       of the ellArr in directions specified by the columns of matrix
%       dirsMat.
%
%   bpMat: double [nDim,nDims1*nDims2*...*nDimsN] - matrix of
%       boundary points
%

% $Author: Lubich Ilya <lubi4ig@gmail.com> $   $Date: Feb-2013$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2013 $
%



tempMat  = max(sqrt(sum(dirsMat'*ellShapeMat.*dirsMat',2)), absTol);
supArr = ellCenterVec'*dirsMat + tempMat';
bpMat = ((ellShapeMat*dirsMat)./repmat(tempMat',size(ellShapeMat,1),1))...
    + repmat(ellCenterVec,1,size(dirsMat,2));

end
