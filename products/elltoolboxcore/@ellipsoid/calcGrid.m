function [lGetGrid, fGetGrid] = calcGrid(nDim,nPlotPoints,factor2d,factor3d)
if nargin==3
    nPlotPoints=floor(nPlotPoints*factor2d);
elseif nargin==4
    nPlotPoints=floor(nPlotPoints*factor3d);
end
if nDim == 2
    lGetGrid = gras.geom.circlepart(nPlotPoints);
    fGetGrid = 1:nPlotPoints+1;
else
    sphereTriang=ellipsoid.calcDepth(nPlotPoints);
    [lGetGrid, fGetGrid] = ...
        gras.geom.tri.spheretri(sphereTriang);
end
lGetGrid(lGetGrid == 0) = eps;
end