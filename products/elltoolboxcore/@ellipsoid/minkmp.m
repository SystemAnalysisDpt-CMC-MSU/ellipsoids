function varargout = minkmp(varargin)
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
%   MINKMP(firstEll, secondEll, sumEllMat, Options) - plots
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
%   centerVec: double[nDim, 1] - center of the resulting set.
%   boundarPointsMat: double[nDim, nBoundPoints] - set of boundary
%       points (vertices) of resulting set.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Nov-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

import elltool.plot.plotgeombodyarr;
import modgen.common.throwerror;
[reg,~,~,~,~,~,~,~,~,~]=...
    modgen.common.parseparext(varargin,...
    {'relDataPlotter','newFigure','fill','lineWidth','color','shade','priorHold','postHold'});
ellsArr = cellfun(@(x)getEllArr(x),reg,'UniformOutput', false);
ellsArr = vertcat(ellsArr{:});
if numel(ellsArr) == 1
    if (nargout == 1)||(nargout == 0)
        plObj = plot(varargin{:});
        varargout(1) = {plObj};
    else
        [centerVector, boundPntMat] = ellsArr.double();
        varargout(1) = {centerVector};
        varargout(2) = {boundPntMat};
    end
elseif numel(ellsArr) == 2
    if (nargout == 1)||(nargout == 0)
        plObj = minkdiff(varargin{:});
        varargout(1) = {plObj};
    else
        [centerVector, boundPntMat] = minkdiff(ellsArr(1),ellsArr(2));
        varargout(1) = {centerVector};
        varargout(2) = {boundPntMat};
    end
else
    if (nargout == 1)||(nargout == 0)
        [reg,~,isShowAll]=...
            modgen.common.parseparext(varargin,...
            {'showAll' ;...
            false;
            @(x)isa(x,'logical')});
        [plObj,nDim,isHold]= plotgeombodyarr('ellipsoid',@fCalcBodyTriArr,@patch,reg{:});
        if (nDim < 3)
            [reg,~,~]=...
                modgen.common.parseparext(reg,...
                {'relDataPlotter';...
                [],;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
                });
            plObj= plotgeombodyarr('ellipsoid',@fCalcCenterTriArr,...
                @(varargin)patch(varargin{:},'marker','*'),reg{:},'relDataPlotter',plObj, 'priorHold',true,'postHold',isHold);
        end
        if isShowAll
            [reg,~,~,~,~,~,~,~,~,~]=...
                modgen.common.parseparext(reg,...
                {'relDataPlotter','newFigure','fill','lineWidth','color','shade','priorHold','postHold'});
            ellsArr = cellfun(@(x)getEllArr(x),reg,'UniformOutput', false);
            ellsArr = vertcat(ellsArr{:});
            ellsArr.plot('color', [0 0 0],'relDataPlotter',plObj);
        end
        varargout = {plObj};
    else
        ellsArrDims = dimension(ellsArr);
        mDim    = min(ellsArrDims);
        nDim    = max(ellsArrDims);
        if mDim ~= nDim
            throwerror('dimMismatch', ...
                'Objects must have the same dimensions.');
        end
        xDifSumCMat = fCalcBodyTriArr(ellsArr);
        qDifSumCMat = fCalcCenterTriArr(ellsArr);
        varargout(1) = qDifSumCMat;
        varargout(2) = xDifSumCMat;
    end
end
    function [qSumDifCMat,fCMat] = fCalcCenterTriArr(ellsArr)
        nDim = dimension(ellsArr(1));
        if nDim == 1
            [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr);
        end        
        fstEll = ellsArr(1);
        secEll = ellsArr(2);
        arrEll = ellsArr(3:end);
        [centerDif,~] = minkdiff(fstEll,secEll);
        [centerSum,~] = minksum(arrEll);
        if isempty(centerDif)
            qSumDifCMat = {centerSum};
        else
            qSumDifCMat = {centerSum + centerDif};
        end
        fCMat = {[1 1]};        
    end
    function [xSumDifMat,fMat] = fCalcBodyTriArr(ellsArr)
        nDim = dimension(ellsArr(1));
        if nDim == 1
            [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr);
        end
        fstEll = ellsArr(1);
        secEll = ellsArr(2);
        switch nDim
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
        if isdegenerate(secEll)
            secEll.shape = regularize(secEll.shape);
        end
        q1Mat=fstEll.shape;
        q2Mat=secEll.shape;
        isGoodDirVec = ~ellipsoid.isbaddirectionmat(q1Mat, q2Mat, ...
            lDirsMat);
        if  ~any(isGoodDirVec)
            tmpEll=ellipsoid(fstEll.center-secEll.center, ...
                zeros(nDim,nDim));
            [~, boundPointMat]=minksum([tmpEll; ...
                ellsArr(3:end)]);
        else
            xCMat = arrayfun(@(x) fCalcSumTri(x, nDim), ellsArr(3:end), ...
                'UniformOutput', false);
            xSumMat = 0;
            for iXMat=1:numel(xCMat)
                xSumMat = xSumMat + xCMat{iXMat};
            end
            [~, minEllPtsMat] = rho(fstEll, ...
                lDirsMat(:,isGoodDirVec));
            [~, subEllPtsMat] = rho(secEll, ...
                lDirsMat(:,isGoodDirVec));
            diffBoundMat =  minEllPtsMat - subEllPtsMat;
            boundPointMat = diffBoundMat + ...
                xSumMat;
            
        end
        if nDim==2
            boundPointMat=[boundPointMat boundPointMat(:,1)];
        end
        xSumDifMat = {boundPointMat};
        if size(boundPointMat,2)>0
            fMat = {convhulln(boundPointMat')};
        else
            fMat = {[]};
        end
        
        
        
        function [xMat] = fCalcSumTri(ell, nDim)
            nPoints = size(lDirsMat(:,isGoodDirVec), 2);
            xMat = zeros(nDim, nPoints);
            [~,xMat(:, 1:end)] = rho(ell,lDirsMat(:,isGoodDirVec));
            xMat(:,1:end-1) = xMat(:,1:end-1) ;
        end
    end
    function ellsVec = getEllArr(ellsArr)
        if isa(ellsArr, 'ellipsoid')
            cnt    = numel(ellsArr);
            ellsVec = reshape(ellsArr, cnt, 1);
            
        else
            import modgen.common.throwerror;
            throwerror('wrongInput', ...
                'if you don''t plot, all inputs must be ellipsoids');
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