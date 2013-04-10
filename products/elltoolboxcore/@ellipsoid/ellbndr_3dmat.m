function [ bpMat ] = ellbndr_3dmat( cenVec, qMat,nPoints, absTol)
%
% ELLBNDR_3DMAT - computes the boudary of 3D ellipsoid given its center
%                 and shape matrix
%
sphereTriangNum=calcDepth(nPoints);
[dirMat, ~] = gras.geom.tri.spheretri(sphereTriangNum);
[~, bpMat] = ellipsoid.rhomat(qMat,cenVec,absTol,dirMat');

function [ triangDepth ] = calcDepth( nPoints )
%
% CALCDEPTH - calculate depth of sphere triangulation starting with icosaeder 
%   and given number of points 
%
%
% Initial icosaeder parameters:
vertNum=12;
faceNum=20;
edgeNum=30;
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


