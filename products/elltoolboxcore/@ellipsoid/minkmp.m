function [centVec, boundPntMat] = minkmp(fstEll, secEll, sumEllArr,varargin)
%
% MINKMP - computes and plots geometric (Minkowski) sum of the
%          geometric difference of two ellipsoids and the geometric
%          sum of n ellipsoids in 2D or 3D:
%          (E - Em) + (E1 + E2 + ... + En),
%          where E = firstEll, Em = secondEll,
%          E1, E2, ..., En - are ellipsoids in sumEllArr
%
%   MINKMP(firstEll, secondEll, sumEllArr, Options) - Computes
%       geometric sum of the geometric difference of two ellipsoids
%       firstEll - secondEll and the geometric sum of ellipsoids in
%       the ellipsoidal array sumEllArr, if
%       1 <= dimension(firstEll) = dimension(secondEll) =
%       = dimension(sumEllArr) <= 3, and plots it if no output
%       arguments are specified.
%
%   [centVec, boundPntMat] = MINKMP(firstEll, secondEll, sumEllArr) -
%       computes: (firstEll - secondEll) +
%       + (geometric sum of ellipsoids in sumEllArr).
%       Here centVec is the center, and
%       boundPntMat - array of boundary points.
%   MINKMP(firstEll, secondEll, sumEllArr) - plots
%       (firstEll - secondEll) +
%       +(geometric sum of ellipsoids in sumEllArr)
%       in default (red) color.
%   MINKMP(firstEll, secondEll, sumEllArr, Options) - plots
%       (firstEll - secondEll) +
%       +(geometric sum of ellipsoids in sumEllArr)
%       using options given in the Options structure.
%
% Input:
%   regular:
%       firstEll: ellipsoid [1, 1] - first ellipsoid. Suppose
%           nDim - space dimension, nDim = 2 or 3.
%       secondEll: ellipsoid [1, 1] - second ellipsoid
%           of the same dimention.
%       sumEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] - array of 
%           ellipsoids.
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
%   centerVecVec: double[nDim, 1] - centerVec of the resulting set.
%   boundarPointsMat: double[nDim, nBoundPoints] - set of boundary
%       points (vertices) of resulting set.
%
% Example:
% firstEllObj = ellipsoid([-2; -1], [2 -1; -1 1]);
% secEllObj = ell_unitball(2);
% ellVec = [firstEllObj secEllObj ellipsoid([-3; 1], eye(2))];
% minkmp(firstEllObj, secEllObj, ellVec);
% 
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $  
% $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

import modgen.common.throwerror;
import modgen.common.checkmultvar;
import modgen.common.checkvar;
import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;

persistent logger;

ellipsoid.checkIsMe(fstEll,'first');
ellipsoid.checkIsMe(secEll,'second');
ellipsoid.checkIsMe(sumEllArr,'third');
checkmultvar('isscalar(x1)&&isscalar(x2)',2,fstEll,secEll,...
    'errorTag','wrongInput','errorMessage',...
    'first and second arguments must be single ellipsoids.')
nDim    = dimension(fstEll);
nDimsArr = dimension(sumEllArr);
checkvar(fstEll,'~isdegenerate(x)','errorTag','wrongInput',...
    'errorMessage','minuend ellipsoid is degenerate.')
checkmultvar('(x1<4)&&all(x2(:)==x1)&&(x3==x1)',...
    3,nDim,nDimsArr,dimension(secEll),...
    'errorTag','wrongInput','errorMessage',...
    'all ellipsoids must be of the same dimension which not higher than 3.');

nArgOut=nargout;

if ~isbigger(fstEll, secEll)
    %minkmp is empty
    switch nArgOut
        case 0,
            if isempty(logger)
                logger=Log4jConfigurator.getLogger();
            end
            logger.info('The resulting set is empty.');
        case 1,
            centVec = [];
        otherwise,
            centVec = [];
            boundPntMat = [];
    end
else
    isVerb = Properties.getIsVerbose();
    if isVerb
        if isempty(logger)
            logger=Log4jConfigurator.getLogger();
        end
        if nArgOut == 0
            logger.info('Computing and plotting (E0 - E) + sum(E_i) ...');
        else
            logger.info('Computing (E0 - E) + sum(E_i) ...');
        end
    end
    
    Properties.setIsVerbose(false);
    
    centVec=NaN(nDim,1);
    switch nDim
        case 1
            [sumCentVec, sumBoundMat]=minksum(sumEllArr);
            boundPntMat=NaN(1,2);
            centVec=fstEll.centerVec-secEll.centerVec;
            boundPntMat(1)=-realsqrt(fstEll.shapeMat)+realsqrt(secEll.shapeMat)+...
                centVec+min(sumBoundMat);
            boundPntMat(2)=realsqrt(fstEll.shapeMat)-realsqrt(secEll.shapeMat)+...
                centVec+max(sumBoundMat);
            centVec=centVec+sumCentVec;
        case 2
            phiVec = linspace(0, 2*pi, fstEll.nPlot2dPoints);
            lDirsMat   = [cos(phiVec); sin(phiVec)];
        case 3
            phiGrid   = fstEll.nPlot3dPoints/2;
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
        if rank(secEll.shapeMat)==0
            tmpEll=ellipsoid(fstEll.centerVec-secEll.centerVec,...
                fstEll.shapeMat);
            [centVec, boundPntMat] = ...
                minksum([tmpEll; sumEllArr(:)]);
        else
            if isdegenerate(secEll)
                secEll.shapeMat = regularize(secEll.shapeMat);
            end
            q1Mat=fstEll.shapeMat;
            q2Mat=secEll.shapeMat;
            absTol=elltool.conf.Properties.getAbsTol();
            isGoodDirVec = ~ellipsoid.isbaddirectionmat(q1Mat, q2Mat, ...
                lDirsMat,absTol);
            if  ~any(isGoodDirVec)
                tmpEll=ellipsoid(fstEll.centerVec-secEll.centerVec, ...
                    zeros(nDim,nDim));
                [centVec, boundPntMat]=minksum([tmpEll; ...
                    sumEllArr(:)]);
            else
                [sumCentVec, sumBoundMat]=minksum(sumEllArr);
                [~, minEllPtsMat] = rho(fstEll, ...
                    lDirsMat(:,isGoodDirVec));
                [~, subEllPtsMat] = rho(secEll, ...
                    lDirsMat(:,isGoodDirVec));
                diffBoundMat =  minEllPtsMat - subEllPtsMat;
                centVec = fstEll.centerVec-...
                    secEll.centerVec+sumCentVec;
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
        if (nargin > 3) && (isstruct(varargin{1}))
            SOptions = varargin{1};
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
                plot(sumEllArr, 'b',SOptionForPlot);
            end
            try
                plot(secEll, 'k',SOptionForPlot);
            end
            try
                plot(fstEll, 'g',SOptionForPlot);
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
