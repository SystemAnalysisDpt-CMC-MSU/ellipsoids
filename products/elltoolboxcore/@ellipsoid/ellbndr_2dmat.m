function [ bpMat, fVec] = ellbndr_2dmat(nPoints, cenVec, qMat,absTol)
%
% ELLBNDR_2DMAT - computes the boudary of 2D ellipsoid given its center
%                 and shape matrix
% Input:
%   regular:
%       nPoints: double[1,1] - number of resulting points of ellipsoid boudary
%   optional:
%       cenVec: double[nDim,1] - center of ellipsoid, by default equals zero
%               vector
%       qMat: double[nDim,nDim] - shape matrix of ellipsoid, by default
%             equals to identity matrix
%       absTol: double[1,1] - absolute tolerance
%
% Output:
%   regular:
%       bpMat: double[nPoints,2] - boundary points of ellipsoid
%   optional:
%       fVec: double[1,nFaces] - indices of points in each face of
%           bpMat graph
%
% $Author:  Vitaly Baranov  <vetbar42@gmail.com> $    $Date: 04-2013 $
% $Copyright: Lomonosov Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
%
if nargin<3
    cenVec=zeros(2,1);
end
if nargin<4
    qMat=eye(2);
end
if nargin<5
    absTol=elltool.conf.Properties.getAbsTol();
end
if nargout>1
    fVec = 1:nPoints+1;
end
dirMat = gras.geom.circlepart(nPoints);
if nargin==1
    bpMat=dirMat;
else
    [~,bpMat]=ellipsoid.rhomat(qMat,cenVec,absTol,dirMat');
    bpMat=bpMat.';
end