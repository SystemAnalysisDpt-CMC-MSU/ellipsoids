function [ projQMat ] = findMatProj( eigvMat,diagMat,basMat )
% FINDMATPROJ - find projection of matrix given in eigenvalue decomposition
%
% Input:
%   regular:
%       eigvMat: double: [nDim,nDim] - matrix of eigenvectors
%       diagMat: double: [nDim,nDim] - matrix of eigenvalues
%       basMat: double: [nDim,nDim] - matrix of projection
%
% Output:
%   orthBasMat: double: [nDim,nDim] - orthogonal matrix whose
%       columns form a basis in R^nDim
%   rang: double: [1,1] - rang of the convex hull of input vectors
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
%
curEllMat=eigvMat*diagMat*eigvMat.';
projQMat=basMat.'*curEllMat*basMat;
projQMat=0.5*(projQMat+projQMat.');
end

