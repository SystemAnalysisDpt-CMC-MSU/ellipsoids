function [ bpMat, fMat] = ellbndr_2dmat(  nPoints, cenVec, qMat,absTol)
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
%       bpMat: double[2,nPoints] - boundary points of ellipsoid
%   optional:
%       fMat: double[nFaces] - indices of points in each face of
%           bpMat graph
%
% $Author:  Vitaly Baranov  <vetbar42@gmail.com> $    $Date: 04-2013 $
% $Copyright: Lomonosov Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
%
if nargin<2
    cenVec=zeros(2,1);
end
if nargin<3
    qMat=eye(2);
end
if nargin<4
    absTol=elltool.conf.Properties.getAbsTol();
end
if nargout>1
    fMat = 1:nPoints+1;
end
dirMat = gras.geom.circlepart(nPoints);
[~,bpMat]=ellipsoid.rhomat(qMat,cenVec,absTol,dirMat');