function plObj = plot(varargin)
%
% PLOT - plots ellipsoids in 2D or 3D.
%
%
% Usage:
%       plot(ell) - plots generic ellipsoid ell in default (red) color.
%       plot(ellArr) - plots an array of generic ellipsoids.
%       plot(ellArr, 'Property',PropValue,...) - plots ellArr with setting 
%                                                properties.
%
% Input:
%   regular:
%       ellArr:  elltool.core.GenEllipsoid: [dim11Size,dim12Size,...,dim1kSize] - 
%                array of 2D or 3D GenEllipsoids objects. All ellipsoids in ellArr 
%                must be either 2D or 3D simutaneously.
%   optional:
%       color1Spec: char[1,1] - color specification code, can be 'r','g',
%                               etc (any code supported by built-in Matlab function).
%       ell2Arr: elltool.core.GenEllipsoid: [dim21Size,dim22Size,...,dim2kSize] -
%                                           second ellipsoid array...
%       color2Spec: char[1,1] - same as color1Spec but for ell2Arr
%       ....
%       ellNArr: elltool.core.GenEllipsoid: [dimN1Size,dim22Size,...,dimNkSize] - 
%                                            N-th ellipsoid array
%       colorNSpec - same as color1Spec but for ellNArr.
%   properties:
%       'newFigure': logical[1,1] - if 1, each plot command will open a new figure window.
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
% Output:
%   regular:
%       plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
%       data plotter object.
%
% Examples:
%       plot([ell1, ell2, ell3], 'color', [1, 0, 1; 0, 0, 1; 1, 0, 0]);
%       plot([ell1, ell2, ell3], 'color', [1; 0; 1; 0; 0; 1; 1; 0; 0]);
%       plot([ell1, ell2, ell3; ell1, ell2, ell3], 'shade', [1, 1, 1; 1, 1,
%       1]);
%       plot([ell1, ell2, ell3; ell1, ell2, ell3], 'shade', [1; 1; 1; 1; 1;
%       1]);
%       plot([ell1, ell2, ell3], 'shade', 0.5);
%       plot([ell1, ell2, ell3], 'lineWidth', 1.5);
%       plot([ell1, ell2, ell3], 'lineWidth', [1.5, 0.5, 3]);

% $Author: <Vadim Kaushanskiy>  <vkaushanskiy@gmail.com> $    $Date: <21 December 2012> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $

import elltool.conf.Properties;
import modgen.common.throwerror;
import elltool.core.GenEllipsoid;
N_PLOT_POINTS = 80;
SPHERE_TRIANG_CONST = 3;
DEFAULT_LINE_WIDTH = 1;
DEFAULT_SHAD = 0.4;
DEFAULT_FILL = false;

[reg,~,plObj,isNewFigure,isFill,lineWidth,colorVec,shadVec,...
    isRelPlotterSpec,~,isIsFill,isLineWidth,isColorVec,isShad]=modgen.common.parseparext(varargin,...
    {'relDataPlotter','newFigure','fill','lineWidth','color','shade' ;...
    [],0,[],[],[],0;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
    @(x)isa(x,'logical'),@(x)isa(x,'logical'),@(x)isa(x,'double'),@(x)isa(x,'double'),...
    @(x)isa(x,'double')});
checkIsWrongInput();
if ~isRelPlotterSpec
    if isNewFigure
        plObj=smartdb.disp.RelationDataPlotter();
    else
        plObj=smartdb.disp.RelationDataPlotter('figureGetNewHandleFunc',...
            @(varargin)gcf,'axesGetNewHandleFunc',@(varargin)gca);
    end
end
[ellsArr, ellNum, uColorVec, vColorVec, isCharColor] = getEllParams(reg);
if isCharColor && isColorVec
    throwerror('ConflictingColor', 'Conflicting using of color property');
end
nDim = max(dimension(ellsArr));
if nDim == 3 && isLineWidth
    throwerror('wrongProperty', 'LineWidth is not supported by 3D Ellipsoids');
end
[lGetGridMat, fGetGridMat] = calcGrid();
[colorVec, shadVec, lineWidth, isFill] = getPlotParams(colorVec, shadVec,...
    lineWidth, isFill);
checkIsWrongParams();
checkDimensions();
SData = setUpSData();
[minValVec, maxValVec] = findMinAndMaxInEachDim(ellsArr);
minValVec = reshape(minValVec, numel(minValVec), 1);
maxValVec = reshape(maxValVec, numel(maxValVec), 1);
calcEllPoints();


rel=smartdb.relations.DynamicRelation(SData);
hFigure = get(0,'CurrentFigure');
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
else
    plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
        @figureSetPropFunc,{},...
        @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
        @axesSetPropDoNothingFunc,{},...
        @plotCreateEl2PlotFunc,...
        {'xCMat','qCMat','clrVec','widVec'});
end
if  isHold
    hold on;
else
    hold off;
end
    function calcEllPoints()
        import elltool.core.GenEllipsoid;
        if isNewFigure
            [SData.figureNameCMat, SData.axesNameCMat] =...
                arrayfun(@(x)getSDataParams(x), (1:ellNum).',...
                'UniformOutput', false);
            
        end
        [xMat, fMat] = arrayfun(@(x) calcOneEllElem(x), ellsArr, ...
            'UniformOutput', false);
        clrCVec = cellfun(@(x, y, z) getColor(x, y, z),...
            num2cell(colorVec, 2), ...
            num2cell(vColorVec, 2), num2cell(uColorVec),...
            'UniformOutput', false);
        SData.verCMat = xMat;
        SData.xCMat = xMat;
        SData.faceCMat = fMat;
        SData.clrVec = clrCVec;
        colCMat = cellfun(@(x) getColCMat(x), clrCVec, ...
            'UniformOutput', false);
        SData.faceVertexCDataCMat = colCMat;
        SData.qCMat = arrayfun(@(x) {x.getCenter()}, ellsArr);
        function clrVec = getColor(colorVec, vColor, uColor)
            if uColor == 1
                clrVec = vColor;
            else
                clrVec = colorVec;
            end
            
        end
        function colCMat = getColCMat(clrVec)
            colCMat = clrVec(ones(1, size(xMat{1}, 2)), :);
        end
        function [xMat, fMat] = calcOneEllElem(plotEll)
            import elltool.core.GenEllipsoid;
            qVec = plotEll.getCenter();
            diagMat = plotEll.getDiagMat();
            eigvMat = plotEll.getEigvMat();
            ell = GenEllipsoid(diagMat);
            
            [xMat, fMat] = ellPoints(ell, nDim);
            nPoints = size(xMat, 2);
            xMat = getRidOfInfVal(xMat, qVec);
            xMat = eigvMat.'*xMat + repmat(qVec, 1, nPoints);
        end
        function [figureNameCMat, axesNameCMat] = getSDataParams(iEll)
            figureNameCMat = sprintf('figure%d',iEll);
            axesNameCMat = sprintf('ax%d',iEll);
        end
        function xMat = getRidOfInfVal(xMat, qVec)
            maxVec = maxValVec - qVec;
            minVec=minValVec-qVec;
            isInfMat=xMat==Inf;
            isNegInfMat=xMat==-Inf;
            maxMat=repmat(maxVec,1,size(xMat, 2));
            minMat=repmat(minVec,1,size(xMat, 2));
            xMat(isInfMat)=maxMat(isInfMat);
            xMat(isNegInfMat)=minMat(isNegInfMat);
        end
    end

    function SData = setUpSData()
        SData.figureNameCMat=repmat({'figure'},ellNum,1);
        SData.axesNameCMat = repmat({'ax'},ellNum,1);
        SData.axesNumCMat = repmat({1},ellNum,1);
        
        SData.figureNumCMat = repmat({1},ellNum,1);
        
        SData.widVec = lineWidth.';
        SData.shadVec = shadVec.';
        SData.fill = (isFill)';
        SData.clrVec = colorVec;
    end
    function checkDimensions()
        import elltool.conf.Properties;
        ellsArrDims = dimension(ellsArr);
        mDim    = min(ellsArrDims);
        nDim    = max(ellsArrDims);
        if mDim ~= nDim
            throwerror('dimMismatch', ...
                'Ellipsoids must be of the same dimension.');
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
        if ~isFilledParam
            outParamVec = multConst*ones(1, ellNum);
        else
            nParams = numel(inParamArr);
            if nParams == 1
                outParamVec = inParamArr*ones(1, ellNum);
            else
                if nParams ~= ellNum
                    import modgen.common.throwerror;
                    throwerror('wrongParamsNumber',...
                        'Number of params is not equal to number of ellipsoids');
                end
                outParamVec = reshape(inParamArr, 1, nParams);
            end
        end
    end


    function colorArr = getColorVec(colorArr)
        
        if ~isColorVec
            auxcolors  = hsv(ellNum);
            multiplier = 7;
            if mod(size(auxcolors, 1), multiplier) == 0
                multiplier = multiplier + 1;
            end
            colCell = arrayfun(@(x) auxcolors(mod(x*multiplier, ...
                size(auxcolors, 1)) + 1, :), 1:ellNum, 'UniformOutput',...
                false);
            colorsArr = vertcat(colCell{:});
            colorsArr = flipud(colorsArr);
            colorArr = colorsArr;
        else
            if size(colorArr, 1) ~= ellNum
                if size(colorArr, 1) > ellNum
                    colorArr = colorArr(1:ellNum, :);
                else
                    colorArr = repmat(colorArr, ellNum, 1);
                end
            end
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
    function [xMat, fMat] = ellPoints(ell, nDim)
        nPoints = size(lGetGridMat, 1);
        xMat = zeros(nDim, nPoints+1);
        dMat = ell.getDiagMat();
        qCenVec = ell.getCenter();
        xMat(:, 1:end-1) = dMat.^0.5*lGetGridMat.' + ...
            repmat(qCenVec, 1, nPoints);
        xMat(:, end) = xMat(:, 1);
        fMat = fGetGridMat;
    end
    function checkIsWrongParams()
        import modgen.common.throwerror;
        if any(lineWidth <= 0) || any(isnan(lineWidth)) || any(isinf(lineWidth))
            throwerror('wrongLineWidth', 'LineWidth must be greater than 0 and finite');
        end
        if (any(shadVec < 0)) || (any(shadVec > 1)) || any(isnan(shadVec)) || any(isinf(shadVec))
            throwerror('wrongShade', 'Shade must be between 0 and 1');
        end
        if (any(colorVec(:) < 0)) || (any(colorVec(:) > 1)) || any(isnan(colorVec(:))) || any(isinf(colorVec(:)))
            throwerror('wrongColorVec', 'Color must be between 0 and 1');
        end
        if size(colorVec, 2) ~= 3
            throwerror('wrongColorVecSize', ...
                'ColorVec is a vector of length 3');
        end
    end
    function checkIsWrongInput()
        import modgen.common.throwerror;
        rNum = 0; gNum = 0; bNum = 0; yNum = 0; cNum = 0; wNum = 0;
        cellfun(@(x)checkIfNoColorCharPresent(x),reg);
        cellfun(@(x)checkRightPropName(x),reg);
   
        function checkIfNoColorCharPresent(value)
            import modgen.common.throwerror;
            if ischar(value)&&(numel(value)==1)&&~isColorDef(value)
                import modgen.common.throwerror;
                throwerror('wrongColorChar', ...
                    'You can''t use this symbol as a color');
            end
            function isColor = isColorDef(value)
                isColor = eq(value, 'r') | eq(value, 'g') | eq(value, 'b') | ...
                    eq(value, 'y') | eq(value, 'c') | ...
                    eq(value, 'm') | eq(value, 'w');
            end
        end
        function checkRightPropName(value)
            if ischar(value)&&(numel(value)>1)&&~isRightProp(value)
                import modgen.common.throwerror;
                throwerror('wrongProperty', 'This property doesn''t exist');
            end
            function isRProp = isRightProp(value)
                isRProp = strcmp(value, 'fill') | strcmp(value, 'linewidth') | ...
                    strcmp(value, 'shade') | strcmp(value, 'color') | ...
                    strcmp(value, 'newfigure');
            end
        end
    end

end

function hVec=plotCreateEl2PlotFunc(hAxes,X,Y,q,clrVec,wid,varargin)
h1 = ell_plot([(X) (Y)],'Parent',hAxes);
set(h1, 'Color', clrVec, 'LineWidth', wid);
h2 = ell_plot(q, '*','Parent',hAxes);
set(h2, 'Color', clrVec);
hVec = [h1,h2];
end
function hVec=plotCreateFillPlotFunc(hAxes,X,q,clrVec,fil,shade,widVec,varargin)
if ~fil
    shade = 0;
end
h1 = ell_plot(q, '*','Parent',hAxes);
if fil == 1
    h2 = fill(X(1, :), X(2, :), clrVec,'FaceAlpha',shade,'Parent',hAxes);
end
h3 = ell_plot(X,'Parent',hAxes);

set(h1, 'Color', clrVec);
set(h3, 'Color', clrVec, 'LineWidth', widVec);
if fil == 1
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

function [ellsArr, ellNum, uColorVec, vColorVec, isCharColor] = getEllParams(reg)

if numel(reg) == 1
    isnLastElemCMat = {0};
else
    isnLastElemCMat = num2cell([ones(1, numel(reg)-1), 0]);
end
if ischar(reg{1})
    import modgen.common.throwerror;
    throwerror('wrongColorChar', 'Color char can''t be the first');
end
isCharColor = false;
[ellsCMat, uColorCMat, vColorCMat] = cellfun(@(x, y, z)getParams(x, y, z),...
    reg, {reg{2:end}, []}, isnLastElemCMat, 'UniformOutput', false);
uColorVec = vertcat(uColorCMat{:});
vColorVec = vertcat(vColorCMat{:});
ellsArr = vertcat(ellsCMat{:});
ellNum = numel(ellsArr);

    function [ellVec, uColorVec, vColorVec] = getParams(ellArr, ...
            nextObjArr, isnLastElem)
        import elltool.core.GenEllipsoid;
        if isa(ellArr, 'elltool.core.GenEllipsoid')
            cnt    = numel(ellArr);
            ellVec = reshape(ellArr, cnt, 1);
            
            if isnLastElem && ischar(nextObjArr)
                isCharColor = true;
                colorVec = GenEllipsoid.getColorTable(nextObjArr);
                val = 1;
            else
                colorVec = [0 0 0];
                val = 0;
            end
            uColorVec = repmat(val, cnt, 1);
            vColorVec = repmat(colorVec, cnt, 1);
        else
            ellVec = [];
            uColorVec = [];
            vColorVec = [];
            if ischar(ellArr) && ischar(nextObjArr)
                import modgen.common.throwerror;
                throwerror('wrongColorChar', 'Wrong combination of color chars');
            end
        end
    end
end



function [minValVec, maxValVec] = findMinAndMaxInEachDim(ellsArr)

nDim = max(dimension(ellsArr));
[minValVec, maxValVec] = arrayfun(@(x) findMinAndMaxDim(ellsArr, x, nDim),...
    1:nDim);


    function [minValVec, maxValVec] = findMinAndMaxDim(ellVec, dirDim, nDims)
        import elltool.core.GenEllipsoid;
        
        minlVec = zeros(nDims, 1);
        minlVec(dirDim) = -1;
        maxlVec = zeros(nDims, 1);
        maxlVec(dirDim) = 1;
        [minValVec, maxValVec] = arrayfun(@(x)findMinAndMaxDimEll(x), ellVec);
        minValVec = min(minValVec);
        maxValVec = max(maxValVec);
        
        function [minVal, maxVal] = findMinAndMaxDimEll(ell)
            import elltool.core.GenEllipsoid;
            qCenVec = ell.getCenter();
            dMat = ell.getDiagMat();
            ell = GenEllipsoid(qCenVec, dMat);
            minVal = Inf;
            maxVal = -Inf;
            
            [~, curEllMax] = rho(ell, maxlVec);
            [~, curEllMin] = rho(ell, minlVec);
            if (curEllMin(dirDim) < minVal)&& (curEllMin(dirDim) > -Inf)
                minVal = curEllMin(dirDim);
            end
            if (curEllMax(dirDim) > maxVal) && (curEllMax(dirDim) < Inf)
                maxVal = curEllMax(dirDim);
            end
            diagVec = diag(dMat);
            maxEig = max(diagVec(diagVec < Inf));
            if (-3*maxEig+qCenVec(dirDim) < minVal) && (curEllMin(dirDim) == -Inf)
                minVal = -3*maxEig+qCenVec(dirDim);
            end
            if (3*maxEig+qCenVec(dirDim) > maxVal) && (curEllMax(dirDim) == Inf)
                maxVal = 3*maxEig+qCenVec(dirDim);
            end
        end
    end
end
