function  [plObj,nDim,isHold] = plotgeombodyarr(fIsObjClassName,fDim,...
    calcBodyPoints,fPlotPatch,varargin)
%
% plotgeombodyarr - plots objects in 2D or 3D.
%
%
% Usage:
%       plotgeombodyarr(objClassName,rebuildOneDim2TwoDim,calcBodyPoints,
%       plotPatch,objArr,'Property',PropValue,...)
%       - plots array of objClassName objects
%           using calcBodyPoints function to calculate points,
%rebuildOneDim2TwoDim to rebuild one dim ibjects to two dim if it is needed,
%           plotPatch to plot objects with  setting properties
%
% Input:
%   regular:
%       objClassName: char[1,] - class of objects
%       calcBodyPoints: function_handle[1,1] - function with input
%           ellsArr,nDim,lGetGridMat,fGetGridMat and output [xMat,fMat]
%       plotPatch: function_handle[1,1] - plotting function
%       bodyArr:  objects: [dim11Size,dim12Size,...,dim1kSize] -
%                array of 2D or 3D objects. All objects in bodyArr
%                must be either 2D or 3D simutaneously.
%   optional:
%       color1Spec: char[1,1] - color specification code, can be 'r','g',
%                      etc (any code supported by built-in Matlab function).
%       body2Arr: objClassName: [dim21Size,dim22Size,...,dim2kSize] -
%                                           second ellipsoid array...
%       color2Spec: char[1,1] - same as color1Spec but for body2Arr
%       ....
%       bodyNArr: objClassName: [dimN1Size,dim22Size,...,dimNkSize] -
%                                            N-th objects array
%       colorNSpec - same as color1Spec but for bodyNArr.
%   properties:
%       'newFigure': logical[1,1] - if 1,
%                   each plot command will open a new figure window.
%                    Default value is 0.
%       'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
%               if 1, ellipsoids in 2D will be filled with color.
%               Default value is 0.
%       'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
%                    line width for 1D and 2D plots. Default value is 1.
%       'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
%                sets default colors in the form [x y z].
%                   Default value is [1 0 0].
%       'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
%      level of transparency between 0 and 1 (0 - transparent, 1 - opaque).
%                Default value is 0.4.
%       'relDataPlotter' - relation data plotter object.
%       'priorHold':logical[1,1] - if true plot with hold on,
%       'postHold':logical[1,1] - if true, after plotting hold will be on ,
%       Notice that property vector could have different dimensions, only
%       total number of elements must be the same.
% Output:
%   regular:
%       plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
%       data plotter object.
%       nDim: double[1,1] - dimension of objects,
%       isHold: logical[1,1] - true, if before plotting was hold on,
%       bodyArr: objClassName: [dim21Size,dim22Size,...,dim2kSize] -
%       array of input objects
%
% $Author: <Ilya Lyubich>  <lubi4ig@gmail.com> $    $Date: <11 January 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
%
import modgen.common.throwerror;
%
DEFAULT_FILL = false;
DEFAULT_LINE_WIDTH = 1;
DEFAULT_SHAD = 0.4;
isObj = true;
[reg,~,plObj,isNewFigure,isFill,lineWidth,colorVec,shadVec,priorHold,...
    postHold, isRelPlotterSpec,~,isIsFill,isLineWidth,...
    isColorVec,isShad,~,...
    isPostHold,]=...
    modgen.common.parseparext(varargin,...
    {'relDataPlotter','newFigure','fill','lineWidth','color','shade',...
    'priorHold','postHold';...
    [],0,[],[],[],0,false,false,...
    ;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
    @(x)isa(x,'logical'),@(x)(isa(x,'logical')||isa(x,'double')),...
    @(x)isa(x,'double'),...
    @(x)isa(x,'double'),...
    @(x)isa(x,'double'), @(x)isa(x,'logical'),@(x)isa(x,'logical'),...
    });
checkIsWrongInput();
%
if ~isRelPlotterSpec
    if isNewFigure
        plObj=smartdb.disp.RelationDataPlotter();
    else
        plObj=smartdb.disp.RelationDataPlotter('figureGetNewHandleFunc',...
            @(varargin)gcf,'axesGetNewHandleFunc',@axesGetNewHandleFunc,...
            'axesRearrangeFunc',@axesRearrangeFunc);
    end
end
%
[bodyArr, uColorVec, vColorVec, isCharColor] = getParams(reg);
if isCharColor && isColorVec
    isColorVec = false;
end
%
dimVec = fDim(bodyArr);
nDim = max(dimVec);
if nDim == 3 && isLineWidth
    throwerror('wrongProperty', 'LineWidth is not supported by 3D objects');
end
checkDimensions();
prepareForPlot();
%
hFigure = get(0,'CurrentFigure');
if isempty(hFigure)
    isHold=false;
else
    hAx = get(hFigure,'currentaxes');
    if isempty(hAx)
        isHold=false;
    else
        if ~ishold(hAx)
            if priorHold
                isHold = true;
            else
                if ~isRelPlotterSpec
                    cla;
                end
                isHold = false;
            end
        else
            isHold = true;
        end
    end
end
if isPostHold
    if postHold
        postFun = @axesSetPropDoNothingFunc;
    else
        postFun = @axesSetPropDoNothing2Func;
    end
else
    if isHold
        postFun = @axesSetPropDoNothingFunc;
    else
        postFun = @axesSetPropDoNothing2Func;
    end
end
%
if isObj
    rel=smartdb.relations.DynamicRelation(SData);
    isDimLEQ2Vec = rel.nDimMat <= 2;
    isDimGEQ3Vec = rel.nDimMat >= 3;
    if any(isDimLEQ2Vec)
        plObj.plotGeneric(rel.getTuples(isDimLEQ2Vec),...
            @figureGetGroupNameFunc,{'figureNameCMat'},...
            @figureSetPropFunc,{},...
            @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
            @axesSetPropDoNothingFunc,{},...
            @plotCreateFillPlotFunc,...
            {'xCMat','faceCMat','clrVec','fill','shadVec', ...
            'widVec','plotPatch'},...
            'axesPostPlotFunc',postFun,...
            'isAutoHoldOn',false);
    end
    if any(isDimGEQ3Vec)
        plObj.plotGeneric(rel.getTuples(isDimGEQ3Vec),...
            @figureGetGroupNameFunc,{'figureNameCMat'},...
            @figureSetPropFunc,{},...
            @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
            @axesSetPropDoNothingFunc,{},...
            @plotCreatePatchFunc,...
            {'verCMat','faceCMat','faceVertexCDataCMat',...
            'shadVec','clrVec','plotPatch',...
            },'axesPostPlotFunc',postFun,...
            'isAutoHoldOn',false);
    end
end
    function prepareForPlot()
        %
        [xCMat,fCMat,nDimMat] = calcBodyPoints(bodyArr);
        %
        if numel(cell2mat(xCMat)) > 0
            %
            bodyPlotNum = numel(xCMat);
            uColorVec = uColorVec(1:bodyPlotNum);
            vColorVec = vColorVec(1:bodyPlotNum,:);
            [colorVec, shadVec, lineWidth, isFill] = ...
                getPlotParams(colorVec, shadVec,...
                lineWidth, isFill,bodyPlotNum);
            checkIsWrongParams();
            SData = setUpSData();
            if isNewFigure
                [SData.figureNameCMat, SData.axesNameCMat] =...
                    arrayfun(@(x)getSDataParams(x), (1:bodyPlotNum).',...
                    'UniformOutput', false);
            else
                SData.figureNameCMat=repmat({'figure'},bodyPlotNum,1);
                import elltool.plot.common.AxesNames;
                SData.axesNameCMat = cell(bodyPlotNum,1);
                SData.axesNameCMat(nDimMat >= 3) = {AxesNames.AXES_3D_KEY};
                SData.axesNameCMat(nDimMat < 3) = {AxesNames.AXES_2D_KEY};
            end
            %
            clrCVec = cellfun(@(x, y, z) getColor(x, y, z),...
                num2cell(colorVec, 2), ...
                num2cell(vColorVec, 2), num2cell(uColorVec),...
                'UniformOutput', false);
            %
            SData.verCMat = xCMat;
            SData.xCMat = xCMat;
            SData.faceCMat = fCMat;
            SData.clrVec = clrCVec;
            SData.nDimMat = nDimMat;
            colCMat = cellfun(@(x) getColCMat(x), clrCVec, ...
                'UniformOutput', false);
            SData.faceVertexCDataCMat = colCMat;
        else
            isObj = false;
        end
        function colCMat = getColCMat(clrVec)
            colCMat = clrVec(ones(1, size(xCMat{1}, 2)), :);
        end
        function [figureNameCMat, axesNameCMat] = getSDataParams(iEll)
            figureNameCMat = sprintf('figure%d',iEll);
            axesNameCMat = sprintf('ax%d',iEll);
        end
        function clrVec = getColor(colorVec, vColor, uColor)
            if uColor == 1
                clrVec = vColor;
            else
                clrVec = colorVec;
            end
        end
        function SData = setUpSData()
            SData.axesNumCMat = repmat({1},bodyPlotNum,1);
            SData.plotPatch = repmat({fPlotPatch},bodyPlotNum,1);
            SData.figureNumCMat = repmat({1},bodyPlotNum,1);
            SData.widVec = lineWidth.';
            SData.shadVec = shadVec.';
            SData.fill = (isFill)';
            SData.clrVec = colorVec;
        end
    end
    %
    function checkDimensions()
        import elltool.conf.Properties;
        import modgen.common.throwerror;
        mDim = min(dimVec);
        nDim = max(dimVec);
        if (mDim < 1) || (nDim > 3)
            throwerror('wrongDim','object dimension can be 1, 2 or 3');
        end
        if Properties.getIsVerbose()
            if bodyPlotNum == 1
                fprintf('Plotting object...\n');
            else
                fprintf('Plotting %d objects...\n', bodyPlotNum);
            end
        end
    end
    %
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
%
    function [colorVec, shade, lineWidth, isFill] = ...
            getPlotParams(colorVec, shade, lineWidth, isFill,bodyPlotNum)
        shade = getPlotInitParam(shade, isShad, DEFAULT_SHAD);
        lineWidth = getPlotInitParam(lineWidth, ...
            isLineWidth, DEFAULT_LINE_WIDTH);
        isFill = getPlotInitParam(isFill, isIsFill, DEFAULT_FILL);
        colorVec = getColorVec(colorVec);
        function outParamVec = getPlotInitParam(inParamArr, ...
                isFilledParam, multConst)
            import modgen.common.throwerror;
            if ~isFilledParam
                outParamVec = multConst*ones(1, bodyPlotNum);
            else
                nParams = numel(inParamArr);
                if nParams == 1
                    outParamVec = inParamArr*ones(1, bodyPlotNum);
                else
                    if nParams ~= bodyPlotNum
                        throwerror('wrongParamsNumber',...
                            'Number of params is not equal to number of objects');
                    end
                    outParamVec = reshape(inParamArr, 1, nParams);
                end
            end
        end
        function colorArr = getColorVec(colorArr)
            import modgen.common.throwerror;
            if ~isColorVec
                auxcolors  = hsv(bodyPlotNum);
                multiplier = 7;
                if mod(size(auxcolors, 1), multiplier) == 0
                    multiplier = multiplier + 1;
                end
                colCell = arrayfun(@(x) auxcolors(mod(x*multiplier, ...
                    size(auxcolors, 1)) + 1, :), 1:bodyPlotNum,...
                    'UniformOutput', false);
                colorsArr = vertcat(colCell{:});
                colorsArr = flipud(colorsArr);
                colorArr = colorsArr;
            else
                if size(colorArr, 1) ~= bodyPlotNum
                    if size(colorArr, 1) ~= 1
                        throwerror('wrongColorVecSize',...
                            'Wrong size of color array');
                    else
                        colorArr = repmat(colorArr, bodyPlotNum, 1);
                    end
                end
            end
        end
    end
    %
    function checkIsWrongInput()
        import modgen.common.throwerror;
        cellfun(@(x)checkIfNoColorCharPresent(x),reg);
        cellfun(@(x)checkRightPropName(x),reg);
        %
        function checkIfNoColorCharPresent(value)
            import modgen.common.throwerror;
            if ischar(value)&&(numel(value)==1)&&~isColorDef(value)
                throwerror('wrongColorChar', ...
                    'You can''t use this symbol as a color');
            end
            function isColor = isColorDef(value)
                isColor = eq(value, 'r') | eq(value, 'g') | ...
                    eq(value, 'b') | ...
                    eq(value, 'y') | eq(value, 'c') | ...
                    eq(value, 'm') | eq(value, 'w')| eq(value, 'k');
            end
        end
        %
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
            elseif ~fIsObjClassName(value) && ~ischar(value)
                throwerror('wrongPropertyType',...
                    'Property must be a string.');
            end
            function isRProp = isRightProp(value)
                isRProp = strcmpi(value, 'fill') |...
                    strcmpi(value, 'linewidth') | ...
                    strcmpi(value, 'shade') | strcmpi(value, 'color') | ...
                    strcmpi(value, 'newfigure');
            end
        end
    end
    function [ellsArr,  uColorVec, vColorVec, isCharColor] = ...
            getParams(reg)
        import modgen.common.throwerror;
        BLACK_COLOR = [0, 0, 0];
        if numel(reg) == 1
            isnLastElemCMat = {0};
        else
            isnLastElemCMat = num2cell([ones(1, numel(reg)-1), 0]);
        end
        if ischar(reg{1})
            throwerror('wrongColorChar', 'Color char can''t be the first');
        end
        isCharColor = false;
        [ellsCMat, uColorCMat, vColorCMat] = ...
            cellfun(@(x, y, z)getParamsInternal(x, y, z),...
            reg, {reg{2:end}, []}, isnLastElemCMat, 'UniformOutput', false);
        uColorVec = vertcat(uColorCMat{:});
        vColorVec = vertcat(vColorCMat{:});
        ellsArr = vertcat(ellsCMat{:});
        %
        function [ellVec, uColorVec, vColorVec] = getParamsInternal(ellArr, ...
                nextObjArr, isnLastElem)
            import modgen.common.throwerror;
            if fIsObjClassName(ellArr)
                cnt    = numel(ellArr);
                ellVec = reshape(ellArr, cnt, 1);
                
                if isnLastElem && ischar(nextObjArr)
                    isCharColor = true;
                    colorVec1 = elltool.plot.colorcode2rgb(nextObjArr);
                    val = 1;
                else
                    colorVec1 = BLACK_COLOR;
                    val = 0;
                end
                uColorVec = repmat(val, cnt, 1);
                vColorVec = repmat(colorVec1, cnt, 1);
            else
                ellVec = [];
                uColorVec = [];
                vColorVec = [];
                if ischar(ellArr) && ischar(nextObjArr)
                    throwerror('wrongColorChar', ...
                        'Wrong combination of color chars');
                end
            end
        end
    end
end
%
function hAxes=axesGetNewHandleFunc(~,...
            nSurfaceRows,nSurfaceColumns,...
            indAxes,hFigureParent,~)
hAxesVec=findobj(get(hFigureParent,'Children'),'Type','axes');
if numel(hAxesVec)==1
    if nSurfaceRows==1&&nSurfaceColumns==1
        hAxes=hAxesVec;
        return;
    end
end
hAxes=subplot(nSurfaceRows,nSurfaceColumns,...
    indAxes,'Parent',hFigureParent);
end
%
function axesRearrangeFunc(hAxes,~,...
    nSurfaceRows,nSurfaceColumns,...
    indAxes,hFigureParent,~)
subplot(nSurfaceRows,nSurfaceColumns,...
    indAxes,hAxes,'Parent',hFigureParent);
end
%
function hVec=plotCreateFillPlotFunc(hAxes,X,faces,clrVec,isFill,...
    shade,widVec,plotPatch,varargin)
if ~isFill
    shade = 0;
end
hVec = plotPatch('Vertices',X','Faces',faces,'Parent',hAxes,...
    'EdgeColor', clrVec, 'LineWidth', widVec,'FaceAlpha',shade,...
    'FaceColor',clrVec);
view(hAxes,2);
end
%
function figureSetPropFunc(hFigure,figureName,~)
set(hFigure,'Name',figureName);
end
%
function figureGroupName=figureGetGroupNameFunc(figureName)
figureGroupName=figureName;
end
%
function hVec=axesSetPropDoNothingFunc(hAxes,~)
if (isempty(hAxes.UserData))
    initializeUserData(hAxes);
end
axis(hAxes,'on');
axis(hAxes,'auto');
grid(hAxes,'on');
hold(hAxes,'on');

setDisplayName(hAxes);
hVec=[];
if strcmp(get(get(hAxes, 'XLabel'), 'String'), '')
    set(get(hAxes, 'XLabel'), 'String', 'x_1', 'Interpreter', 'tex');
    hVec=[hVec, get(hAxes, 'XLabel')];
end
if strcmp(get(get(hAxes, 'YLabel'), 'String'), '')
    set(get(hAxes, 'YLabel'), 'String', 'x_2', 'Interpreter', 'tex');
    hVec=[hVec, get(hAxes, 'YLabel')];
end
if strcmp(get(get(hAxes, 'ZLabel'), 'String'), '')
    set(get(hAxes, 'ZLabel'), 'String', 'x_3', 'Interpreter', 'tex');
    hVec=[hVec, get(hAxes, 'ZLabel')];
end
end
%
function hVec=axesSetPropDoNothing2Func(hAxes,~)
if (isempty(hAxes.UserData))
    initializeUserData(hAxes);
end
axis(hAxes,'on');
axis(hAxes,'auto');
grid(hAxes,'on');
hold(hAxes,'off');

setDisplayName(hAxes);
hVec=[];
if strcmp(get(get(hAxes, 'XLabel'), 'String'), '')
    set(get(hAxes, 'XLabel'), 'String', 'x_1', 'Interpreter', 'tex');
    hVec=[hVec, get(hAxes, 'XLabel')];
end
if strcmp(get(get(hAxes, 'YLabel'), 'String'), '')
    set(get(hAxes, 'YLabel'), 'String', 'x_2', 'Interpreter', 'tex');
    hVec=[hVec, get(hAxes, 'YLabel')];
end
if strcmp(get(get(hAxes, 'ZLabel'), 'String'), '')
    set(get(hAxes, 'ZLabel'), 'String', 'x_3', 'Interpreter', 'tex');
    hVec=[hVec, get(hAxes, 'ZLabel')];
end
end
%
function initializeUserData(hAxes)
    hAxes.UserData = struct('counter', 0);
end
%
function setDisplayName(hAxes)
childVec=get(hAxes,'Children');
for ind = length(childVec):-1:1
    if (~isprop(childVec(ind),'Annotation'))
        continue;
    end
    isAnnotation=childVec(ind).Annotation.LegendInformation.IconDisplayStyle;
    if (strcmp(isAnnotation,'on'))
        if (isempty(childVec(ind).DisplayName))
            newCounter=hAxes.UserData.counter+1;
            childVec(ind).DisplayName=num2str(newCounter);
            hAxes.UserData.counter=newCounter;
        end
    end
end
set(hAxes, 'Children', childVec);
end
%
function axesName=axesGetNameSurfFunc(name,~)
axesName=name;
end
%
function hVec=plotCreatePatchFunc(hAxes,vertices,faces,...
    faceVertexCData,faceAlpha,clrVec,plotPatch)
import modgen.graphics.camlight;
LIGHT_TYPE_LIST={{'left'},{40,-65},{-20,25}};
hVec = plotPatch('Vertices',vertices', 'Faces', faces, ...
    'FaceVertexCData', faceVertexCData, 'FaceColor','flat', ...
    'FaceAlpha', faceAlpha,'EdgeColor',clrVec,'Parent',hAxes);
hLightList=cellfun(@(x)camlight(hAxes,x{:}),LIGHT_TYPE_LIST,...
    'UniformOutput',false);
hVec=[hVec,hLightList{:}];
if size(vertices,2) > 1
    shading(hAxes,'interp');
end
lighting(hAxes,'phong');
material(hAxes,'metal');
view(hAxes,3);
end