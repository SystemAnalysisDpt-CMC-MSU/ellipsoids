function [varargout] = minksum(varargin)
%
% MINKSUM - computes geometric (Minkowski) sum of ellipsoids in 2D or 3D.
% Usage:
%   MINKSUM(inpEllMat,'Property',PropValue,...) - Computes geometric sum of ellipsoids
%       in the array inpEllMat, if
%       1 <= min(dimension(inpEllMat)) = max(dimension(inpEllMat)) <= 3,
%       and plots it if no output arguments are specified.
%
%   [centVec, boundPointMat] = MINKSUM(inpEllMat) - Computes
%       geometric sum of ellipsoids in inpEllMat. Here centVec is
%       the center, and boundPointMat - array of boundary points.
%   MINKSUM(inpEllMat) - Plots geometric sum of ellipsoids in
%       inpEllMat in default (red) color.
%   MINKSUM(inpEllMat, 'Property',PropValue,...) - Plots geometric sum of inpEllMat
%       with setting properties.
%
% Input:
%   regular:
%       ellArr:  Ellipsoid: [dim11Size,dim12Size,...,dim1kSize] -
%                array of 2D or 3D Ellipsoids objects. All ellipsoids in ellArr
%                must be either 2D or 3D simutaneously.
%
%   properties:
%       'showAll': logical[1,1] - if 1, plot all ellArr.
%                    Default value is 0.
%       'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
%               if 1, ellipsoids in 2D will be filled with color. Default value is 0.
%       'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
%                    line width for 1D and 2D plots. Default value is 1.
%       'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
%                sets default colors in the form [x y z]. Default value is [1 0 0].
%       'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
%                level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
%                Default value is 0.4.
%       'relDataPlotter' - relation data plotter object.
%       Notice that property vector could have different dimensions, only
%       total number of elements must be the same.
%
% Output:
%   centVec: double[nDim, 1] - center of the resulting set.
%   boundPointMat: double[nDim, nBoundPoints] - set of boundary
%       points (vertices) of resulting set.
%
% $Author: <Ilya Lyubich>  <lubi4ig@gmail.com> $    $Date: <8 January 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $

import elltool.plot.plotgeombodyarr;
if (nargout == 1)||(nargout == 0)
    [reg,~,isShowAll]=...
        modgen.common.parseparext(varargin,...
        {'showAll' ;...
        false;
        @(x)isa(x,'logical')});
    [plObj,nDim,isHold,ellsArr]= plotgeombodyarr('ellipsoid',@rebuildOneDim2TwoDim,@calcBodyPoints,@patch,reg{:},'plotBodies',1);
    if (nDim < 3)
        [reg,~,~]=...
            modgen.common.parseparext(reg,...
            {'relDataPlotter';...
            [],;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
            });
        plObj= plotgeombodyarr('ellipsoid',@rebuildOneDim2TwoDim,@calcCenterEllPoints,...
            @(varargin)patch(varargin{:},'marker','*'),reg{:},'relDataPlotter',plObj, 'priorHold',true,'postHold',isHold,'plotBodies',1);
    end
    if isShowAll
        plot(ellsArr, 'color', [0 0 0],'relDataPlotter',plObj);
    end
    varargout = {plObj};
else
    import modgen.common.throwerror;
    N_PLOT_POINTS = 80;
    SPHERE_TRIANG_CONST = 3;
    ellsCMat = cellfun(@(x)getEllArr(x),varargin,'UniformOutput', false);
    ellsArr = vertcat(ellsCMat{:});
    ellsArrDims = dimension(ellsArr);
    mDim    = min(ellsArrDims);
    nDim    = max(ellsArrDims);
    if mDim ~= nDim
        throwerror('dimMismatch', ...
            'Objects must have the same dimensions.');
    end
    if nDim == 1
        [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr);
    end
    if nDim == 2
        lGetGrid = gras.geom.circlepart(N_PLOT_POINTS);
        fGetGrid = 1:N_PLOT_POINTS+1;
    else
        [lGetGrid, fGetGrid] = ...
            gras.geom.tri.spheretri(SPHERE_TRIANG_CONST);
    end
    lGetGrid(lGetGrid == 0) = eps;
    xSumMat = calcBodyPoints(ellsArr,nDim,lGetGrid,fGetGrid);
    qSumMat = calcCenterEllPoints(ellsArr,nDim,lGetGrid,fGetGrid);
    varargout(1) = qSumMat;
    varargout(2) = xSumMat;
end
    function ellsVec = getEllArr(ellsArr)
        if isa(ellsArr, 'ellipsoid')
            cnt    = numel(ellsArr);
            ellsVec = reshape(ellsArr, cnt, 1);
            
        else
            import modgen.common.throwerror;
            throwerror('wrongInput', ...
                'if you don''t plot, all inputs must be ellipsoids');
        end
    end
    function [xMat,fMat] = calcCenterEllPoints(ellsArr,~,~, fGetGridMat)
        qSumMat = 0;
        qMat = arrayfun(@(x) {x.center}, ellsArr);
        for iQMat=1:numel(qMat)
            qSumMat = qSumMat + qMat{iQMat};
        end
        xMat = {qSumMat};
        fMat = fGetGridMat(1);
    end
    function [xSumMat,fMat] = calcBodyPoints(ellsArr,nDim,lGetGridMat, fGetGridMat)
        [xMat, fMat] = arrayfun(@(x) ellPoints(x, nDim), ellsArr, ...
            'UniformOutput', false);
        xSumMat = 0;
        for iXMat=1:numel(xMat)
            xSumMat = xSumMat + xMat{iXMat};
        end
        xSumMat = {xSumMat};
        fMat = fMat(1);
        function [xMat, fMat] = ellPoints(ell, nDim)
            nPoints = size(lGetGridMat, 1);
            xMat = zeros(nDim, nPoints+1);
            [~,xMat(:, 1:end-1)] = rho(ell,lGetGridMat.');
            xMat(:,1:end-1) = xMat(:,1:end-1) ;
            xMat(:, end) = xMat(:, 1);
            fMat = fGetGridMat;
        end
    end
    function [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr)
        ellsCMat = arrayfun(@(x) oneDim2TwoDim(x), ellsArr, ...
            'UniformOutput', false);
        ellsArr = vertcat(ellsCMat{:});
        nDim = 2;
        function ellTwoDim = oneDim2TwoDim(ell)
            [ellCenVec, qMat] = ell.double();
            ellTwoDim = ellipsoid([ellCenVec, 0].', ...
                diag([qMat, 0]));
        end
    end

end