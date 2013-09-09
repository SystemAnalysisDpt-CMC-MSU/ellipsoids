function [diffBoundMat, isPlotCenter3d] = calcdiffonedir(fstEll,secEll,lMat,pUniversalVec,isGoodDirVec)
ABS_TOL = 1e-14;
absTol = elltool.conf.Properties.getAbsTol();
[~, minEllPtsMat] = rho(fstEll, ...
    lMat);
[~, subEllPtsMat] = rho(secEll, ...
    lMat);
if dimension(fstEll) == 3
    isPlotCenter3d = true;
else
    isPlotCenter3d = false;
end
[diffBoundMat] = arrayfun(@(x,y) calcdiff(x,y),isGoodDirVec,...
    1:size(lMat,2), 'UniformOutput',false);


    function diffBoundMat = calcdiff(isGood, ind)
        if isGood
            diffBoundMat = minEllPtsMat(:,ind) - subEllPtsMat(:,ind);
        else
            [~, diffBoundMat] = ...
                gras.geom.ell.rhomat((1-pUniversalVec(ind))...
                *secEll.shapeMat + (1-1/pUniversalVec(ind))*...
                fstEll.shapeMat, ...
                lMat(:,ind),absTol,fstEll.centerVec-secEll.centerVec);
        end
        if abs(diffBoundMat-fstEll.centerVec+secEll.centerVec) < ABS_TOL
            diffBoundMat = fstEll.centerVec-secEll.centerVec;
        else
            isPlotCenter3d = false;
        end
    end
end