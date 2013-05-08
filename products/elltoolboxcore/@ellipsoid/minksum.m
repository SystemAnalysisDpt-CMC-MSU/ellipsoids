function [varargout] = minksum(varargin)
%
% MINKSUM - computes geometric (Minkowski) sum of ellipsoids in 2D or 3D.
% 
% Usage:
%   MINKSUM(inpEllMat,'Property',PropValue,...) - Computes geometric sum of
%       ellipsoids in the array inpEllMat, if
%       1 <= min(dimension(inpEllMat)) = max(dimension(inpEllMat)) <= 3,
%       and plots it if no output arguments are specified.
%
%   [centVec, boundPointMat] = MINKSUM(inpEllMat) - Computes
%       geometric sum of ellipsoids in inpEllMat. Here centVec is
%       the center, and boundPointMat - array of boundary points.
%   MINKSUM(inpEllMat) - Plots geometric sum of ellipsoids in
%       inpEllMat in default (red) color.
%   MINKSUM(inpEllMat, 'Property',PropValue,...) - Plots geometric sum of 
%   inpEllMat with setting properties.
%
% Input:
%   regular:
%       ellArr:  Ellipsoid: [dim11Size,dim12Size,...,dim1kSize] -
%                array of 2D or 3D Ellipsoids objects. All ellipsoids 
%                in ellArr must be either 2D or 3D simutaneously.
%
%   properties:
%    'showAll': logical[1,1] - if 1, plot all ellArr.
%                    Default value is 0.
%    'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
%               if 1, ellipsoids in 2D will be filled with color. Default 
%               value is 0.
%    'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]-
%                    line width for 1D and 2D plots. Default value is 1.
%    'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
%        sets default colors in the form [x y z]. Default value is [1 0 0].
%    'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
%      level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
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
% Example:
%   firstEllObj = ellipsoid([-2; -1], [2 -1; -1 1]);
%   secEllObj = ell_unitball(2);
%   ellVec = [firstEllObj, secellObj]
%   sumVec = minksum(ellVec);
% $Author: <Ilya Lyubich>  <lubi4ig@gmail.com> $  Date: <8 January 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $

import elltool.plot.plotgeombodyarr;
import modgen.common.throwerror;

if nargout == 0
    minkCommonAction(@getEllArr,@fCalcBodyTriArr,@fCalcCenterTriArr,...
        varargin{:});
elseif nargout == 1
    output = minkCommonAction(@getEllArr,@fCalcBodyTriArr,...
        @fCalcCenterTriArr,varargin{:});
    varargout = output(1);
else
    [qSumMat,boundMat] = minkCommonAction(@getEllArr,@fCalcBodyTriArr,...
        @fCalcCenterTriArr,varargin{:});
    varargout(1) = {qSumMat};
    varargout(2) = {boundMat};
end
    
    function ellsVec = getEllArr(ellsArr)
        if isa(ellsArr, 'ellipsoid')
            cnt    = numel(ellsArr);
            ellsVec = reshape(ellsArr, cnt, 1);
        end
    end
    function [xCenterCMat,fCMat] = fCalcCenterTriArr(ellsArr)
        qSumMat = 0;
        nDim = dimension(ellsArr(1));
        if nDim == 1
            [ellsArr,~] = rebuildOneDim2TwoDim(ellsArr);
        end
        qMat = arrayfun(@(x) {x.centerVec}, ellsArr);
        for iQMat=1:numel(qMat)
            qSumMat = qSumMat + qMat{iQMat};
        end
        xCenterCMat = {qSumMat};
        fCMat = {[1 1]};
    end
    function [xSumCMat,fCMat] = fCalcBodyTriArr(ellsArr)
        nDim = dimension(ellsArr(1));
        if nDim == 1
            [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr);
        end
        [lGridMat, fGridMat] = getGridByFactor(ellsArr(1));
        [xMat, fCMat] = arrayfun(@(x) fCalcBodyTri(x, nDim), ellsArr, ...    
            'UniformOutput', false);
        xSumCMat = 0;
        for iXMat=1:numel(xMat)
            xSumCMat = xSumCMat + xMat{iXMat};
        end
        xSumCMat = {xSumCMat};
        fCMat = fCMat(1);
        function [xMat, fMat] = fCalcBodyTri(ell, nDim)
            nPoints = size(lGridMat, 1);
            xMat = zeros(nDim, nPoints+1);
            [~,xMat(:, 1:end-1)] = rho(ell,lGridMat.');
            xMat(:, end) = xMat(:, 1);
            fMat = fGridMat;
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