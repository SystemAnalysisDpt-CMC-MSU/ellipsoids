function [vGridMat, fGridMat] = spheretriext(nDim,nPoints)
%
% GETGRID - compute  grid of 2d or 3d sphere.
%
% Input:
%   regular:
%       nDim: double [1, 1]- dimension of space.
%       nPoints: number of boundary points
%
% Output:
%   regular:
%       bpMat: double[nPoints,nDim] - boundary points of sphere
%   optional:
%       fVec: double[1,nFaces]/double[nPoints,3] - indices of points in 
%           each face of bpMat graph
%
% $Author: Vitaly Baranov <vetbar42@gmail.com>$ $Date: 13-04-2013$
% $Copyright: Lomonosov Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             System Analysis Department 2013$
%
if nDim==2
    fEllbndr=@spherebndr_2d;
else
    fEllbndr=@spherebndr_3d;
end
if nargout>1
    [vGridMat, fGridMat]=fEllbndr(nPoints);
else
    vGridMat=fEllbndr(nPoints);
end
vGridMat(vGridMat == 0) = eps;
%
%
%
function [ bpMat, fVec] = spherebndr_2d(nPoints)
%
% SPHEREBNDR_2D - computes the boudary of 2D ellipsoid 
%
% Input:
%   regular:
%       nPoints: double[1,1] - number of resulting points of sphere boudary
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
if nargout>1
    fVec = 1:nPoints+1;
end
bpMat = gras.geom.circlepart(nPoints);
%
%
%
function [ bpMat, fMat] = spherebndr_3d(nPoints)
%
% SPHREEBNDR_3d - computes the boudary of 3D ellipsoid 
%
% Input:
%   regular:
%       nPoints: double[1,1] - number of resulting points of ellipsoid boudary
% Output:
%   regular:
%       bpMat: doulbe[nPoints,3] - boundary points of ellipsoid
%   optional:
%       fMat: double[3,nFaces] - indices of face verties in bpMat
%
% $Author:  Vitaly Baranov  <vetbar42@gmail.com> $    $Date: 04-2013 $
% $Copyright: Lomonosov Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
%
sphereTriangNum=calcDepth(nPoints);
if nargout<2
    [dirMat, ~] = gras.geom.tri.spheretri(sphereTriangNum);
else
    [dirMat, fMat] = gras.geom.tri.spheretri(sphereTriangNum);
end
bpMat=dirMat;
%
function [ triangDepth ] = calcDepth( nPoints )
%
% CALCDEPTH - calculate depth of sphere triangulation starting with icosaeder
%   and given number of points
%
% $Author:  Vitaly Baranov  <vetbar42@gmail.com> $    $Date: 04-2013 $
% $Copyright: Lomonosov Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
%
%
% Initial icosaeder parameters:
VERTICES_NUM=12;
FACES_NUM=20;
EDGES_NUM=30;
vertNum=VERTICES_NUM;
faceNum=FACES_NUM;
edgeNum=EDGES_NUM;
%
curDepth=0;
isStop=false;
while ~isStop
    curDepth=curDepth+1;
    vertNum=vertNum+edgeNum;
    edgeNum=2*edgeNum+3*faceNum;
    faceNum=4*faceNum;
    isStop=vertNum>=nPoints;
end
triangDepth=curDepth;