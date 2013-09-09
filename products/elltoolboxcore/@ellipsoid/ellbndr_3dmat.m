function [ bpMat, fMat] = ellbndr_3dmat(nPoints, cenVec, qMat,absTol)
%
% ELLBNDR_3DMAT - computes the boudary of 3D ellipsoid given its center
%                 and shape matrix
%
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
%       bpMat: doulbe[nPoints,3] - boundary points of ellipsoid
%   optional:
%       fMat: double[3,nFaces] - indices of face verties in bpMat
%
% $Author:  Vitaly Baranov  <vetbar42@gmail.com> $    $Date: 04-2013 $
% $Copyright: Lomonosov Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
%
if nargin<3
    cenVec=zeros(3,1);
end
if nargin<4
    qMat=eye(3);
end
if nargin<5
    absTol=elltool.conf.Properties.getAbsTol();
end
%
sphereTriangNum=calcDepth(nPoints);
if nargout<2
    [dirMat, ~] = gras.geom.tri.spheretri(sphereTriangNum);
else
    [dirMat, fMat] = gras.geom.tri.spheretri(sphereTriangNum);
end
if nargin==1
    bpMat=dirMat;
else
    [~, bpMat] = ellipsoid.rhomat(qMat,cenVec,absTol,dirMat');
    bpMat=bpMat.';
end

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