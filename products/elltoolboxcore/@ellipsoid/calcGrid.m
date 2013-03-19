function [lGetGrid, fGetGrid] = calcGrid(nDim,nPlotPoints,sphereTriang)
        if nDim == 2
            lGetGrid = gras.geom.circlepart(nPlotPoints);
            fGetGrid = 1:nPlotPoints+1;
        else
            [lGetGrid, fGetGrid] = ...
                gras.geom.tri.spheretri(sphereTriang);
        end
        lGetGrid(lGetGrid == 0) = eps;
end