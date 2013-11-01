function varargout = minkmp(varargin)
%
% MINKMP - computes and plots geometric (Minkowski) sum of the
%          geometric difference of two ellipsoids and the geometric
%          sum of n ellipsoids in 2D or 3D:
%          (E - Em) + (E1 + E2 + ... + En),
%          where E = firstEll, Em = secondEll,
%          E1, E2, ..., En - are ellipsoids in sumEllArr
%
% Usage:
%   MINKMP(firEll,secEll,ellMat,'Property',PropValue,...) -
%           Computes (E1 - E2) + (E3 + E4+ ... + En), if
%       1 <= min(dimension(inpEllMat)) = max(dimension(inpEllMat)) <= 3,
%       and plots it if no output arguments are specified.
%
%   [centVec, boundPointMat] = MINKMP(firEll,secEll,ellMat) - Computes
%      (E1 - E2) + (E3 + E4+ ... + En). Here centVec is
%       the center, and boundPointMat - array of boundary points.
% Input:
%   regular:
%       ellArr:  Ellipsoid: [dim11Size,dim12Size,...,dim1kSize] -
%           array of 2D or 3D Ellipsoids objects. All ellipsoids in ellArr
%                must be either 2D or 3D simutaneously.
%
%   properties:
%       'showAll': logical[1,1] - if 1, plot all ellArr.
%                    Default value is 0.
%       'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
%               if 1, ellipsoids in 2D will be filled with color.
%               Default value is 0.
%       'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]-
%                    line width for 1D and 2D plots. Default value is 1.
%       'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
%                sets default colors in the form [x y z].
%                   Default value is [1 0 0].
%       'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
%                level of transparency between 0 and 1 
%               (0 - transparent, 1 - opaque).
%                Default value is 0.4.
%       'relDataPlotter' - relation data plotter object.
%       Notice that property vector could have different dimensions, only
%       total number of elements must be the same.
%
% Output:
%   centVec: double[nDim, 1] - center of the resulting set.
%   boundPointMat: double[nDim, nBoundPoints] - set of boundary
%       points (vertices) of resulting set.
%
% Example:
%   firstEllObj = ellipsoid([-2; -1], [2 -1; -1 1]);
%   secEllObj = ell_unitball(2);
%   ellVec = [firstEllObj secEllObj ellipsoid([-3; 1], eye(2))];
%   minkmp(firstEllObj, secEllObj, ellVec);
% $Author: <Ilya Lyubich>  <lubi4ig@gmail.com> $    $Date: <8 January 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $


import elltool.plot.plotgeombodyarr;
import modgen.common.throwerror;
[reg]=...
    modgen.common.parseparext(varargin,...
    {'relDataPlotter','newFigure','fill','lineWidth','color','shade',...
    'priorHold','postHold','showAll'});
ellsArr = cellfun(@(x)getEllArr(x),reg,'UniformOutput', false);
ellsArr = vertcat(ellsArr{:});
ind = ~ellsArr.isEmpty();
ellsArr = ellsArr(ind);
if numel(ellsArr) == 1
    if (nargout == 1)||(nargout == 0)
        [reg]=...
            modgen.common.parseparext(varargin,...
            {'showAll';...
            [];});
        plObj = plot(reg{:});
        varargout(1) = {plObj};
    else
        [centerVector, boundPntMat] = ellsArr.double();
        varargout(1) = {centerVector};
        varargout(2) = {boundPntMat};
    end
elseif numel(ellsArr) == 2
    if (nargout == 1)||(nargout == 0)
        [reg]=...
            modgen.common.parseparext(varargin,...
            {'showAll';...
            [];});
        plObj = minkdiff(reg{:});
        varargout(1) = {plObj};
    else
        [centerVector, boundPntMat] = minkdiff(ellsArr(1),ellsArr(2));
        varargout(1) = {centerVector};
        varargout(2) = {boundPntMat};
    end
else
    if nargout == 0
        minkCommonAction(@getEllArr,@fCalcBodyTriArr,@fCalcCenterTriArr,...
            varargin{:});
    elseif nargout == 1
        output = minkCommonAction(@getEllArr,@fCalcBodyTriArr,...
            @fCalcCenterTriArr,varargin{:});
        varargout = output(1);
    else
        [qDifSumMat,boundMat] = minkCommonAction(@getEllArr,...
            @fCalcBodyTriArr,...
            @fCalcCenterTriArr,varargin{:});
        varargout(1) = {qDifSumMat};
        varargout(2) = {boundMat};
    end
end
    function [qSumDifCMat,fCMat] = fCalcCenterTriArr(ellsArr)
        nDim = dimension(ellsArr(1));
        if nDim == 1
            [ellsArr,~] = rebuildOneDim2TwoDim(ellsArr);
        end
        fstEll = ellsArr(1);
        secEll = ellsArr(2);
        arrEll = ellsArr(3:end);
        [centerDif,~] = minkdiff(fstEll,secEll);
        [centerSum,~] = minksum(arrEll);
        if isempty(centerDif)
            qSumDifCMat = {[]};
            fCMat = {[]};
        else
            qSumDifCMat = {centerSum + centerDif};
            fCMat = {[1 1]};
        end
        
    end
    function [xSumDifMat,fMat] = fCalcBodyTriArr(ellsArr)
        nDim = dimension(ellsArr(1));
        [lDirsMat, fGridMat] = getGridByFactor(ellsArr(1));
        lDirsMat = lDirsMat';
        if nDim == 1
            [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr);
        end
        fstEll = ellsArr(1);
        secEll = ellsArr(2);
        if ~isbigger(fstEll, secEll)
            xSumDifMat = {[]};
            fMat = {[]};
        else
            fstEllShMat = fstEll.shapeMat;
            if isdegenerate(fstEll)
                fstEllShMat = ...
                    ellipsoid.regularize(fstEllShMat,fstEll.absTol);
            end
            secEllShMat = secEll.shapeMat;
            if isdegenerate(secEll)
                secEllShMat = ...
                    ellipsoid.regularize(secEllShMat,secEll.absTol);
            end            
            absTolVal=min(fstEll.absTol, secEll.absTol);
            [isBadDirVec,pUniversalVec] = ...
                ellipsoid.isbaddirectionmat(fstEllShMat, secEllShMat, ...
                lDirsMat,absTolVal);
            isGoodDirVec = ~isBadDirVec;
            
            xCMat = arrayfun(@(x) fCalcSumTri(x, nDim), ellsArr(3:end), ...
                'UniformOutput', false);
            xSumMat = 0;
            for iXMat=1:numel(xCMat)
                xSumMat = xSumMat + xCMat{iXMat};
            end
            [diffBoundMat] = ...
                ellipsoid.calcdiffonedir(fstEll,secEll,lDirsMat,...
                pUniversalVec,isGoodDirVec);
            boundPointMat = cell2mat(diffBoundMat) + ...
                xSumMat;        
            
            boundPointMat=[boundPointMat boundPointMat(:,1)];
           
            fMat = {fGridMat};
            
            xSumDifMat = {boundPointMat};
        end
        
        function [xMat] = fCalcSumTri(ell, nDim)
            nPoints = size(lDirsMat, 2);
            xMat = zeros(nDim, nPoints);
            [~,xMat(:, 1:end)] = rho(ell,lDirsMat);
        end
    end
    function ellsVec = getEllArr(ellsArr)
        ellsVec = ellipsoid;
        if isa(ellsArr, 'ellipsoid')
            cnt    = numel(ellsArr);
            ellsVec = reshape(ellsArr, cnt, 1);
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
