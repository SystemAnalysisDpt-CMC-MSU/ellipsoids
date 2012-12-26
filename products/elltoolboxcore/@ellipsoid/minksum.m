function [varargout] = minksum(varargin)
%
% MINKSUM - computes geometric (Minkowski) sum of ellipsoids in 2D or 3D.
%
%   MINKSUM(inpEllMat, Options) - Computes geometric sum of ellipsoids
%       in the array inpEllMat, if
%       1 <= min(dimension(inpEllMat)) = max(dimension(inpEllMat)) <= 3,
%       and plots it if no output arguments are specified.
%
%   [centVec, boundPointMat] = MINKSUM(inpEllMat) - Computes
%       geometric sum of ellipsoids in inpEllMat. Here centVec is
%       the center, and boundPointMat - array of boundary points.
%   MINKSUM(inpEllMat) - Plots geometric sum of ellipsoids in
%       inpEllMat in default (red) color.
%   MINKSUM(inpEllMat, Options) - Plots geometric sum of inpEllMat
%       using options given in the Options structure.
%
% Input:
%   regular:
%       inpEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids
%           of the same dimentions 2D or 3D.
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
%   centVec: double[nDim, 1] - center of the resulting set.
%   boundPointMat: double[nDim, nBoundPoints] - set of boundary
%       points (vertices) of resulting set.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import modgen.common.throwerror;
N_PLOT_POINTS = 80;
SPHERE_TRIANG_CONST = 3;
DEFAULT_LINE_WIDTH = 1;
DEFAULT_SHAD = 0.4;
DEFAULT_FILL = false;
[reg,~,plObj,isFill,lineWidth,colorVec,shadVec,isShowAll...
    isRelPlotterSpec,isIsFill,isLineWidth,isColorVec,isShad]=...
    modgen.common.parseparext(varargin,...
    {'relDataPlotter','fill','lineWidth','color','shade','showall' ;...
    [],0,[],[],[],0;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
    @(x)isa(x,'logical'),@(x)isa(x,'double'),@(x)isa(x,'double'),...
    @(x)isa(x,'double'),...
    @(x)isa(x,'logical')});
checkIsWrongInput();
if ~isRelPlotterSpec
    plObj=smartdb.disp.RelationDataPlotter('figureGetNewHandleFunc',...
        @(varargin)gcf,'axesGetNewHandleFunc',@(varargin)gca);
end
[ellsArr, ellNum] = getEllParams(reg);
nDim = max(dimension(ellsArr));
if nDim == 3 && isLineWidth
    throwerror('wrongProperty', 'LineWidth is not supported by 3D Ellipsoids');
end
if nDim == 1
    rebuildOneDim2TwoDim();
end
[lGetGridMat, fGetGridMat] = calcGrid();
[colorVec, shadVec, lineWidth, isFill] = getPlotParams(colorVec, shadVec,...
    lineWidth, isFill);
checkIsWrongParams();
checkDimensions();
SData = setUpSData();
calcEllPoints();

rel=smartdb.relations.DynamicRelation(SData);
hFigure = get(0,'CurrentFigure');
if (nargout <= 1)
    if isempty(hFigure)
        isHold=false;
    elseif ~ishold(get(hFigure,'currentaxes'))
        cla;
        isHold = false;
    else
        isHold = true;
    end
    if (nDim==2)
        plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
            @figureSetPropFunc,{},...
            @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
            @axesSetPropDoNothingFunc,{},...
            @plotCreateFillPlotFunc,...
            {'xCMat','qCMat', 'clrVec','fill','shadVec', 'widVec'});
        
    elseif (nDim==3)
        plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
            @figureSetPropFunc,{},...
            @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
            @axesSetPropDoNothingFunc,{},...
            @plotCreatePatchFunc,...
            {'verCMat','faceCMat','faceVertexCDataCMat',...
            'shadVec','clrVec'});
    end
    
    if isShowAll
        plot(ellsArr, 'color', [0 0 0],'relDataPlotter',plObj);
    end
    if  isHold
        hold on;
    else
        hold off;
    end
    if (nargout == 1)
        varargout = plObj;
    end
else
    varargout = {SData.qCMat{1}, SData.xCMat{1}};
end

%
% if ~ishold
%     isHold = false;
%     cla
% else
%     isHold = true;
% end
% hold on;
% fstInpArg = reg{1};
% if ~isa(fstInpArg, 'ellipsoid')
%     throwerror('wrongInput', ...
%         'MINKSUM: input argument must be an array of ellipsoids.');
% end
%
% inpEllMat   = reg{1};
% [mRows, nCols] = size(inpEllMat);
% nInpEllip = mRows * nCols;
% inpEllVec   = reshape(inpEllMat, 1, nInpEllip);
% nDimsVec = dimension(inpEllVec);
% minDim = min(nDimsVec);
% maxDim = max(nDimsVec);
%
% if minDim ~= maxDim
%     throwerror('wrongSizes', ...
%         'MINKSUM: ellipsoids must be of the same dimension.');
% end
% if maxDim > 3
%     throwerror('wrongSizes', ...
%         'MINKSUM: ellipsoid dimension must be not higher than 3.');
% end
%
% if (isShowAll ~= 0) && ((nargout == 1) || (nargout == 0))
%     plObj = plot(inpEllVec, 'b','relDataPlotter',plObj);
% end
%
% if (Properties.getIsVerbose()) && (nInpEllip > 1)
%     if nargout == 1
%         fstStr = 'Computing and plotting geometric sum ';
%         secStr = 'of %d ellipsoids...\n';
%         fprintf([fstStr secStr], nInpEllip);
%     else
%         fprintf('Computing geometric sum of %d ellipsoids...\n', ...
%             nInpEllip);
%     end
% end
% SData = [];
% SData.figureNameCMat={'figure'};
% SData.axesNameCMat = {'ax'};
% SData.axesNumCMat = {1};
% SData.figureNumCMat = {1};
% SData.clrVec = {colorVec};
% SData.widVec = lineWidth;
% SData.shadVec = shad;
% for iEllip = 1:nInpEllip
%     myEll = inpEllVec(iEllip);
%     switch maxDim
%         case 2,
%             if iEllip == 1
%                 boundPointMat = ellbndr_2d(myEll);
%                 SData.boundPointXVec = boundPointMat(1,:);
%                 SData.boundPointYVec = boundPointMat(2,:);
%                 SData.centVec = myEll.center';
%             else
%                 boundPointMat = boundPointMat + ellbndr_2d(myEll);
%                 SData.boundPointXVec = boundPointMat(1,:);
%                 SData.boundPointYVec = boundPointMat(2,:);
%                 SData.centVec = SData.centVec + myEll.center';
%             end
%         case 3,
%             if iEllip == 1
%                 boundPointMat = ellbndr_3d(myEll);
%                 centVec = myEll.center;
%             else
%                 boundPointMat = boundPointMat + ellbndr_3d(myEll);
%                 centVec = centVec + myEll.center;
%             end
%         otherwise,
%             if iEllip == 1
%                 SData.centVec = myEll.center';
%                 SData.boundPointXVec = myEll.center - sqrt(myEll.shape);
%                 SData.boundPointYVec = myEll.center + sqrt(myEll.shape);
%             else
%                 SData.centVec = SData.centVec + myEll.center';
%                 SData.boundPointXVec = SData.boundPointXVec + myEll.center...
%                     - sqrt(myEll.shape);
%                 SData.boundPointYVec = SData.boundPointYVec + myEll.center...
%                     + sqrt(myEll.shape);
%             end
%     end
% end
% SData.fill = (isFill~=0);
% rel=smartdb.relations.DynamicRelation(SData);
% if (maxDim==2)
%     if isFill ~= 0
%         plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
%             @figureSetPropFunc,{},...
%             @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
%             @axesSetPropDoNothingFunc,{},...
%             @plotCreateFillPlotFunc,...
%             {'boundPointXVec','boundPointYVec','clrVec','fill','shadVec'});
%     end
%     plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
%         @figureSetPropFunc,{},...
%         @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
%         @axesSetPropDoNothingFunc,{},...
%         @plotCreateElPlotFunc,...
%         {'boundPointXVec','boundPointYVec','centVec','clrVec','widVec'});
% elseif (maxDim==3)
%     chllMat = convhulln(boundPointMat');
%     nBoundPoints = size(boundPointMat, 2);
%     SData.verXCMat = {boundPointMat(1,:)};
%     SData.verYCMat = {boundPointMat(2,:)};
%     SData.verZCMat = {boundPointMat(3,:)};
%     SData.faceXCMat = {chllMat(:,1)};
%     SData.faceYCMat = {chllMat(:,2)};
%     SData.faceZCMat = {chllMat(:,3)};
%     clr = colorVec(ones(1, nBoundPoints),:);
%     SData.faceVertexCDataXCMat = {clr(:,1)};
%     size(SData.faceVertexCDataXCMat{1})
%     SData.faceVertexCDataYCMat = {clr(:,2)};
%     SData.faceVertexCDataZCMat = {clr(:,3)};
%     rel=smartdb.relations.DynamicRelation(SData);
%     plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
%         @figureSetPropFunc,{},...
%         @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
%         @axesSetPropDoNothingFunc,{},...
%         @plotCreatePatchFunc,...
%         {'verXCMat','verYCMat','verZCMat','faceXCMat','faceYCMat','faceZCMat','faceVertexCDataXCMat','faceVertexCDataYCMat',...
%         'faceVertexCDataZCMat','shadVec','clrVec'});
% else
%     plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
%         @figureSetPropFunc,{},...
%         @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
%         @axesSetPropDoNothingFunc,{},...
%         @plotCreateEl2PlotFunc,...
%         {'boundPointXVec','boundPointYVec','centVec','clrVec','widVec'});
% end
% if (nargout == 1)||(nargout == 0)
%     varargout = {plObj};
% else
%     varargout = {centVec, boundPointMat};
% end
% if ~isHold
%     hold off
% end





    function calcEllPoints()
        [xMat, fMat] = arrayfun(@(x) ellPoints(x, nDim), ellsArr, ...
            'UniformOutput', false);
        xSumMat = 0;
        for iXMat=1:numel(xMat)
            xSumMat = xSumMat + xMat{iXMat};
        end
        qSumMat = 0;
        qMat = arrayfun(@(x) {x.center}, ellsArr);
        for iQMat=1:numel(qMat)
            qSumMat = qSumMat + qMat{iQMat};
        end
        SData.xCMat = {xSumMat};
        SData.qCMat = {qSumMat};
        SData.verCMat = {xSumMat};
        SData.clrVec = {colorVec};
        SData.faceCMat = fMat(1);
        colCMat = cellfun(@(x) getColCMat(x), num2cell(colorVec, 2), ...
            'UniformOutput', false);
        SData.faceVertexCDataCMat = colCMat;
        function colCMat = getColCMat(clrVec)
            colCMat = clrVec(ones(1, size(xMat{1}, 2)), :);
        end
    end

    function SData = setUpSData()
        SData.figureNameCMat=repmat({'figure'},1,1);
        SData.axesNameCMat = repmat({'ax'},1,1);
        SData.axesNumCMat = repmat({1},1,1);
        
        SData.figureNumCMat = repmat({1},1,1);
        
        SData.widVec = lineWidth.';
        SData.shadVec = shadVec.';
        SData.fill = (isFill)';
    end
    function checkIsWrongInput()
        import modgen.common.throwerror;
        cellfun(@(x)checkRightPropName(x),reg);
        
        function checkRightPropName(value)
            import modgen.common.throwerror;
            if ischar(value)&&(numel(value)>1)
                if~isRightProp(value)
                    throwerror('wrongProperty', ...
                        'This property doesn''t exist');
                else
                    throwerror('wrongPropertyValue', ...
                        'There is no value for property.');
                end
            elseif ~isa(value, 'ellipsoid') && ~ischar(value)
                throwerror('wrongPropertyType', 'Property must be a string.');
            end
            function isRProp = isRightProp(value)
                isRProp = strcmpi(value, 'fill') |...
                    strcmpi(value, 'linewidth') | ...
                    strcmpi(value, 'shade') | strcmpi(value, 'color') | ...
                    strcmpi(value, 'showall');
            end
        end
    end
    function rebuildOneDim2TwoDim()
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
    function [lGetGrid, fGetGrid] = calcGrid()
        if nDim == 2
            lGetGrid = gras.geom.circlepart(N_PLOT_POINTS);
            fGetGrid = 1:N_PLOT_POINTS+1;
        else
            [lGetGrid, fGetGrid] = ...
                gras.geom.tri.spheretri(SPHERE_TRIANG_CONST);
        end
        lGetGrid(lGetGrid == 0) = eps;
    end
    function [colorVec, shade, lineWidth, isFill] = ...
            getPlotParams(colorVec, shade, lineWidth, isFill)
        
        shade = getPlotInitParam(shade, isShad, DEFAULT_SHAD);
        lineWidth = getPlotInitParam(lineWidth, ...
            isLineWidth, DEFAULT_LINE_WIDTH);
        isFill = getPlotInitParam(isFill, isIsFill, DEFAULT_FILL);
        colorVec = getColorVec(colorVec);
    end
    function outParamVec = getPlotInitParam(inParamArr, ...
            isFilledParam, multConst)
        import modgen.common.throwerror;
        outParamVec = multConst;
        if isFilledParam
            if numel(inParamArr)>1
                throwerror('wrongParamsNumber',...
                    'Number of params is not equal 1');
            end
            outParamVec = inParamArr;
        end
    end
    function colorArr = getColorVec(colorArr)
        import modgen.common.throwerror;
        if ~isColorVec
            colorArr = [1 0 0];
        else
            if size(colorArr, 1) ~= 1
                throwerror('wrongColorVecSize',...
                    'Wrong size of color array');
            end
        end
    end
    function checkIsWrongParams()
        import modgen.common.throwerror;
        if any(lineWidth <= 0) || any(isnan(lineWidth)) || ...
                any(isinf(lineWidth))
            throwerror('wrongLineWidth', ...
                'LineWidth must be greater than 0 and finite');
        end
        if (any(shadVec < 0)) || (any(shadVec > 1)) || any(isnan(shadVec))...
                || any(isinf(shadVec))
            throwerror('wrongShade', 'Shade must be between 0 and 1');
        end
        if (any(colorVec(:) < 0)) || (any(colorVec(:) > 1)) || ...
                any(isnan(colorVec(:))) || any(isinf(colorVec(:)))
            throwerror('wrongColorVec', 'Color must be between 0 and 1');
        end
        if size(colorVec, 2) ~= 3
            throwerror('wrongColorVecSize', ...
                'ColorVec is a vector of length 3');
        end
    end
    function checkDimensions()
        import elltool.conf.Properties;
        import modgen.common.throwerror;
        ellsArrDims = dimension(ellsArr);
        mDim    = min(ellsArrDims);
        nDim    = max(ellsArrDims);
        if mDim ~= nDim
            throwerror('dimMismatch', ...
                'Ellipsoids must have the same dimensions.');
        end
        if (mDim < 1) || (nDim > 3)
            throwerror('wrongDim','ellipsoid dimension can be 1, 2 or 3');
        end
        if Properties.getIsVerbose()
            if ellNum == 1
                fprintf('Plotting ellipsoid...\n');
            else
                fprintf('Plotting %d ellipsoids...\n', ellNum);
            end
        end
    end
    function [xMat, fMat] = ellPoints(ell, nDim)
        nPoints = size(lGetGridMat, 1);
        xMat = zeros(nDim, nPoints+1);
        [qCenVec,qMat] = ell.double();
        xMat(:, 1:end-1) = sqrtm(qMat)*lGetGridMat.' + ...
            repmat(qCenVec, 1, nPoints);
        xMat(:, end) = xMat(:, 1);
        fMat = fGetGridMat;
    end
end














function hVec=plotCreateFillPlotFunc(hAxes,X,q,clrVec,isFill,...
    shade,widVec,varargin)
if ~isFill
    shade = 0;
end
h1 = ell_plot(q, '*','Parent',hAxes);
if isFill
    h2 = fill(X(1, :), X(2, :), clrVec,'FaceAlpha',shade,'Parent',hAxes);
end
h3 = ell_plot(X,'Parent',hAxes);

set(h1, 'Color', clrVec);
set(h3, 'Color', clrVec, 'LineWidth', widVec);
if isFill
    hVec = [h1,h2,h3];
else
    hVec = [h1, h3];
end
end
function figureSetPropFunc(hFigure,figureName,~)
set(hFigure,'Name',figureName);
end
function figureGroupName=figureGetGroupNameFunc(figureName)
figureGroupName=figureName;
end
function hVec=axesSetPropDoNothingFunc(~,~)
hVec=[];
end
function axesName=axesGetNameSurfFunc(name,~)
axesName=name;
end
function hVec=plotCreatePatchFunc(hAxes,vertices,faces,...
    faceVertexCData,faceAlpha,clrVec)
import modgen.graphics.camlight;
LIGHT_TYPE_LIST={{'left'},{40,-65},{-20,25}};
hVec = patch('Vertices',vertices', 'Faces', faces, ...
    'FaceVertexCData', faceVertexCData, 'FaceColor','flat', ...
    'FaceAlpha', faceAlpha,'EdgeColor',clrVec,'Parent',hAxes);
hLightVec=cellfun(@(x)camlight(hAxes,x{:}),LIGHT_TYPE_LIST);
hVec=[hVec,hLightVec];
shading(hAxes,'interp');
lighting(hAxes,'phong');
material(hAxes,'metal');
view(hAxes,3);
end


function [ellsArr, ellNum] = getEllParams(reg)
import modgen.common.throwerror;
[ellsCMat] = cellfun(@(x)getParams(x),...
    reg,'UniformOutput', false);
ellsArr = vertcat(ellsCMat{:});
ellNum = numel(ellsArr);

    function [ellVec] = getParams(ellArr)
        
        import modgen.common.throwerror;
        if isa(ellArr, 'ellipsoid')
            cnt    = numel(ellArr);
            ellVec = reshape(ellArr, cnt, 1);
        else
            throwerror('wrongInput', ...
                'All inputs except the properties must be ellipsoids or arrays of ellipsoids');
        end
    end
end