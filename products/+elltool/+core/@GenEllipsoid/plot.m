function plObj = plot(varargin)
%
% PLOT - plots ellipsoids in 2D or 3D.
%
%
% Usage:
%       plot(ell) - plots generic ellipsoid ell in default (red) color.
%       plot(ellArr) - plots an array of generic ellipsoids.
%       plot(ellArr, 'Property',PropValue,...) - plots ellArr with setting
%                                                properties.
%
% Input:
%   regular:
%       ellArr:  elltool.core.GenEllipsoid: [dim11Size,dim12Size,...,
%                dim1kSize] - array of 2D or 3D GenEllipsoids objects. 
%                All ellipsoids in ellArr  must be either 2D or 3D
%                simutaneously.
%   optional:
%       color1Spec: char[1,1] - color specification code, can be 'r','g',
%                               etc (any code supported by built-in Matlab 
%                               function).
%       ell2Arr: elltool.core.GenEllipsoid: [dim21Size,dim22Size,...,
%                               dim2kSize] - second ellipsoid array...
%       color2Spec: char[1,1] - same as color1Spec but for ell2Arr
%       ....
%       ellNArr: elltool.core.GenEllipsoid: [dimN1Size,dim22Size,...,
%                                dimNkSize] - N-th ellipsoid array
%       colorNSpec - same as color1Spec but for ellNArr.
%   properties:
%       'newFigure': logical[1,1] - if 1, each plot command will open a new .
%                    figure window Default value is 0.
%       'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
%               if 1, ellipsoids in 2D will be filled with color. 
%               Default value is 0.
%       'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
%                line width for 1D and 2D plots. 
%                Default value is 1.
%       'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
%                sets default colors in the form [x y z]. 
%                Default value is [1 0 0].
%       'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
%                level of transparency between 0 and 1 (0 - transparent, 
%                1 - opaque).
%                Default value is 0.4.
%       'relDataPlotter' - relation data plotter object.
%       Notice that property vector could have different dimensions, only
%       total number of elements must be the same.
% Output:
%   regular:
%       plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
%       data plotter object.
%
% Examples:
%   plot([ell1, ell2, ell3], 'color', [1, 0, 1; 0, 0, 1; 1, 0, 0]);
%   plot([ell1, ell2, ell3], 'color', [1; 0; 1; 0; 0; 1; 1; 0; 0]);
%   plot([ell1, ell2, ell3; ell1, ell2, ell3], 'shade', [1, 1, 1; 1, 1,
%     1]);
%   plot([ell1, ell2, ell3; ell1, ell2, ell3], 'shade', [1; 1; 1; 1; 1;
%       1]);
%   plot([ell1, ell2, ell3], 'shade', 0.5);
%   plot([ell1, ell2, ell3], 'lineWidth', 1.5);
%   plot([ell1, ell2, ell3], 'lineWidth', [1.5, 0.5, 3]);
% 
%$Author: <Vadim Kaushanskiy>  <vkaushanskiy@gmail.com> $
%$Date: 2012-12-21 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
% $Author: <Ilya Lyubich>  <lubi4ig@gmail.com> $    $Date: <8 January 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
import elltool.conf.Properties;
import modgen.common.throwerror;
import elltool.core.GenEllipsoid;
import elltool.plot.plotgeombodyarr;
import elltool.logging.Log4jConfigurator;

logger=Log4jConfigurator.getLogger();
N_PLOT_POINTS = 80;
SPHERE_TRIANG_CONST = 3;
[plObj,nDim,isHold]= ...
    plotgeombodyarr(@(x)isa(x,'elltool.core.GenEllipsoid'),...
        @(x)dimension(x),@fCalcBodyTriArr,@patch,varargin{:});
if (nDim < 3)
    [reg]=...
        modgen.common.parseparext(varargin,...
        {'relDataPlotter';...
        [],;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
        });
    plObj= plotgeombodyarr(@(x)isa(x,'elltool.core.GenEllipsoid'),...
        @(x)dimension(x),@fCalcCenterTriArr,...
        @(varargin)patch(varargin{:},'marker','*'),reg{:},...
        'relDataPlotter',plObj, 'priorHold',true,'postHold',isHold);
end




    function [xMat,fMat] = fCalcCenterTriArr(ellsArr)
        nDim = dimension(ellsArr(1));
        if nDim == 1
            [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr);
        end
        [xMat, fMat] = arrayfun(@(x) fCalcCenterTri(x), ellsArr, ...
            'UniformOutput', false);
        function [xMat, fMat] = fCalcCenterTri(plotEll)
            import elltool.core.GenEllipsoid;
            xMat = plotEll.getCenter();
            fMat = [1 1];
        end
    end

    function [lGetGrid, fGetGrid] = calcGrid(nDim)
        if nDim == 2
            lGetGrid = gras.geom.circlepart(N_PLOT_POINTS);
            fGetGrid = 1:N_PLOT_POINTS+1;
        else
            [lGetGrid, fGetGrid] = ...
                gras.geom.tri.spheretri(SPHERE_TRIANG_CONST);
        end
        lGetGrid(lGetGrid == 0) = eps;
    end
    function [xMat,fMat] = fCalcBodyTriArr(ellsArr)
        import elltool.core.GenEllipsoid;
        [minValVec, maxValVec] = findMinAndMaxInEachDim(ellsArr);
        minValVec = reshape(minValVec, numel(minValVec), 1);
        maxValVec = reshape(maxValVec, numel(maxValVec), 1);
        nDim = dimension(ellsArr(1));
        if nDim == 1
            [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr);
        end
        [lGetGridMat, fGetGridMat] = calcGrid(nDim);
        [xMat, fMat] = arrayfun(@(x) fCalcBodyTri(x), ellsArr, ...
            'UniformOutput', false);
        
        
        
        function [xMat, fMat] = fCalcBodyTri(plotEll)
            import elltool.core.GenEllipsoid;
            qVec = plotEll.getCenter();
            diagMat = plotEll.getDiagMat();
            eigvMat = plotEll.getEigvMat();
            ell = GenEllipsoid(diagMat);
            
            [xMat, fMat] = ellPoints(ell, nDim);
            nPoints = size(xMat, 2);
            xMat = getRidOfInfVal(xMat, qVec);
            xMat = eigvMat.'*xMat + repmat(qVec, 1, nPoints);
        end
        
        function xMat = getRidOfInfVal(xMat, qVec)
            maxVec = maxValVec - qVec;
            minVec=minValVec-qVec;
            isInfMat=xMat==Inf;
            isNegInfMat=xMat==-Inf;
            maxMat=repmat(maxVec,1,size(xMat, 2));
            minMat=repmat(minVec,1,size(xMat, 2));
            xMat(isInfMat)=maxMat(isInfMat);
            xMat(isNegInfMat)=minMat(isNegInfMat);
        end
        function [xMat, fMat] = ellPoints(ell, nDim)
            nPoints = size(lGetGridMat, 1);
            xMat = zeros(nDim, nPoints+1);
            dMat = ell.getDiagMat();
            qCenVec = ell.getCenter();
            xMat(:, 1:end-1) = dMat.^0.5*lGetGridMat.' + ...
                repmat(qCenVec, 1, nPoints);
            xMat(:, end) = xMat(:, 1);
            fMat = fGetGridMat;
        end
        if (nDim < 1) || (nDim > 3)
            throwerror('wrongDim','ellipsoid dimension can be 1, 2 or 3');
        end
        if elltool.conf.Properties.getIsVerbose()
            if ellNum == 1
                logger.info('Plotting ellipsoid...');
            else
                logger.info(sprintf('Plotting %d ellipsoids...', ellNum));
            end
        end
    end










end


function [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr)
ellsCMat = arrayfun(@(x) oneDim2TwoDim(x), ellsArr, ...
    'UniformOutput', false);
ellsArr = vertcat(ellsCMat{:});
nDim = 2;
    function ellTwoDim = oneDim2TwoDim(ell)
        import elltool.core.GenEllipsoid;
        ellCenVec = ell.getCenter();
        ellEigMat = ell.getEigvMat();
        ellDiagMat = ell.getDiagMat();
        ellTwoDim = GenEllipsoid([ellCenVec, 0].', ...
            diag([ellDiagMat, 0]), diag([ellEigMat, 0]));
    end
end

function [minValVec, maxValVec] = findMinAndMaxInEachDim(ellsArr)

nDim = max(dimension(ellsArr));
if nDim == 1
    [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr);
end
[minValVec, maxValVec] = arrayfun(@(x) findMinAndMaxDim(ellsArr, x, nDim),...
    1:nDim);


    function [minValVec, maxValVec] = findMinAndMaxDim(ellVec, ...
            dirDim, nDims)
        import elltool.core.GenEllipsoid;
        
        minlVec = zeros(nDims, 1);
        minlVec(dirDim) = -1;
        maxlVec = zeros(nDims, 1);
        maxlVec(dirDim) = 1;
        [minValVec, maxValVec] = arrayfun(@(x)findMinAndMaxDimEll(x),...
            ellVec);
        minValVec = min(minValVec);
        maxValVec = max(maxValVec);
        
        function [minVal, maxVal] = findMinAndMaxDimEll(ell)
            import elltool.core.GenEllipsoid;
            qCenVec = ell.getCenter();
            dMat = ell.getDiagMat();
            ell = GenEllipsoid(qCenVec, dMat);
            minVal = Inf;
            maxVal = -Inf;
            
            [~, curEllMax] = rho(ell, maxlVec);
            [~, curEllMin] = rho(ell, minlVec);
            if (curEllMin(dirDim) < minVal)&& (curEllMin(dirDim) > -Inf)
                minVal = curEllMin(dirDim);
            end
            if (curEllMax(dirDim) > maxVal) && (curEllMax(dirDim) < Inf)
                maxVal = curEllMax(dirDim);
            end
            diagVec = diag(dMat);
            maxEig = max(diagVec(diagVec < Inf));
            if (-3*maxEig+qCenVec(dirDim) < minVal) &&...
                    (curEllMin(dirDim) == -Inf)
                minVal = -3*maxEig+qCenVec(dirDim);
            end
            if (3*maxEig+qCenVec(dirDim) > maxVal) && ...
                    (curEllMax(dirDim) == Inf)
                maxVal = 3*maxEig+qCenVec(dirDim);
            end
        end
    end
end
