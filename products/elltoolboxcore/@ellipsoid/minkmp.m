function [centVec, boundPntMat] = minkmp(varargin)
%
% MINKMP - computes and plots geometric (Minkowski) sum of the
%          geometric difference of two ellipsoids and the geometric
%          sum of n ellipsoids in 2D or 3D:
%          (E - Em) + (E1 + E2 + ... + En),
%          where E = firstEll, Em = secondEll,
%          E1, E2, ..., En - are ellipsoids in sumEllMat
%
%   MINKMP(firstEll, secondEll, sumEllMat, Options) - Computes
%       geometric sum of the geometric difference of two ellipsoids
%       firstEll - secondEll and the geometric sum of ellipsoids in
%       the ellipsoidal array sumEllMat, if
%       1 <= dimension(firstEll) = dimension(secondEll) =
%       = dimension(sumEllMat) <= 3, and plots it if no output
%       arguments are specified.
%
%   [centVec, boundPntMat] = MINKMP(firstEll, secondEll, sumEllMat) -
%       computes: (firstEll - secondEll) +
%       + (geometric sum of ellipsoids in sumEllMat).
%       Here centVec is the center, and
%       boundPntMat - array of boundary points.
%   MINKMP(firstEll, secondEll, sumEllMat) - plots
%       (firstEll - secondEll) +
%       +(geometric sum of ellipsoids in sumEllMat)
%       in default (red) color.
%   MINKMP(firstEll, secondEll, sumEllMat, Options) - plots
%       (firstEll - secondEll) +
%       +(geometric sum of ellipsoids in sumEllMat)
%       using options given in the Options structure.
%
% Input:
%   regular:
%       firstEll: ellipsoid [1, 1] - first ellipsoid. Suppose
%           nDim - space dimension, nDim = 2 or 3.
%       secondEll: ellipsoid [1, 1] - second ellipsoid
%           of the same dimention.
%       sumEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.
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
%   centerVec: double[nDim, 1] - center of the resulting set.
%   boundarPointsMat: double[nDim, nBoundPoints] - set of boundary
%       points (vertices) of resulting set.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Rustam Guliev <glvrst@gmail.com> $  $Date: 23-10-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $

import modgen.common.throwerror;
import elltool.conf.Properties;

if nargin < 3
    throwerror('wrongInput', ...
        'MINKMP: first, second and third arguments must be ellipsoids.');
end

firstEll = varargin{1};
secondEll = varargin{2};
sumEllMat = varargin{3};

if ~(isa(firstEll, 'ellipsoid')) || ~(isa(secondEll, 'ellipsoid')) ...
        || ~(isa(sumEllMat, 'ellipsoid'))
    throwerror('wrongInput', ...
        'MINKMP: first, second and third arguments must be ellipsoids.');
end

if (~isscalar(firstEll)) || (~isscalar(secondEll))
    throwerror('wrongInput', ...
        'MINKMP: first and second arguments must be single ellipsoid.');
end

nDim    = dimension(firstEll);
nDimsMat = dimension(sumEllMat);

if (~all(nDimsMat(:)==nDim)) || (dimension(secondEll) ~= nDim)
    throwerror('wrongInput', ...
        'MINKMP: all ellipsoids must be of the same dimension.');
end

if nDim > 3
    throwerror('wrongInput', ...
        'MINKMP: ellipsoid dimension must be not higher than 3.');
end

if isdegenerate(firstEll)
    throwerror('wrongInput', ...
        'MINKMP: minuend ellipsoid is degenerate.');
end

nArgOut=nargout;

if ~isbigger(firstEll, secondEll)
    %minkmp is empty
    switch nArgOut
        case 0,
            fprintf('The resulting set is empty.');
        case 1,
            centVec = [];
        otherwise,
            centVec = [];
            boundPntMat = [];
    end
else
    isVerb = Properties.getIsVerbose();
    if isVerb
        if nArgOut == 0
            fprintf('Computing and plotting (E0 - E) + sum(E_i) ...\n');
        else
            fprintf('Computing (E0 - E) + sum(E_i) ...\n');
        end
    end
    
    Properties.setIsVerbose(false);
    
    centVec=NaN(nDim,1);
    switch nDim
        case 1
            [sumCentVec, sumBoundMat]=minksum(sumEllMat);
            boundPntMat=NaN(1,2);
            centVec=firstEll.center-secondEll.center;
            boundPntMat(1)=-sqrt(firstEll.shape)+sqrt(secondEll.shape)+...
                centVec+min(sumBoundMat);
            boundPntMat(2)=sqrt(firstEll.shape)-sqrt(secondEll.shape)+...
                centVec+max(sumBoundMat);
            centVec=centVec+sumCentVec;
        case 2
            phiVec = linspace(0, 2*pi, firstEll.nPlot2dPoints);
            lDirsMat   = [cos(phiVec); sin(phiVec)];
        case 3
            phiGrid   = firstEll.nPlot3dPoints/2;
            psyGrid   = phiGrid/2;
            psyVec = linspace(0, pi, psyGrid);
            phiVec = linspace(0, 2*pi, phiGrid);
            lDirsMat   = zeros(3,phiGrid*(psyGrid-2));
            for i = 2:(psyGrid - 1)
                arrVec = cos(psyVec(i))*ones(1, phiGrid);
                lDirsMat(:,(i-2)*phiGrid+(1:phiGrid)) = ...
                    [cos(phiVec)*sin(psyVec(i)); ...
                    sin(phiVec)*sin(psyVec(i)); arrVec];
            end
    end
    
    if nDim>1
        if rank(secondEll.shape)==0
            tmpEll=ellipsoid(firstEll.center-secondEll.center,...
                firstEll.shape);
            [centVec, boundPntMat] = ...
                minksum([tmpEll; sumEllMat(:)]);
        else
            if isdegenerate(secondEll)
                secondEll.shape = regularize(secondEll.shape);
            end
            q1Mat=firstEll.shape;
            q2Mat=secondEll.shape;
            isGoodDirVec = ~ellipsoid.isbaddirectionmat(q1Mat, q2Mat, ...
                lDirsMat);
            if  ~any(isGoodDirVec)
                tmpEll=ellipsoid(firstEll.center-secondEll.center, ...
                    zeros(nDim,nDim));
                [centVec, boundPntMat]=minksum([tmpEll; ...
                    sumEllMat(:)]);
            else
                [sumCentVec, sumBoundMat]=minksum(sumEllMat);
                [~, minEllPtsMat] = rho(firstEll, ...
                    lDirsMat(:,isGoodDirVec));
                [~, subEllPtsMat] = rho(secondEll, ...
                    lDirsMat(:,isGoodDirVec));
                diffBoundMat =  minEllPtsMat - subEllPtsMat;
                centVec = firstEll.center-...
                    secondEll.center+sumCentVec;
                boundPntMat = diffBoundMat + ...
                    sumBoundMat(:,isGoodDirVec);
            end
        end
    end
    
    if nDim==2
        boundPntMat=[boundPntMat boundPntMat(:,1)];
    end
    %===================================================================
    if (nArgOut ==1)
        centVec = boundPntMat;
        clear secOutArgMat;
    elseif (nArgOut == 0)
        %Read parameters
        SOptions = [];
        if (nargin > 3) && (isstruct(varargin{4}))
            SOptions = varargin{4};
        end
        isHolded=ishold;
        if ~isfield(SOptions, 'newfigure')
            SOptions.newfigure = 0;
        end
        if ~isfield(SOptions, 'show_all')
            SOptions.show_all = 0;
        end
        if ( ~isfield(SOptions, 'fill') )
            SOptions.fill = 0;
        end
        if ~isfield(SOptions, 'newfigure')
            SOptions.newfigure = 0;
        end
        shade=0.6;
        if isfield(SOptions, 'shade')
            shade = SOptions.shade(1, 1);
        end
        colorVec=[1,0,0];%red
        if isfield(SOptions, 'color')
            colorVec = SOptions.color;
        end
        grd=1;
        if isfield(SOptions, 'grid')
            grd = SOptions.grid;
        end
        %Starting plot
        if (SOptions.newfigure ~= 0)
            figure;
        else
            newplot;
        end
        title('Minkmp result','interpreter','latex','FontSize',12);
        hold on;
        if grd
            grid on;
        end
        if (SOptions.show_all)
            SOptionForPlot.width=2;
            try
                plot(sumEllMat, 'b',SOptionForPlot);
            end
            try
                plot(secondEll, 'k',SOptionForPlot);
            end
            try
                plot(firstEll, 'g',SOptionForPlot);
            end
        end
        switch nDim
            case 1
                SEllPlot = ell_plot(boundPntMat);
                set(SEllPlot, 'Color', colorVec, 'LineWidth', 2);
                SEllPlot = ell_plot(centVec, '*');
                set(SEllPlot, 'Color', colorVec);
                xlabel('$x$','interpreter','latex','FontSize',14);
            case 2
                if SOptions.fill
                    fill(boundPntMat(1,:),boundPntMat(2,:),colorVec);
                else
                    SEllPlot = ell_plot(boundPntMat);
                    set(SEllPlot, 'Color', colorVec, 'LineWidth', 2);
                end
                SEllPlot = ell_plot(centVec, '.');
                set(SEllPlot, 'Color', colorVec);
                xlabel('$x$','interpreter','latex','FontSize',14);
                ylabel('$y$','interpreter','latex','FontSize',14);
            case 3
                if size(boundPntMat, 2) > 1
                    ConvHullnMat = convhulln(boundPntMat');
                    camlight;  camlight('headlight');
                    shading interp; material('metal');
                    patch('Vertices', boundPntMat', 'Faces', ...
                        ConvHullnMat, 'FaceVertexCData', ...
                        colorVec(ones(1, size(boundPntMat, 2)), :), ...
                        'FaceColor', 'flat', 'FaceAlpha', shade, ...
                        'FaceLighting','phong','EdgeColor','none');
                    %lighting phong;
                else
                    SEllPlot = ell_plot(centVec, '*');
                    set(SEllPlot, 'Color', clr);
                end
                
                view(3);
                xlabel('$x$','interpreter','latex','FontSize',14);
                ylabel('$y$','interpreter','latex','FontSize',14);
                zlabel('$z$','interpreter','latex','FontSize',14);
                rotate3d on;
                
        end
        if ~isHolded
            hold off;
        end
        clear firOutArgMat secOutArgMat;
    end
    Properties.setIsVerbose(false);
end
