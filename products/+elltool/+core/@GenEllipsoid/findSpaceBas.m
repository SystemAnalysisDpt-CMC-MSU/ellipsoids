function [ spaceBasMat,  oSpaceBasMat, spaceIndVec, oSpaceIndVec] = ...
    findSpaceBas( dirMat,absTol )
% FINDSPACEBAS - find basis of linear hull of  specified vectors and
%                basis of orthogonal subspace to the hull
%
% Input:
%   regular:
%       dirMat: double: [nDim,nCol] - matric whose columns form a subspace
%       absTol: double: [1,1] - absolute tolerance
% Output:
%   spaceBasMat: double: [nDim,r1Dim] - basis of subspace of input vector
%   oSpaceBasMat: double: [nDim,r2Dim] - basis of orthogonal subspace
%   spaceIndVec: double: [1,r1Dim] - indices of subspace basis vectors
%   oSpaceIndVec: double: [1,r2Dim] - indices of orthogonal subspace basis
%       vectors
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
import elltool.core.GenEllipsoid;
nDimSpace=size(dirMat,1);
[orthBasMat rankL]=GenEllipsoid.findBasRank(dirMat,absTol);
spaceIndVec=1:rankL;
oSpaceIndVec=(rankL+1):nDimSpace;
spaceBasMat=orthBasMat(:,spaceIndVec);
oSpaceBasMat = orthBasMat(:,oSpaceIndVec);

