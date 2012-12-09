function [varargout] = minksum(varargin)
%
% MINKSUM - computes geometric (Minkowski) sum of ellipsoids in 2D or 3D.
%
%   MINKSUM(inpEllMat, Options) - Computes geometric sum of ellipsoids
%       in the array inpEllMat, if
%       1 <= min(dimension(inpEllMat)) = max(dimension(inpEllMat)) <= 3,
%       and plots it if no output arguments are specified.
%
%   [centVec, boundPointMat] = MINKSUM(inpEllMat) - Computes
%       geometric sum of ellipsoids in inpEllMat. Here centVec is
%       the center, and boundPointMat - array of boundary points.
%   MINKSUM(inpEllMat) - Plots geometric sum of ellipsoids in
%       inpEllMat in default (red) color.
%   MINKSUM(inpEllMat, Options) - Plots geometric sum of inpEllMat
%       using options given in the Options structure.
%
% Input:
%   regular:
%       inpEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids
%           of the same dimentions 2D or 3D.
%
%   optional:
%       Options: structure[1, 1] - fields:
%           show_all: double[1, 1] - if 1, displays
%               also ellipsoids fstEll and secEll.
%           newfigure: double[1, 1] - if 1, each plot
%               command will open a new figure window.
%           fill: double[1, 1] - if 1, the resulting
%               set in 2D will be filled with color.
%           color: double[1, 3] - sets default colors
%               in the form [x y z].
%           shade: double[1, 1] = 0-1 - level of transparency
%               (0 - transparent, 1 - opaque).
%
% Output:
%   centVec: double[nDim, 1] - center of the resulting set.
%   boundPointMat: double[nDim, nBoundPoints] - set of boundary
%       points (vertices) of resulting set.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import modgen.common.throwerror;

[reg,~,plObj,isNewFigure,isFill,lineWidth,colorVec,shad,isShowAll...
    isRelPlotterSpec,~,isIsFill,isLineWidth,isColorVec,isShad]=modgen.common.parseparext(varargin,...
    {'relDataPlotter','newFigure','fill','lineWidth','color','shade','showAll';...
    [],0,0,1,[1 0 0],0.4,0;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
    @(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x)});

% nAi = nargin;
if ~isRelPlotterSpec
    if ishold
        plObj=smartdb.disp.RelationDataPlotter('figureGetNewHandleFunc', @(varargin)gcf,'axesGetNewHandleFunc',@(varargin)gca);
    else
        plObj=smartdb.disp.RelationDataPlotter();
    end
end

fstInpArg = reg{1};
if ~isa(fstInpArg, 'ellipsoid')
    throwerror('wrongInput', ...
        'MINKSUM: input argument must be an array of ellipsoids.');
end

inpEllMat   = reg{1};
[mRows, nCols] = size(inpEllMat);
nInpEllip = mRows * nCols;
inpEllVec   = reshape(inpEllMat, 1, nInpEllip);
nDimsVec = dimension(inpEllVec);
minDim = min(nDimsVec);
maxDim = max(nDimsVec);

if minDim ~= maxDim
    throwerror('wrongSizes', ...
        'MINKSUM: ellipsoids must be of the same dimension.');
end
if maxDim > 3
    throwerror('wrongSizes', ...
        'MINKSUM: ellipsoid dimension must be not higher than 3.');
end

if (isShawAll ~= 0) && (nargout == 1)
%     plot(inpEllVec, 'b');
end

if (Properties.getIsVerbose()) && (nInpEllip > 1)
    if nargout == 1
        fstStr = 'Computing and plotting geometric sum ';
        secStr = 'of %d ellipsoids...\n';
        fprintf([fstStr secStr], nInpEllip);
    else
        fprintf('Computing geometric sum of %d ellipsoids...\n', ...
            nInpEllip);
    end
end

for iEllip = 1:nInpEllip
    myEll = inpEllVec(iEllip);    
    switch maxDim
        case 2,
            if iEllip == 1
                boundPointMat = ellbndr_2d(myEll);
                centVec = myEll.center;
            else
                boundPointMat = boundPointMat + ellbndr_2d(myEll);
                centVec = centVec + myEll.center;
            end
            if (iEllip == nInpEllip) && (nargout == 1)
                if isFill
                    fill(boundPointMat(1, :), boundPointMat(2, :), ...
                        clrVec);
                    hold on;
                end
%                 hPlot = ell_plot(boundPointMat);
%                 hold on;
%                 set(hPlot, 'Color', clrVec, 'LineWidth', 2);
%                 hPlot = ell_plot(centVec, '.');
%                 set(hPlot, 'Color', clrVec);
            end
            
        case 3,
            if iEllip == 1
                boundPointMat = ellbndr_3d(myEll);
                centVec = myEll.center;
            else
                boundPointMat = boundPointMat + ellbndr_3d(myEll);
                centVec = centVec + myEll.center;
            end
            if (iEllip == nInpEllip) && (nargout == 1)
%                 chllMat = convhulln(boundPointMat');
%                 nBoundPoints = size(boundPointMat, 2);
%                 patch('Vertices', boundPointMat', 'Faces', chllMat, ...
%                     'FaceVertexCData', clrVec(ones(1, nBoundPoints), :),...
%                     'FaceColor', 'flat', 'FaceAlpha', ...
%                     Options.shade(1, 1));
%                 hold on;
%                 shading interp;
%                 lighting phong;
%                 material('metal');
%                 view(3);
            end
            
        otherwise,
            if iEllip == 1
                centVec = myEll.center;
                boundPointMat(1, 1) = myEll.center - sqrt(myEll.shape);
                boundPointMat(1, 2) = myEll.center + sqrt(myEll.shape);
            else
                centVec = centVec + myEll.center;
                boundPointMat(1, 1) = boundPointMat(1, 1) + myEll.center...
                    - sqrt(myEll.shape);
                boundPointMat(1, 2) = boundPointMat(1, 2) + myEll.center...
                    + sqrt(myEll.shape);
            end
            if (iEllip == nInpEllip) && (nargout == 1)
%                 hPlot = ell_plot(boundPointMat);
%                 hold on;
%                 set(hPlot, 'Color', clrVec, 'LineWidth', 2);
%                 hPlot = ell_plot(centVec, '*');
%                 set(hPlot, 'Color', clrVec);
            end
            
    end
end
if nargout == 1
    varargout = plObj;
else
    varargout = [centVec boundPointMat];
end