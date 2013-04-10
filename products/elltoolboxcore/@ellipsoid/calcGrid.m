function [lGetGrid, fGetGrid] = calcGrid(ellObj,factor2d,factor3d)
nDim=dimension(ellObj);
if nargin<3
    factor3d=1;
end
if nargin<2
    factor2d=1;
end
if nDim==3
    nPlotPoints=ellObj.nPlot3dPoints;
    if ~(factor3d==1)
        nPlotPoints=floor(nPlotPoints*factor2d);
    end
    sphereTriang=calcDepth(nPlotPoints);
    [lGetGrid, fGetGrid] = ...
        gras.geom.tri.spheretri(sphereTriang);
else
    nPlotPoints=ellObj.nPlot2dPoints;
    if ~(factor2d==1)
        nPlotPoints=floor(nPlotPoints*factor3d);
    end
    lGetGrid = gras.geom.circlepart(nPlotPoints);
    fGetGrid = 1:nPlotPoints+1;
end
lGetGrid(lGetGrid == 0) = eps;

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
