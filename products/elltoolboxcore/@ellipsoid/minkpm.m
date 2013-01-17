function [varargout] = minkpm(varargin)
%
% MINKPM - computes and plots geometric (Minkowski) difference
%          of the geometric sum of ellipsoids and a single ellipsoid
%          in 2D or 3D: (E1 + E2 + ... + En) - E,
%          where E = inpEll,
%          E1, E2, ... En - are ellipsoids in inpEllArr.
%
%   MINKPM(inpEllArr, inpEll, OPTIONS)  Computes geometric difference
%       of the geometric sum of ellipsoids in inpEllMat and
%       ellipsoid inpEll, if
%       1 <= dimension(inpEllArr) = dimension(inpArr) <= 3,
%       and plots it if no output arguments are specified.
%
%   [centVec, boundPointMat] = MINKPM(inpEllArr, inpEll) - pomputes
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

import elltool.plot.plotgeombodyarr;
import modgen.common.throwerror;
isPlotCenter3d = false;
[reg]=...
    modgen.common.parseparext(varargin,...
    {'relDataPlotter','newFigure','fill','lineWidth','color','shade','priorHold','postHold','showAll'});
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
    if nargout == 0
        output = minkCommonAction(@getEllArr,@fCalcBodyTriArr,@fCalcCenterTriArr,varargin{:});
        plObj = output{1};
        isHold = output{2};
        if isPlotCenter3d
            [reg]=...
                modgen.common.parseparext(varargin,...
                {'relDataPlotter';...
                [],;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
                });
            plotgeombodyarr('ellipsoid',@fCalcCenterTriArr,...
                @(varargin)patch(varargin{:},'marker','*'),reg{:},'relDataPlotter',plObj, 'priorHold',true,'postHold',isHold);
        end
    elseif nargout == 1
        output = minkCommonAction(@getEllArr,@fCalcBodyTriArr,@fCalcCenterTriArr,varargin{:});
        plObj = output{1};
        isHold = output{2};
        if isPlotCenter3d
            [reg]=...
                modgen.common.parseparext(varargin,...
                {'relDataPlotter';...
                [],;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
                });
            plObj = minkCommonAction('ellipsoid',@fCalcCenterTriArr,...
                @(varargin)patch(varargin{:},'marker','*'),reg{:},'relDataPlotter',plObj, 'priorHold',true,'postHold',isHold);
        end
        varargout = {plObj};
    else
        [qDifMat,boundMat] = minkCommonAction(@getEllArr,@fCalcBodyTriArr,@fCalcCenterTriArr,varargin{:});
        varargout(1) = {qDifMat};
        varargout(2) = {boundMat};
    end
end
    function ellsVec = getEllArr(ellsArr)
        if isa(ellsArr, 'ellipsoid')
            cnt    = numel(ellsArr);
            ellsVec = reshape(ellsArr, cnt, 1);
        end
    end

    function [qSumDifMat,fMat] = fCalcCenterTriArr(ellsArr)
        nDim = dimension(ellsArr(1));
        if nDim == 1
            [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr);
        end
        inpEllArr = ellsArr(1:end-1);
        inpEll = ellsArr(end);
        switch nDim
            case 2,
                nPlot2dPointsInpEllMat = inpEllArr.nPlot2dPoints;
                nPlot2dPoints = max(nPlot2dPointsInpEllMat(:));
                phiVec = linspace(0, 2*pi, nPlot2dPoints);
                dirMat = [cos(phiVec); sin(phiVec)];
                
            case 3,
                nPlot3dPointsInpEllMat = inpEllArr.nPlot3dPoints;
                nPlot3dPnt = max(nPlot3dPointsInpEllMat(:))/2;
                nPlot3dPntSub = nPlot3dPnt/2;
                psyVec = linspace(0, pi, nPlot3dPntSub);
                phiVec = linspace(0, 2*pi, nPlot3dPnt);
                dirMat   = [];
                for iCol = 2:(nPlot3dPntSub - 1)
                    subDirVec = cos(psyVec(iCol))*ones(1, nPlot3dPnt);
                    dirMat   = [dirMat [cos(phiVec)*sin(psyVec(iCol)); ...
                        sin(phiVec)*sin(psyVec(iCol)); subDirVec]];
                end
                
        end
        extApproxEllVec = minksumEa(inpEllArr, dirMat);
        if min(extApproxEllVec > inpEll) == 0
            qSumDifMat = [];
            fMat = [];
        else
            [qSum,~] = minksum(inpEllArr);
            qSumDifMat = {qSum - inpEll.center};
            fMat = {[1 1]};
        end
    end

    function [xSumDifMat,fMat] = fCalcBodyTriArr(ellsArr)
        import modgen.common.throwerror;
        nDim = dimension(ellsArr(1));
        if nDim == 1
            [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr);
        end
        absTol = elltool.conf.Properties.getAbsTol();
        inpEllArr = ellsArr(1:end-1);
        inpEll = ellsArr(end);
        switch nDim
            case 2,
                nPlot2dPointsInpEllMat = inpEllArr.nPlot2dPoints;
                nPlot2dPoints = max(nPlot2dPointsInpEllMat(:));
                phiVec = linspace(0, 2*pi, nPlot2dPoints);
                dirMat = [cos(phiVec); sin(phiVec)];
                
            case 3,
                nPlot3dPointsInpEllMat = inpEllArr.nPlot3dPoints;
                nPlot3dPnt = max(nPlot3dPointsInpEllMat(:))/2;
                nPlot3dPntSub = nPlot3dPnt/2;
                psyVec = linspace(0, pi, nPlot3dPntSub);
                phiVec = linspace(0, 2*pi, nPlot3dPnt);
                dirMat   = [];
                for iCol = 2:(nPlot3dPntSub - 1)
                    subDirVec = cos(psyVec(iCol))*ones(1, nPlot3dPnt);
                    dirMat   = [dirMat [cos(phiVec)*sin(psyVec(iCol)); ...
                        sin(phiVec)*sin(psyVec(iCol)); subDirVec]];
                end
                
        end
        extApproxEllVec = minksumEa(inpEllArr, dirMat);
        if min(extApproxEllVec > inpEll) == 0
            xSumDifMat = [];
            fMat = [];
        else
            nCols = size(dirMat, 2);
            secEllShMat = inpEll.shape;
            if isdegenerate(inpEll)
                secEllShMat = ellipsoid.regularize(secEllShMat,absTol);
            end
            
            boundPointMat = arrayfun(@calcDifDir,1:nCols, 'UniformOutput',false);
            boundPointMat = horzcat(boundPointMat{:});
            ind = min(~isnan(boundPointMat),[],1);
            index = 1:nCols;
            boundPointMat = boundPointMat(:,index(ind));
            
            xSumDifMat = {boundPointMat};
            if (size(boundPointMat,2)>0)
                fMat = {convhulln(boundPointMat')};
            else
                fMat = {[]};
            end
            if (size(boundPointMat,2) < 2)&&(nDim == 3)
                isPlotCenter3d = true;
            end
        end
        function bpMat = calcDifDir(index)
            dirVec = dirMat(:, index);
            inpEllT = extApproxEllVec(index);
            extApproxShEllMat = inpEllT.shape;
            if isdegenerate(inpEllT)
                extApproxShEllMat  = ellipsoid.regularize(extApproxShEllMat ,absTol);
            end
            lVec = ellipsoid.rm_bad_directions(extApproxShEllMat, ...
                secEllShMat, dirVec);
            if size(lVec, 2) > 0
                [~, bpMat] = rho(inpEllT, lVec);
                [~, subBoundPointMat] = rho(inpEll, lVec);
                bpMat = bpMat - subBoundPointMat;
            else
                bpMat = NaN(1,size(lVec,1));
            end
            
            
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
function extApprEllVec = minksumEa(inpEllArr, dirMat)
[nDims, nCols] = size(dirMat);
if isscalar(inpEllArr)
    extApprEllVec = inpEllArr;
    return;
end
centVec =zeros(nDims,1);
arrayfun(@(x) fAddCenter(x),inpEllArr);
absTolArr = getAbsTol(inpEllArr);
extApprEllVec(1,nCols) = ellipsoid;
arrayfun(@(x) fSingleDirection(x),1:nCols);

    function fAddCenter(singEll)
        centVec = centVec + singEll.center;
    end
    function fSingleDirection(index)
        secCoef = 0;
        subShMat = zeros(nDims,nDims);
        dirVec = dirMat(:, index);
        arrayfun(@(x,y) fAddSh(x,y), inpEllArr,absTolArr);
        subShMat  = 0.5*secCoef*(subShMat + subShMat');
        extApprEllVec(index).center = centVec;
        extApprEllVec(index).shape = subShMat;
        
        function fAddSh(singEll,absTol)
            shMat = singEll.shape;
            if isdegenerate(singEll)
                shMat = ellipsoid.regularize(shMat, absTol);
            end
            fstCoef = sqrt(dirVec'*shMat*dirVec);
            subShMat = subShMat + ((1/fstCoef) * shMat);
            secCoef = secCoef + fstCoef;
        end
        
    end
end