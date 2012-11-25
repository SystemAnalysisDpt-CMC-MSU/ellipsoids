function [firOutArgMat, secOutArgMat] = minkmp(varargin)
%
% MINKMP - computes and plots geometric (Minkowski) sum of the geometric difference
%          of two ellipsoids and the geometric sum of n ellipsoids in 2D or 3D:
%
%          (E0 - E) + (E1 + E2 + ... + En)
%
%
% Description:
% ------------
%
% MINKMP(E0, E, EE, OPTIONS)  Computes geometric sum of the geometric difference
%                             of two ellipsoids E0 - E and the geometric sum of
%                             ellipsoids in the ellipsoidal array EE, if
%                             1 <= dimension(E0) = dimension(E) = dimension(EE) <= 3,
%                             and plots it if no output arguments are specified.
%
%    [y, Y] = MINKMP(E0, E, EE)  Computes (E0 - E) + (geometric sum of ellipsoids in EE).
%                                Here y is the center, and Y - array of boundary points.
%             MINKMP(E0, E, EE)  Plots (E0 - E) + (geometric sum of ellipsoids in EE)
%                                in default (red) color.
%    MINKMP(E0, E, EE, Options)  Plots (E0 - E) + (geometric sum of ellipsoids in EE)
%                                using options given in the Options structure.
%
% Options.show_all     - if 1, displays also ellipsoids
% Options.newfigure    - if 1, each plot command will open a new figure window.
% Options.fill         - if 1, the resulting set in 2D will be filled with color.
% Options.color        - sets default colors in the form [x y z].
% Options.shade = 0-1  - level of transparency (0 - transparent, 1 - opaque).
% Options.grid         - if 1, grid on.
%
% Output:
% -------
%
%    firOutArgMat - center of the resulting set.
%    secOutArgMat - set of boundary points (vertices) of resulting set.
% 
% $Author: Rustam Guliev, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 23-October-2012, <glvrst@gmail.com>$
%


import modgen.common.throwerror;
import elltool.conf.Properties;

if nargin < 3
    throwerror('wrongInput','MINKMP: first, second and third arguments must be ellipsoids.');
end

minEll = varargin{1};
subEll = varargin{2};
sumEllMat = varargin{3};

if ~(isa(minEll, 'ellipsoid')) || ~(isa(subEll, 'ellipsoid')) || ~(isa(sumEllMat, 'ellipsoid'))
    throwerror('wrongInput','MINKMP: first, second and third arguments must be ellipsoids.');
end

if (~isscalar(minEll)) || (~isscalar(subEll))
    throwerror('wrongInput','MINKMP: first and second arguments must be single ellipsoid.');
end

nDim    = dimension(minEll);
nDimsVec = dimension(sumEllMat);

if (~all(nDimsVec(:)==nDim)) || (dimension(subEll) ~= nDim)
    throwerror('wrongInput','MINKMP: all ellipsoids must be of the same dimension.');
end

if nDim > 3
    throwerror('wrongInput','MINKMP: ellipsoid dimension must be not higher than 3.');
end

if isdegenerate(minEll)
    throwerror('wrongInput','MINKMP: minuend ellipsoid is degenerate.');
end
  
nArgOut=nargout;
  
if ~isbigger(minEll, subEll)
    %minkmp is empty
    switch nArgOut
        case 0,
            fprintf('The resulting set is empty.');
        case 1,
            firOutArgMat = [];
        otherwise,
            firOutArgMat = [];
            secOutArgMat = [];
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
    
    firOutArgMat=NaN(nDim,1);
    switch nDim
        case 1
            [sumCentVec, sumBoundMat]=minksum(sumEllMat);
            secOutArgMat=NaN(1,2);
            firOutArgMat=minEll.center-subEll.center;
            secOutArgMat(1)=-sqrt(minEll.shape)+sqrt(subEll.shape)+...
                firOutArgMat+min(sumBoundMat);
            secOutArgMat(2)=sqrt(minEll.shape)-sqrt(subEll.shape)+...
                firOutArgMat+max(sumBoundMat);
            firOutArgMat=firOutArgMat+sumCentVec;
        case 2
            phi = linspace(0, 2*pi, minEll.nPlot2dPoints);
            lDirsMat   = [cos(phi); sin(phi)];
        case 3
            phiGrid   = minEll.nPlot3dPoints/2;
            psyGrid   = phiGrid/2;
            psy = linspace(0, pi, psyGrid);
            phi = linspace(0, 2*pi, phiGrid);
            lDirsMat   = zeros(3,phiGrid*(psyGrid-2));
            for i = 2:(psyGrid - 1)
                arr = cos(psy(i))*ones(1, phiGrid);
                lDirsMat(:,(i-2)*phiGrid+(1:phiGrid))   = [cos(phi)*sin(psy(i)); sin(phi)*sin(psy(i)); arr];
            end
    end
    
    if nDim>1
        if rank(subEll.shape)==0
            tmpEll=ellipsoid(minEll.center-subEll.center,minEll.shape);
            [firOutArgMat, secOutArgMat]=minksum([tmpEll; sumEllMat(:)]);
        else
            if isdegenerate(subEll)
                subEll.shape = regularize(subEll.shape);
            end
            q1Mat=minEll.shape;
            q2Mat=subEll.shape;
            isGoodDirVec = ~ellipsoid.isbaddirectionmat(q1Mat, q2Mat, lDirsMat);
            if  ~any(isGoodDirVec)
                tmpEll=ellipsoid(minEll.center-subEll.center,zeros(nDim,nDim));
                [firOutArgMat, secOutArgMat]=minksum([tmpEll; sumEllMat(:)]);
            else
                [sumCentVec, sumBoundMat]=minksum(sumEllMat);
                [~, minEllPtsMat] = rho(minEll, lDirsMat(:,isGoodDirVec));
                [~, subEllPtsMat] = rho(subEll, lDirsMat(:,isGoodDirVec));
                diffBoundMat =  minEllPtsMat - subEllPtsMat;
                firOutArgMat = minEll.center-subEll.center+sumCentVec;
                secOutArgMat = diffBoundMat+ sumBoundMat(:,isGoodDirVec);
            end
        end
    end
    
    if nDim==2
        secOutArgMat=[secOutArgMat secOutArgMat(:,1)];
    end
%=======================================================================   
    if (nArgOut ==1)
        firOutArgMat = secOutArgMat;
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
                plot(subEll, 'k',SOptionForPlot);
            end
            try
                plot(minEll, 'g',SOptionForPlot);
            end
        end
        switch nDim
            case 1
                SEllPlot = ell_plot(secOutArgMat);
                set(SEllPlot, 'Color', colorVec, 'LineWidth', 2);
                SEllPlot = ell_plot(firOutArgMat, '*');
                set(SEllPlot, 'Color', colorVec);
                xlabel('$x$','interpreter','latex','FontSize',14);
            case 2
                if SOptions.fill
                    fill(secOutArgMat(1,:),secOutArgMat(2,:),colorVec);
                else
                   SEllPlot = ell_plot(secOutArgMat);
                    set(SEllPlot, 'Color', colorVec, 'LineWidth', 2);
                end
                SEllPlot = ell_plot(firOutArgMat, '.');
                set(SEllPlot, 'Color', colorVec); 
                xlabel('$x$','interpreter','latex','FontSize',14);
                ylabel('$y$','interpreter','latex','FontSize',14);
            case 3
                if size(secOutArgMat, 2) > 1
                    ConvHullnMat = convhulln(secOutArgMat');
                    camlight;  camlight('headlight');
                    shading interp; material('metal');
                    patch('Vertices', secOutArgMat', 'Faces', ConvHullnMat, ...
                    'FaceVertexCData', colorVec(ones(1, size(secOutArgMat, 2)), :), 'FaceColor', 'flat', ...
                    'FaceAlpha', shade,'FaceLighting','phong','EdgeColor','none');
                    %lighting phong;
                else
                    SEllPlot = ell_plot(firOutArgMat, '*');
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
end
