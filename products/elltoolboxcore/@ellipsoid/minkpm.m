function [centVec, boundPointMat] = minkpm(varargin)
%
% MINKPM - computes and plots geometric (Minkowski) difference
%          of the geometric sum of ellipsoids and a single ellipsoid
%          in 2D or 3D: (E1 + E2 + ... + En) - E,
%          where E = inpEll,
%          E1, E2, ... En - are ellipsoids in inpEllMat.
%
%   MINKPM(inpEllMat, inpEll, OPTIONS)  Computes geometric difference
%       of the geometric sum of ellipsoids in inpEllMat and
%       ellipsoid inpEll, if
%       1 <= dimension(inpEllMat) = dimension(inpEll) <= 3,
%       and plots it if no output arguments are specified.
%
%   [centVec, boundPointMat] = MINKPM(inpEllMat, inpEll) - pomputes
%       (geometric sum of ellipsoids in inpEllMat) - inpEll.
%       Here centVec is the center, and boundPointMat - array
%       of boundary points.
%   MINKPM(inpEllMat, inpEll) - plots (geometric sum of ellipsoids
%       in inpEllMat) - inpEll in default (red) color.
%   MINKPM(inpEllMat, inpEll, Options) - plots
%       (geometric sum of ellipsoids in inpEllMat) - inpEll using
%       options given in the Options structure.
%
% Input:
%   regular:
%       inpEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids
%           of the same dimentions 2D or 3D.
%       inpEll: ellipsoid [1, 1] - ellipsoid of the same
%           dimention 2D or 3D.
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
%    centVec: double[nDim, 1]/double[0, 0] - center of the resulting set.
%       centerVec may be empty.
%    boundPointMat: double[nDim, ]/double[0, 0] - set of boundary
%       points (vertices) of resulting set. boundPointMat may be empty.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import modgen.common.throwerror;

if nargin < 2
    throwerror('wrongInput', ...
        'MINKPM: first and second arguments must be ellipsoids.');
end

inpEllMat = varargin{1};
inpEll = varargin{2};

if ~(isa(inpEllMat, 'ellipsoid')) || ~(isa(inpEll, 'ellipsoid'))
    throwerror('wrongInput', ...
        'MINKPM: first and second arguments must be ellipsoids.');
end

[mRowsInpEll, nColsInpEll] = size(inpEll);
if (mRowsInpEll ~= 1) || (nColsInpEll ~= 1)
    throwerror('wrongInput', ...
        'MINKPM: second argument must be single ellipsoid.');
end

nDimsMat = dimension(inpEllMat);
minEllDim = min(min(nDimsMat));
maxEllDim = max(max(nDimsMat));
nDimsInpEll = dimension(inpEll);
if (minEllDim ~= maxEllDim) || (maxEllDim ~= nDimsInpEll)
    throwerror('wrongSizes', ...
        'MINKPM: all ellipsoids must be of the same dimension.');
end
if nDimsInpEll > 3
    throwerror('wrongSizes', ...
        'MINKPM: ellipsoid dimension must be not higher than 3.');
end

switch nDimsInpEll
    case 2,
        nPlot2dPointsInpEllMat = inpEllMat.nPlot2dPoints;
        nPlot2dPoints = max(nPlot2dPointsInpEllMat(:));
        phiVec = linspace(0, 2*pi, nPlot2dPoints);
        dirMat = [cos(phiVec); sin(phiVec)];
        
    case 3,
        nPlot3dPnt = inpEllMat.nPlot3dPoints/2;
        nPlot3dPntSub = nPlot3dPnt/2;
        psyVec = linspace(0, pi, nPlot3dPntSub);
        phiVec = linspace(0, 2*pi, nPlot3dPnt);
        dirMat   = [];
        for iCol = 2:(nPlot3dPntSub - 1)
            subDirVec = cos(psyVec(iCol))*ones(1, nPlot3dPnt);
            dirMat   = [dirMat [cos(phiVec)*sin(psyVec(iCol)); ...
                sin(phiVec)*sin(psyVec(iCol)); subDirVec]];
        end
        
    otherwise,
        dirMat = [-1 1];
        
end

isVrb = Properties.getIsVerbose();
Properties.setIsVerbose(false);
extApproxEllVec = minksum_ea(inpEllMat, dirMat);
Properties.setIsVerbose(isVrb);

if min(extApproxEllVec > inpEll) == 0
    switch nargout
        case 0,
            fprintf('The resulting set is empty.');
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
%
if nargin > 2
    if isstruct(varargin{3})
        Options = varargin{3};
    else
        Options = [];
    end
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

if nargout == 0
    ih = ishold;
end

if (Options.show_all ~= 0) && (nargout == 0)
    plot(inpEllMat, 'b', inpEll, 'k');
    hold on;
    if Options.newfigure ~= 0
        figure;
    else
        newplot;
    end
end

if Properties.getIsVerbose()
    if nargout == 0
        fprintf('Computing and plotting (sum(E_i) - E) ...\n');
    else
        fprintf('Computing (sum(E_i) - E) ...\n');
    end
end

centVec= extApproxEllVec(1).center - inpEll.center;
boundPointMat=[];
nCols = size(dirMat, 2);
Properties.setIsVerbose(false);
%
switch nDimsInpEll
    case 2,
        extApprEllVec(nCols) = ellipsoid();
        directionMat = zeros(nDimsInpEll, nCols);
        for iCol = 1:nCols
            dirVec = dirMat(:, iCol);
            extApprEll = extApproxEllVec(iCol);
            if ~isbaddirection(extApprEll, inpEll, dirVec)
                extApprEllVec(iCol)=minkdiff_ea(extApprEll, ...
                    inpEll, dirVec);
                directionMat(:,iCol)=dirVec;
            end
        end
        nExtApprEllVec = size(extApprEllVec, 2);
        mValVec=zeros(1, nCols);
        for jExtApprEll = 1:nExtApprEllVec
            extApprEllShMat = extApprEllVec(jExtApprEll).shape;
            invShMat = ell_inv(extApprEllShMat);
            for iCol = 1:nCols
                dirVec = dirMat(:, iCol);
                val = dirVec' * invShMat * dirVec;
                if val > mValVec(iCol)
                    mValVec(iCol) = val;
                end
            end
        end
        isPosVec=mValVec>0;
        nPos=sum(isPosVec);
        mValMultVec = 1./sqrt(mValVec(isPosVec));
        boundPointMat=dirMat(:,isPosVec).* ...
            mValMultVec(ones(1,nDimsInpEll),:)+centVec(:,ones(1,nPos));
        if isempty(boundPointMat)
            boundPointMat = centVec;
        end
        boundPointMat = [boundPointMat boundPointMat(:, 1)];
        if nargout == 0
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
        for iCol = 1:nCols
            dirVec = dirMat(:, iCol);
            extApprEll = extApproxEllVec(iCol);
            if ~isbaddirection(extApprEll, inpEll, dirVec)
                intApprEll = minksum_ia(inpEllMat, dirVec);
                if isbigger(intApprEll, inpEll)
                    if ~isbaddirection(intApprEll, inpEll, dirVec)
                        [~, boundPointSubMat] = ...
                            rho(minkdiff_ea(extApprEll, inpEll, ...
                            dirVec), dirVec);
                        boundPointMat = [boundPointMat boundPointSubMat];
                    end
                end
            end
        end
        if isempty(boundPointMat)
            boundPointMat = centVec;
        end
        if nargout == 0
            nBoundPoints = size(boundPointMat, 2);
            if nBoundPoints > 1
                chll = convhulln(boundPointMat');
                patch('Vertices', boundPointMat', 'Faces', chll, ...
                    'FaceVertexCData', clrVec(ones(1, nBoundPoints), :),...
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
        boundPointMat = [centVec centVec];
        boundPointMat(1, 1) = extApproxEllVec(1).center - ...
            inpEll.center + sqrt(inpEll.shape) - ...
            sqrt(extApproxEllVec(1).shape);
        boundPointMat(1, 2) = extApproxEllVec(1).center - ...
            inpEll.center + sqrt(extApproxEllVec(1).shape) - ...
            sqrt(inpEll.shape);
        if nargout == 0
            hPlot = ell_plot(boundPointMat);
            hold on;
            set(hPlot, 'Color', clrVec, 'LineWidth', 2);
            hPlot = ell_plot(centVec, '*');
            set(hPlot, 'Color', clrVec);
        end
        
end

Properties.setIsVerbose(isVrb);

if nargout == 0
    if ih == 0
        hold off;
    end
end

if nargout == 1
    centVec = boundPointMat;
end
if nargout == 0
    clear centVec  boundPointMat;
end
