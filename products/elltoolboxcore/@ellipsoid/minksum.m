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
%       'shawAll': logical[1,1] - if 1, plot all ellArr.
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

varargout= num2cell(culcoperell(@calcBodyPoints,varargin{:}),2);



    function [xSumMat,fMat,qSumMat] = calcBodyPoints(ellsArr,nDim,lGetGridMat, fGetGridMat)
        [xMat, fMat] = arrayfun(@(x) ellPoints(x, nDim), ellsArr, ...
            'UniformOutput', false);
        xSumMat = 0;
        for iXMat=1:numel(xMat)
            xSumMat = xSumMat + xMat{iXMat};
        end
        qSumMat = 0;
        qMat = arrayfun(@(x) {x.center}, ellsArr);
        for iQMat=1:numel(qMat)
            qSumMat = qSumMat + qMat{iQMat};
        end
        function [xMat, fMat] = ellPoints(ell, nDim)
            nPoints = size(lGetGridMat, 1);
            xMat = zeros(nDim, nPoints+1);
            [qCenVec,qMat] = ell.double();
            [~,xMat(:, 1:end-1)] = rho(ell,sqrtm(qMat)*lGetGridMat.' + ...
                repmat(qCenVec, 1, nPoints));
            [~,xMat(:, end)] = rho(ell,xMat(:, 1));
            fMat = fGetGridMat;
        end
    end

end