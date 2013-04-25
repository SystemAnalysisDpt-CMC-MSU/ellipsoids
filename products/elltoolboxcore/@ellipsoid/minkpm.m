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
ABS_TOL = 1e-14;
[reg]=...
    modgen.common.parseparext(varargin,...
    {'relDataPlotter','newFigure','fill','lineWidth','color','shade','priorHold','postHold','showAll'});
ellsArr = cellfun(@(x)getEllArr(x),reg,'UniformOutput', false);
ellsArr = vertcat(ellsArr{:});
ind = ~isempty(ellsArr);
ellsArr = ellsArr(ind);
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
                @(varargin)patch(varargin{:},'marker','*'),reg{:},'relDataPlotter',...
                plObj, 'priorHold',true,'postHold',isHold);
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
                @(varargin)patch(varargin{:},'marker','*'),reg{:},'relDataPlotter',...
                plObj, 'priorHold',true,'postHold',isHold);
        end
        varargout = {plObj};
    else
        [qDifMat,boundMat] = minkCommonAction(@getEllArr,@fCalcBodyTriArr,@fCalcCenterTriArr,varargin{:});
        varargout(1) = {qDifMat};
        varargout(2) = {boundMat};
    end
end
    function ellsVec = getEllArr(ellsArr)
        ellsVec = ellipsoid;
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
        [dirMat, ~] = getGridByFactor(inpEllArr(1));
        dirMat = dirMat';
        extApproxEllVec = minksumEa(inpEllArr, dirMat);
        if min(extApproxEllVec > inpEll) == 0
            qSumDifMat = {[]};
            fMat = {[]};
        else
            [qSum,~] = minksum(inpEllArr);
            qSumDifMat = {qSum - inpEll.center};
            fMat = {[1 1]};
        end
    end

    function [xSumDiffCell,fMat] = fCalcBodyTriArr(ellsArr)
        import modgen.common.throwerror;
        nDims = dimension(ellsArr(1));
        if nDims == 1
            [ellsArr,nDims] = rebuildOneDim2TwoDim(ellsArr);
        end
        inpEllArr = ellsArr(1:end-1);
        inpEll = ellsArr(end);
        elltool.conf.Properties.setIsVerbose(false)
        [dirMat, fMat] =getGridByFactor(inpEllArr(1));
        dirMat = dirMat';
        extApproxEllVec = minksum_ea(inpEllArr, dirMat);
        centVec= extApproxEllVec(1).center - inpEll.center;
        nCols = size(dirMat, 2);
%         switch nDims
%             case 2
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
                xSumDiffCell = {[bpMat bpMat(:, 1)]};
                
                
%             case 3
%                 fMat = {fMat};
%                 isGoodDir = false(1,nCols);
%                 arrayfun(@(x) fFindGoodDir(x), 1:nCols);
%                 if any(isGoodDir)
%                     nGoodDirs = sum(isGoodDir);
%                     goodIndexVec = find(isGoodDir);
%                     boundPointMat = zeros(nDims, nGoodDirs);
%                     arrayfun(@(x)  fCase3(x), 1:nGoodDirs);
%                     xSumDiffCell = {boundPointMat};
%                 else
%                     xSumDiffCell = {centVec};
%                 end
               
                fMat = {fMat};
                
                
%         end
        function fCase2extAppr(index)
            dirVec = dirMat(:, index);
            absTolVal=min(extApproxEllVec(index).absTol, inpEll.absTol);
            isGoodDirVec =~isbaddirection(extApproxEllVec(index), inpEll, dirVec,absTolVal);
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
            absTolVal=min(extApproxEllVec(index).absTol, inpEll.absTol);
            if ~isbaddirection(extApproxEllVec(index), inpEll, dirVec,absTolVal)
                intApprEll = minksum_ia(inpEllArr, dirVec);
                absTolVal2=min(intApprEll.absTol, inpEll.absTol);
                if ~isbaddirection(intApprEll, inpEll, dirVec,absTolVal2)
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
        %         extApproxEllVec = minksumEa(inpEllArr, dirMat);
        %         if min(extApproxEllVec > inpEll) == 0
        %             xSumDifMat = {[]};
        %             fMat = {[]};
        %         else
        % %             isPlotCenter3d = true;
        %             xSumDifMat = dirMat;
        %             supAllMat = inf(1,size(dirMat,2));
        %             [extApproxDiffCell] = arrayfun(@(x)minkdiffEa(x,inpEll,dirMat),extApproxEllVec,'UniformOutput',false);
        %             cellfun(@(x)diffcalcl1(x),extApproxDiffCell);
        %             xSumDiffCell ={[xSumDifMat,xSumDifMat(:,1)]};
        %             fMat = {fMat};
        %
        %         end
        
        
        function [boundPointMat] = isplotcenter(boundPointMat)
            [qSum,~] = minksum(ellsArr(1:end-1));
            if abs(boundPointMat-qSum+inpEll.center) < ABS_TOL
                boundPointMat = qSum-inpEll.center;
            else
                isPlotCenter3d = false;
            end
        end
        function diffcalcl1(extApproxDiffCell)
            arrayfun(@(x)diffcalcl2(x),extApproxDiffCell);
            
            
            function diffcalcl2(ellipsoidl1l2)
                [supMat, supDirMat] = rho(ellipsoidl1l2, ...
                    dirMat);
                supAllMat = min(supAllMat,supMat);
                ind = find((supAllMat-supMat) == 0);
                if (any(ind))
                    xSumDifMat(:,ind) = supDirMat(:,ind);
                end
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


function [extApprEllVec] = minkdiffEa(fstEll, secEll, directionsMat)
import modgen.common.throwerror;
import modgen.common.checkmultvar;
import elltool.conf.Properties;
clear extApprEllVec ;
centVec = fstEll.center - secEll.center;
fstEllShMat = fstEll.shape;
secEllShMat = secEll.shape;
if isdegenerate(fstEll)
    fstEllShMat = ellipsoid.regularize(fstEllShMat,fstEll.absTol);
end
if isdegenerate(secEll)
    secEllShMat = ellipsoid.regularize(secEllShMat,secEll.absTol);
end
absTolVal=min(fstEll.absTol, secEll.absTol);
directionsMat  = ellipsoid.rm_bad_directions(fstEllShMat, ...
    secEllShMat, directionsMat,absTolVal);
nDirs  = size(directionsMat, 2);
if nDirs < 1
    extApprEllVec = [];
    return;
end
fstEllSqrtShMat = sqrtm(fstEllShMat);
secEllSqrtShMat = sqrtm(secEllShMat);

srcMat=fstEllSqrtShMat*directionsMat;
dstMat=secEllSqrtShMat*directionsMat;
rotArray=gras.la.mlorthtransl(dstMat, srcMat);

extApprEllVec(nDirs) = ellipsoid();
arrayfun(@(x) fSingleDir(x), 1:nDirs)
    function fSingleDir(index)
        rotMat = rotArray(:,:,index);
        shMat = fstEllSqrtShMat - rotMat*secEllSqrtShMat;
        extApprEllVec(index).center = centVec;
        extApprEllVec(index).shape = shMat'*shMat;
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