function [lGetGrid, fGetGrid] = calcGrid(ellObj,factor)
nDim=dimension(ellObj);
if nargin<3
    factor=1;
end
if nargin<2
    factor=1;
end
if nDim==3
    nPlotPoints=ellObj.nPlot3dPoints;
    if ~(factor==1)
        nPlotPoints=floor(nPlotPoints*factor);
    end
    [lGetGrid, fGetGrid]=ellObj.ellbndr_3dmat(nPlotPoints);
else
    nPlotPoints=ellObj.nPlot2dPoints;
    if ~(factor==1)
        nPlotPoints=floor(nPlotPoints*factor);
    end
    lGetGrid = ellObj.ellbndr_2dmat(nPlotPoints);
    fGetGrid = 1:nPlotPoints+1;
end
lGetGrid=lGetGrid.';
lGetGrid(lGetGrid == 0) = eps;