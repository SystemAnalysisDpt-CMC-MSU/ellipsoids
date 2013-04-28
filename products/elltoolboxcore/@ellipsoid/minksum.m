function [centVec, boundPointMat] = minksum(inpEllArr,varargin)
%
% MINKSUM - computes geometric (Minkowski) sum of ellipsoids in 2D or 3D.
%
%   MINKSUM(inpEllArr, Options) - Computes geometric sum of ellipsoids
%       in the array inpEllArr, if
%       1 <= min(dimension(inpEllArr)) = max(dimension(inpEllArr)) <= 3,
%       and plots it if no output arguments are specified.
%
%   [centVec, boundPointMat] = MINKSUM(inpEllArr) - Computes
%       geometric sum of ellipsoids in inpEllArr. Here centVec is
%       the center, and boundPointMat - array of boundary points.
%   MINKSUM(inpEllArr) - Plots geometric sum of ellipsoids in
%       inpEllArr in default (red) color.
%   MINKSUM(inpEllArr, Options) - Plots geometric sum of inpEllMat
%       using options given in the Options structure.
%
% Input:
%   regular:
%       inpEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] - array of 
%           ellipsoids of the same dimentions 2D or 3D.
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
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

import elltool.conf.Properties;
import modgen.common.throwerror;
import modgen.common.checkmultvar;
import elltool.logging.Log4jConfigurator;

persistent logger;

ellipsoid.checkIsMe(inpEllArr);

nInpEllip = numel(inpEllArr);
inpEllVec   = reshape(inpEllArr, 1, nInpEllip);
nDimsVec = dimension(inpEllVec);
nDim = nDimsVec(1);
checkmultvar('all(x2(:)==x1)',2,nDimsVec,nDim,...
    'errorTag','wrongSizes','errorMessage',...
    'ellipsoids must be of the same dimension which not higher than 3.');

if (nargin > 1)&&(isstruct(varargin{1}))
    Options = varargin{1};
else
    Options = [];
end

if ~isfield(Options, 'newfigure')
    Options.newfigure = 0;
end

if ~isfield(Options, 'fill')
    Options.fill = 0;
end

if ~isfield(Options, 'show_all')
    Options.show_all = 0;
end

if ~isfield(Options, 'color')
    Options.color = [1 0 0];
end

if ~isfield(Options, 'shade')
    Options.shade = 0.4*ones(1, nInpEllip);
else
    Options.shade = Options.shade(1, 1);
end
nArgOut = nargout;
if nArgOut == 0
    ih = ishold;
end

if (Options.show_all ~= 0) && (nArgOut == 0)
    plot(inpEllVec, 'b');
    hold on;
    if Options.newfigure ~= 0
        figure;
    else
        newplot;
    end
end

if (Properties.getIsVerbose()) && (nInpEllip > 1)
    if isempty(logger)
        logger=Log4jConfigurator.getLogger();
    end
    if nArgOut == 0
        fstStr = 'Computing and plotting geometric sum ';
        secStr = 'of %d ellipsoids...';
        logger.info(sprintf([fstStr secStr], nInpEllip));
    else
        logger.info(sprintf('Computing geometric sum of %d ellipsoids...', ...
            nInpEllip));
    end
end
clrVec = Options.color;

centVec = inpEllVec(1).centerVec;
switch nDim
    case 1
        rad = realsqrt(inpEllVec(1).shapeMat);
        boundPointMat(1, 1) = centVec - rad;
        boundPointMat(1, 2) = centVec + rad;
    case 2
        boundPointMat = ellbndr_2d(inpEllVec(1));
    case 3
        boundPointMat = ellbndr_3d(inpEllVec(1));
end
arrayfun(@(x) fGetBndPnts(x),inpEllVec(2:end));
if ~nArgOut
    switch nDim
        case 2
            if Options.fill ~= 0
                fill(boundPointMat(1, :), boundPointMat(2, :), ...
                    clrVec);
                hold on;
            end
            hPlot = ell_plot(boundPointMat);
            hold on;
            set(hPlot, 'Color', clrVec, 'LineWidth', 2);
            hPlot = ell_plot(centVec, '.');
            set(hPlot, 'Color', clrVec);
            
        case 3
            chllMat = convhulln(boundPointMat');
            nBoundPoints = size(boundPointMat, 2);
            patch('Vertices', boundPointMat', 'Faces', chllMat, ...
                'FaceVertexCData', clrVec(ones(1, nBoundPoints), :),...
                'FaceColor', 'flat', 'FaceAlpha', ...
                Options.shade(1, 1));
            hold on;
            shading interp;
            lighting phong;
            material('metal');
            view(3);
            
        otherwise
            hPlot = ell_plot(boundPointMat);
            hold on;
            set(hPlot, 'Color', clrVec, 'LineWidth', 2);
            hPlot = ell_plot(centVec, '*');
            set(hPlot, 'Color', clrVec);
    end
    if ih == 0
        hold off;
    end
end

if nArgOut == 1
    centVec = boundPointMat;
    clear boundPointMat;
end
if nArgOut == 0
    clear centVec boundPointMat;
end
    function fGetBndPnts(myEll)
        centVec = centVec + myEll.centerVec;
        switch nDim
            case 1
                rad = realsqrt(myEll.shapeMat);
                boundPointMat(1, 1) =boundPointMat(1,1) + ...
                    myEll.centerVec - rad;
                boundPointMat(1, 2) = boundPointMat(1,2) + ...
                    myEll.centerVec + rad;
            case 2
                boundPointMat = boundPointMat + ellbndr_2d(myEll);
            case 3
                boundPointMat = boundPointMat + ellbndr_3d(myEll);
        end
    end
end