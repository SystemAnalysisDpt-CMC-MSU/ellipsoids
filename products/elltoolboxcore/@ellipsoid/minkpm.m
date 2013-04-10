function [centVec, boundPointMat] = minkpm(inpEllArr, inpEll, varargin)
%
% MINKPM - computes and plots geometric (Minkowski) difference
%          of the geometric sum of ellipsoids and a single ellipsoid
%          in 2D or 3D: (E1 + E2 + ... + En) - E,
%          where E = inpEll,
%          E1, E2, ... En - are ellipsoids in inpEllArr.
%
%   MINKPM(inpEllArr, inpEll, OPTIONS)  Computes geometric difference
%       of the geometric sum of ellipsoids in inpEllArr and
%       ellipsoid inpEll, if
%       1 <= dimension(inpEllArr) = dimension(inpArr) <= 3,
%       and plots it if no output arguments are specified.
%
%   [centVec, boundPointMat] = MINKPM(inpEllArr, inpEll) - computes
%       (geometric sum of ellipsoids in inpEllArr) - inpEll.
%       Here centVec is the center, and boundPointMat - array
%       of boundary points.
%   MINKPM(inpEllArr, inpEll) - plots (geometric sum of ellipsoids
%       in inpEllArr) - inpEll in default (red) color.
%   MINKPM(inpEllArr, inpEll, Options) - plots
%       (geometric sum of ellipsoids in inpEllArr) - inpEll using
%       options given in the Options structure.
%
% Input:
%   regular:
%       inpEllArr: ellipsoid [nDims1, nDims2,...,nDimsN] - array of 
%           ellipsoids of the same dimentions 2D or 3D.
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
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

import elltool.conf.Properties;
import modgen.common.throwerror;
import modgen.common.checkvar;
import modgen.common.checkmultvar;
import elltool.logging.Log4jConfigurator;

persistent logger;

ellipsoid.checkIsMe(inpEllArr,'first');
ellipsoid.checkIsMe(inpEll,'second');
checkvar(inpEll,'isscalar(x)','errorTag','wrongInput',...
    'errorMessage','second argument must be single ellipsoid.');

nDimsArr = dimension(inpEllArr);
nDims = dimension(inpEll);
checkmultvar('all(x1(:)==x2)',2,nDimsArr,nDims,...
    'errorTag','wrongSizes','errorMessage',...
    'all ellipsoids must be of the same dimension which not higher than 3.');

switch nDims
    case 2,
        nPlot2dPointsInpEllArr = inpEllArr.nPlot2dPoints;
        nPlot2dPoints = max(nPlot2dPointsInpEllArr(:));
        phiVec = linspace(0, 2*pi, nPlot2dPoints);
        dirMat = [cos(phiVec); sin(phiVec)];
        
    case 3,
        nPlot3dPnt = inpEllArr.nPlot3dPoints/2;
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
extApproxEllVec = minksum_ea(inpEllArr, dirMat);
absTolVal=min(min(extApproxEllVec.getAbsTol()),inpEll.absTol); 
Properties.setIsVerbose(isVrb);

if min(extApproxEllVec > inpEll) == 0
    switch nargout
        case 0,
            if isempty(logger)
                logger=Log4jConfigurator.getLogger();
            end
            logger.info('The resulting set is empty.');
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

nArgOut = nargout;
if nArgOut == 0
    ih = ishold;
end

if (Options.show_all ~= 0) && (nArgOut == 0)
    plot(inpEllArr, 'b', inpEll, 'k');
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
        logger.info('Computing and plotting (sum(E_i) - E) ...');
    else
        logger.info('Computing (sum(E_i) - E) ...');
    end
end

centVec= extApproxEllVec(1).center - inpEll.center;
boundPointMat=[];
nCols = size(dirMat, 2);
Properties.setIsVerbose(false);
%
switch nDims
    case 2
        extApprEllVec(1,nCols) = ellipsoid();
        arrayfun(@(x) fCase2extAppr(x),1:nCols);
        
        mValVec=zeros(1, nCols);
        arrayfun(@(x) fCase2(x),find(~isempty(extApprEllVec)));
        
        isPosVec=mValVec>0;
        nPos=sum(isPosVec);
        mValMultVec = 1./sqrt(mValVec(isPosVec));
        bpMat=dirMat(:,isPosVec).* ...
            mValMultVec(ones(1,nDims),:)+centVec(:,ones(1,nPos));
        if isempty(bpMat)
            bpMat = centVec;
        end
        boundPointMat = [bpMat bpMat(:, 1)];
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
        
    case 3
        isGoodDir = false(1,nCols);
        arrayfun(@(x) fFindGoodDir(x), 1:nCols);
        if any(isGoodDir)
            nGoodDirs = sum(isGoodDir);
            goodIndexVec = find(isGoodDir);
            boundPointMat = zeros(nDims, nGoodDirs);
            arrayfun(@(x)  fCase3(x), 1:nGoodDirs);
        else
            boundPointMat = centVec;
        end
        if nArgOut == 0
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
        if nArgOut == 0
            hPlot = ell_plot(boundPointMat);
            hold on;
            set(hPlot, 'Color', clrVec, 'LineWidth', 2);
            hPlot = ell_plot(centVec, '*');
            set(hPlot, 'Color', clrVec);
        end
        
end

Properties.setIsVerbose(isVrb);

if nArgOut == 0
    if ih == 0
        hold off;
    end
end

if nArgOut == 1
    centVec = boundPointMat;
end
if nArgOut == 0
    clear centVec  boundPointMat;
end
    function fCase2extAppr(index)
        dirVec = dirMat(:, index);
        isGoodDirVec =~isbaddirection(extApproxEllVec(index), inpEll,...
            dirVec,absTolVal);
        if any(isGoodDirVec)
            extApprEllVec(index)=minkdiff_ea(extApproxEllVec(index), ...
                inpEll, dirMat(:,index));
        end
    end
    function fCase2(index)
        eaShMat = extApprEllVec(index).shape;
        invShMat = ell_inv(eaShMat);
        valVec = sum((invShMat*dirMat).*dirMat,1);
        mValVec = max(valVec, mValVec);
    end
    function fFindGoodDir(index)
        dirVec = dirMat(:, index);
        if ~isbaddirection(extApproxEllVec(index), inpEll, dirVec)
            intApprEll = minksum_ia(inpEllArr, dirVec);
            if ~isbaddirection(intApprEll, inpEll, dirVec)
                isGoodDir(index) = true;
            end
        end
    end
    function fCase3(iCount)
        index = goodIndexVec(iCount);
        dirVec = dirMat(:, index);
        [~, boundPointSubVec] = ...
            rho(minkdiff_ea(extApproxEllVec(index), inpEll, ...
            dirVec), dirVec);
        boundPointMat(:,iCount) = boundPointSubVec;
    end
end