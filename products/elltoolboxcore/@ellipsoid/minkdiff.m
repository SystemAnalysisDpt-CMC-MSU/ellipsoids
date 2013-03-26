function [centVec, boundPointMat] = minkdiff(fstEll,secEll,varargin)
%
% MINKDIFF - computes geometric (Minkowski) difference of two
%            ellipsoids in 2D or 3D.
%
%   MINKDIFF(fstEll, secEll, Options) - Computes geometric difference
%       of two ellipsoids fstEll - secEll, if 1 <= dimension(fstEll) =
%       = dimension(secEll) <= 3, and plots it if no output arguments
%       are specified.
%   [centVec, boundPointMat] = MINKDIFF(fstEll, secEll)  Computes
%       geometric difference of two ellipsoids fstEll - secEll.
%       Here centVec is the center, and boundPointMat - matrix
%       whose colums are boundary points.
%   MINKDIFF(fstEll, secEll)  Plots geometric difference of two
%       ellipsoids fstEll - secEll in default (red) color.
%   MINKDIFF(fstEll, secEll, Options)  Plots geometric difference
%       fstEll - secEll using options given in the Options structure.
%
%   In order for the geometric difference to be nonempty set,
%   ellipsoid fstEll must be bigger than secEll in the sense that
%   if fstEll and secEll had the same center, secEll would be
%   contained inside fstEll.
%
% Input:
%   regular:
%       fstEll: ellipsoid [1, 1] - first ellipsoid. Suppose
%           nDim - space dimension, nDim = 2 or 3.
%       secEll: ellipsoid [1, 1] - second ellipsoid
%           of the same dimention.
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
%   centVec: double[nDim, 1]/double[0, 0] - center of the resulting set.
%       centVec may be empty if ellipsoid fsrEll isn't bigger
%       than secEll.
%   boundPointMat: double[nDim, nBoundPoints]/double[0, 0] - set of
%       boundary points (vertices) of resulting set. boundPointMat
%       may be empty if  ellipsoid fstEll isn't bigger than secEll.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;
import modgen.common.throwerror;
import modgen.common.checkmultvar;

persistent logger;

ellipsoid.checkIsMe(fstEll,'first');
ellipsoid.checkIsMe(secEll,'second');
checkmultvar('isscalar(x1)&&isscalar(x2)',2,fstEll,secEll,...
    'errorTag','wrongInput','errorMessage',...
    'first and second arguments must be single ellipsoids.');
nDim = dimension(fstEll);
checkmultvar('(x1==x2)&&(x1<4)',2,nDim,dimension(secEll),...
    'errorTag','wrongSizes','errorMessage',...
    'ellipsoids must be of the same dimension, which not higher than 3.');
nArgOut = nargout;
if ~isbigger(fstEll, secEll)
    switch nArgOut
        case 0,
            if isempty(logger)
                logger=Log4jConfigurator.getLogger();
            end
            fstStr = 'Geometric difference of these two ellipsoids';
            secStr = ' is empty set.';
            logger.info([fstStr secStr]);
            return;
        case 1,
            centVec = [];
            return;
            
        otherwise,
            centVec = [];
            boundPointMat = [];
            return;
    end
end

if nargin > 2 && isstruct(varargin{1})
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
    Options.shade = 0.4;
else
    Options.shade = Options.shade(1, 1);
end

clrVec  = Options.color;

if ~nArgOut
    isHld = ishold;
end

if (Options.show_all ~= 0) && (nargout == 0)
    plot([fstEll secEll], 'b');
    hold on;
    if Options.newfigure ~= 0
        figure;
    else
        newplot;
    end
end

if Properties.getIsVerbose()
    if isempty(logger)
        logger=Log4jConfigurator.getLogger();
    end
    if nArgOut == 0
        fstStr = 'Computing and plotting geometric difference ';
        secStr = 'of two ellipsoids...';
        logger.info([fstStr secStr]);
    else
        logger.info('Computing geometric difference of two ellipsoids...');
    end
end

fstEllShMat = fstEll.shape;
if isdegenerate(fstEll)
    fstEllShMat = ellipsoid.regularize(fstEllShMat,fstEll.absTol);
end
secEllShMat = secEll.shape;
if isdegenerate(secEll)
    secEllShMat = ellipsoid.regularize(secEllShMat,secEll.absTol);
end
switch nDim
    case 2,
        centVec = fstEll.center - secEll.center;
        phiVec = linspace(0, 2*pi, fstEll.nPlot2dPoints);
        lMat = ellipsoid.rm_bad_directions(fstEllShMat, ...
            secEllShMat, [cos(phiVec); sin(phiVec)]);
        if size(lMat, 2) > 0
            [~, bpMat] = rho(fstEll, lMat);
            [~, subBoundPointMat] = rho(secEll, lMat);
            bpMat = bpMat - subBoundPointMat;
            boundPointMat = [bpMat bpMat(:, 1)];
        else
            boundPointMat = centVec;
        end
        if nArgOut == 0
            if Options.fill ~= 0
                fill(boundPointMat(1, :), boundPointMat(2, :), clrVec);
                hold on;
            end
            hPlot = ell_plot(boundPointMat);
            hold on;
            set(hPlot, 'Color', clrVec, 'LineWidth', 2);
            hPlot = ell_plot(centVec, '.');
            set(hPlot, 'Color', clrVec);
        end
        
    case 3,
        centVec   = fstEll.center - secEll.center;
        fstEll3dPnt = fstEll.nPlot3dPoints()/2;
        fstEll3dPntSub = fstEll3dPnt/2;
        psyVec = linspace(0, pi, fstEll3dPntSub);
        phiVec = linspace(0, 2*pi, fstEll3dPnt);
        lMat   = zeros(3,fstEll3dPnt*(fstEll3dPntSub-2));
        for iFstEll3dPnt = 2:(fstEll3dPntSub - 1)
            arrVec = cos(psyVec(iFstEll3dPnt))*ones(1, fstEll3dPnt);
            lMat(:,(fstEll3dPnt*(iFstEll3dPnt-2))+(1:fstEll3dPnt)) ...
                = [cos(phiVec)*sin(psyVec(iFstEll3dPnt)); ...
                sin(phiVec)*sin(psyVec(iFstEll3dPnt)); arrVec];
        end
        lMat = ellipsoid.rm_bad_directions(fstEllShMat,...
            secEllShMat, lMat);
        if size(lMat, 2) > 0
            [~, boundPointMat] = rho(fstEll, lMat);
            [~, subBoundPointMat] = rho(secEll, lMat);
            boundPointMat      = boundPointMat - subBoundPointMat;
        else
            boundPointMat = centVec;
        end
        if nArgOut == 0
            nBoundPonts = size(boundPointMat, 2);
            if nBoundPonts > 1
                chllMat = convhulln(boundPointMat');
                patch('Vertices', boundPointMat', 'Faces', ...
                    chllMat, 'FaceVertexCData', ...
                    clrVec(ones(1, nBoundPonts), :), ...
                    'FaceColor', 'flat', ...
                    'FaceAlpha', Options.shade(1, 1));
            else
                hPlot = ell_plot(centVec, '*');
                set(hPlot, 'Color', clrVec);
            end
            hold on;
            shading interp;
            lighting phong;
            material('metal');
            view(3);
        end
        
    otherwise,
        centVec = fstEll.center - secEll.center;
        boundPointMat(1, 1) = fstEll.center - secEll.center + ...
            sqrt(secEll.shape) - sqrt(fstEll.shape);
        boundPointMat(1, 2) = fstEll.center - secEll.center + ...
            sqrt(fstEll.shape) - sqrt(secEll.shape);
        if nArgOut == 0
            hPlot = ell_plot(boundPointMat);
            hold on;
            set(hPlot, 'Color', clrVec, 'LineWidth', 2);
            hPlot = ell_plot(centVec, '*');
            set(hPlot, 'Color', clrVec);
        end
        
end

if nArgOut == 0
    if isHld == 0
        hold off;
    end
end

if nArgOut == 1
    centVec = boundPointMat;
end
if nArgOut == 0
    clear centVec boundPointMat;
end
