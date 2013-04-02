function [varargout] = minkdiff(varargin)
%
% MINKSUM - computes geometric (Minkowski) sum of ellipsoids in 2D or 3D.
% Usage:
%   MINKSUM(inpEllMat,'Property',PropValue,...) - Computes geometric sum of ellipsoids
%       in the array inpEllMat, if
%       1 <= min(dimension(inpEllMat)) = max(dimension(inpEllMat)) <= 3,
%       and plots it if no output arguments are specified.
%
%   [centVec, boundPointMat] = MINKSUM(inpEllMat) - Computes
%       geometric sum of ellipsoids in inpEllMat. Here centVec is
%       the center, and boundPointMat - array of boundary points.
%   MINKSUM(inpEllMat) - Plots geometric sum of ellipsoids in
%       inpEllMat in default (red) color.
%   MINKSUM(inpEllMat, 'Property',PropValue,...) - Plots geometric sum of inpEllMat
%       with setting properties.
%
% Input:
%   regular:
%       ellArr:  Ellipsoid: [dim11Size,dim12Size,...,dim1kSize] -
%                array of 2D or 3D Ellipsoids objects. All ellipsoids in ellArr
%                must be either 2D or 3D simutaneously.
%
%   properties:
%       'shawAll': logical[1,1] - if 1, plot all ellArr.
%                    Default value is 0.
%       'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
%               if 1, ellipsoids in 2D will be filled with color. Default value is 0.
%       'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
%                    line width for 1D and 2D plots. Default value is 1.
%       'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
%                sets default colors in the form [x y z]. Default value is [1 0 0].
%       'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
%                level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
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
% $Author: <Ilya Lyubich>  <lubi4ig@gmail.com> $    $Date: <8 January 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $

import elltool.plot.plotgeombodyarr;
import modgen.common.throwerror;
N_PLOT_POINTS = 80;
SPHERE_TRIANG_CONST = 3;
isPlotCenter3d = false;
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
        plObj = plotgeombodyarr('ellipsoid',@fCalcCenterTriArr,...
            @(varargin)patch(varargin{:},'marker','*'),reg{:},'relDataPlotter',plObj, 'priorHold',true,'postHold',isHold);
    end
    varargout = {plObj};
else
    [qDifMat,boundMat] = minkCommonAction(@getEllArr,@fCalcBodyTriArr,@fCalcCenterTriArr,varargin{:});
    varargout(1) = {qDifMat};
    varargout(2) = {boundMat};
end
    function ellsVec = getEllArr(ellsArr)
        if isa(ellsArr, 'ellipsoid')
            cnt    = numel(ellsArr);
            ellsVec = reshape(ellsArr, cnt, 1);
        end
    end

    function [qDifMat,fMat] = fCalcCenterTriArr(ellsArr)
        nDim = dimension(ellsArr(1));
        if nDim == 1
            [ellsArr,~] = rebuildOneDim2TwoDim(ellsArr);
        end
        fstEll = ellsArr(1);
        secEll = ellsArr(2);
        if ~isbigger(fstEll, secEll)
            qDifMat = {[]};
            fMat = {[]};
        else
            centVec = fstEll.center - secEll.center;
            boundPointMat = centVec;
            qDifMat = {boundPointMat};
            fMat = {[1 1]};
        end
    end
    function [xDifMat,fMat] = fCalcBodyTriArr(ellsArr)
        import modgen.common.throwerror;
%         import calcdiffonedir;
        nDim = dimension(ellsArr(1));
        if nDim == 1
            [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr);
        end
        if numel(ellsArr) ~= 2
            throwerror('wrongInput','minkdiff needs 2 ellipsods');
        end
        absTol = elltool.conf.Properties.getAbsTol();
        fstEll = ellsArr(1);
        secEll = ellsArr(2);
        if ~isbigger(fstEll, secEll)
            xDifMat = {[]};
            fMat = {[]};
        else
            if nDim == 3
                isPlotCenter3d = true;
            end;
            fstEllShMat = fstEll.shape;
            if isdegenerate(fstEll)
                fstEllShMat = ellipsoid.regularize(fstEllShMat,absTol);
            end
            secEllShMat = secEll.shape;
            if isdegenerate(secEll)
                secEllShMat = ellipsoid.regularize(secEllShMat,absTol);
            end
            [lMat, fMat] = ellipsoid.calcGrid(nDim,N_PLOT_POINTS,SPHERE_TRIANG_CONST);
            lMat = lMat';
            [isBadDirVec,pUniversalVec] = ellipsoid.isbaddirectionmat(fstEllShMat, secEllShMat, ...
                lMat);
            isGoodDirVec = ~isBadDirVec;
            [diffBoundMat,isPlotCenter3d] = ellipsoid.calcdiffonedir(fstEll,secEll,lMat,...
                pUniversalVec,isGoodDirVec);
            boundPointMat = cell2mat(diffBoundMat);
            boundPointMat = [boundPointMat, boundPointMat(:, 1)];
            fMat = {fMat};
            
            xDifMat = {boundPointMat};
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