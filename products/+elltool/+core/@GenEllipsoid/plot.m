function plObj = plot(varargin)
%
% PLOT - plots General Ellipsoids in 2D or 3D.
%
%
% Description:
% ------------
%
% PLOT(E, 'Property',PropValue) plots ellipsoid E if 2 <= dimension(E) <= 3.
%
%                  PLOT(E)  Plots E in default (red) color.
%              PLOT(EA, E)  Plots array of ellipsoids EA and single ellipsoid E.
%   PLOT(E1, 'g', E2, 'b')  Plots E1 in green and E2 in blue color.
%        PLOT(EA, 'Property',PropValue)  Plots EA  by setting properties.
%
% Properties:
% 'newFigure'    - if 1, each plot command will open a new figure window.
% 'fill'         - if 1, ellipsoids in 2D will be filled with color.
% 'lineWidth'        - line width for 1D and 2D plots.
% 'color'        - sets default colors in the form [x y z].
% 'shade' = 0-1  - level of transparency (0 - transparent, 1 - opaque).
%  'relDataPlotter' - relation data plotter object
%
% Output:
% -------
%
%     plObj - returns the relation data plotter object
%

%
% Author:
% -------
%
%    $Author: Vadim Kaushanskiy  <vkaushanskiy@gmail.com> $    $Date: 21-December-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
%
import elltool.conf.Properties;
import modgen.common.throwerror;
import elltool.core.GenEllipsoid;
N_PLOT_POINTS = 500;
SPHERE_TRIANG_CONST = 5;
DEFAULT_LINE_WIDTH = 1;
DEFAULT_SHAD = 0.4;
DEFAULT_FILL = 0;

[reg,~,plObj,isNewFigure,isFill,lineWidth,colorVec,shadVec,...
    isRelPlotterSpec,~,isIsFill,isLineWidth,isColorVec,isShad]=modgen.common.parseparext(varargin,...
    {'relDataPlotter','newFigure','fill','lineWidth','color','shade';...
    [],0,[],[],[],0;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
    @(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x)});


if ~isRelPlotterSpec
    if isNewFigure
        plObj=smartdb.disp.RelationDataPlotter();
    else
        plObj=smartdb.disp.RelationDataPlotter('figureGetNewHandleFunc', @(varargin)gcf,'axesGetNewHandleFunc',@(varargin)gca);
    end
end
[ellsArr, ellNum, uColorVec, vColorVec] = getEllParams(reg);
nDim = max(dimension(ellsArr));
[lGetGridMat, fGetGridMat] = calcGrid();
[colorVec, shadVec, lineWidth, isFill] = getPlotParams(colorVec, shadVec,... 
    lineWidth, isFill);
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
elseif ~ishold
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
            [SData.figureNameCMat, SData.axesNameCMat] = arrayfun(@(x)getSDataParams(x), (1:ellNum).', 'UniformOutput', false);
            
        end
        [xMat, fMat] = arrayfun(@(x) calcOneEllElem(x), ellsArr, 'UniformOutput', false);
        colMat = cellfun(@(x, y, z) getColor(x, y, z), num2cell(colorVec, 2), ...
            num2cell(vColorVec, 2), num2cell(uColorVec), 'UniformOutput', false);
        SData.verCMat = xMat;
        SData.xCMat = xMat;
        SData.faceCMat = fMat;
        SData.faceVertexCDataCMat = colMat;
        SData.qCMat = arrayfun(@(x) {x.getCenter()}, ellsArr);
        function colMat = getColor(colorVec, vColor, uColor)
            if uColor == 1
                clrVec = vColor;
            else
                clrVec = colorVec;
            end
            colMat = clrVec(ones(1, size(xMat{1}, 2)), :);
      
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
        SData.fill = (isFill~=0)';
        SData.clrVec = colorVec;
    end
    function checkDimensions()
        import elltool.conf.Properties;
        ellsArrDims = dimension(ellsArr);
        mDim    = min(ellsArrDims);
        nDim    = max(ellsArrDims);
        if mDim ~= nDim
            throwerror('dimMismatch','Ellipsoids must be of the same dimension.');
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
    function [colorVec, shad, lineWidth, isFill] = getPlotParams(colorVec, shad, lineWidth, isFill)
        
        shad = getPlotInitParam(shad, isShad, DEFAULT_SHAD);
        lineWidth = getPlotInitParam(lineWidth, isLineWidth, DEFAULT_LINE_WIDTH);
        isFill = getPlotInitParam(isFill, isIsFill, DEFAULT_FILL);
        colorVec = getColorVec(colorVec);
    end

    function outParamVec = getPlotInitParam(inParamArr, isFilledParam, multConst)
        if ~isFilledParam
            outParamVec = multConst*ones(1, ellNum);
        else
            nParams = numel(inParamArr);
            if nParams == 1
                outParamVec = inParamArr*ones(1, ellNum);
            else
                outParamVec = reshape(inParamArr, 1, mDim);
                if nParams < ellNum
                    outParamVec = [outParamVec, multConst*ones(1, ellNum-mDim)];
                end
            end
        end
    end
 

    function colorArr = getColorVec(colorArr)
        
        if ~isColorVec
            % Color maps:
            %    hsv       - Hue-saturation-value color map.
            %    hot       - Black-red-yellow-white color map.
            %    gray      - Linear gray-scale color map.
            %    bone      - Gray-scale with tinge of blue color map.
            %    copper    - Linear copper-tone color map.
            %    pink      - Pastel shades of pink color map.
            %    white     - All white color map.
            %    flag      - Alternating red, white, blue, and black color map.
            %    lines     - Color map with the line colors.
            %    colorcube - Enhanced color-cube color map.
            %    vga       - Windows colormap for 16 colors.
            %    jet       - Variant of HSV.
            %    prism     - Prism color map.
            %    cool      - Shades of cyan and magenta color map.
            %    autumn    - Shades of red and yellow color map.
            %    spring    - Shades of magenta and yellow color map.
            %    winter    - Shades of blue and green color map.
            %    summer    - Shades of green and yellow color map.
            
            auxcolors  = hsv(ellNum);
            colorsArr     = auxcolors;
            multiplier = 7;
            if mod(size(auxcolors, 1), multiplier) == 0
                multiplier = multiplier + 1;
            end
            colCell = arrayfun(@(x) auxcolors(mod(x*multiplier, ...
                size(auxcolors, 1)) + 1, :), 1:ellNum, 'UniformOutput', false);
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
            [lGetGrid, fGetGrid] = gras.geom.tri.spheretri(SPHERE_TRIANG_CONST);
        end
        lGetGrid(lGetGrid == 0) = eps;
    end
    function [xMat, fMat] = ellPoints(ell, nDim)
        nPoints = size(lGetGridMat, 1);
        xMat = zeros(nDim, nPoints+1);
        dMat = ell.getDiagMat();
        qCenVec = ell.getCenter();
        xMat(:, 1:end-1) = dMat.^0.5*lGetGridMat.' + repmat(qCenVec, 1, nPoints);
        xMat(:, end) = xMat(:, 1);
        fMat = fGetGridMat;
    end

end


function hVec=plotCreateElPlotFunc(hAxes,X,q,clrVec,wid,varargin)
h1 = ell_plot(X,'Parent',hAxes);
set(h1, 'Color', clrVec, 'LineWidth', wid);
h2 = ell_plot(q, '.','Parent',hAxes);
set(h2, 'Color', clrVec);
hVec = [h1,h2];
end
function hVec=plotCreateEl2PlotFunc(hAxes,X,Y,q,clrVec,wid,varargin)
h1 = ell_plot([(X) (Y)],'Parent',hAxes);
set(h1, 'Color', clrVec, 'LineWidth', wid);
h2 = ell_plot(q, '*','Parent',hAxes);
set(h2, 'Color', clrVec);
hVec = [h1,h2];
end
function hVec=plotCreateFillPlotFunc(hAxes,X,q,clrVec,fil,shad,widVec,varargin)
if ~fil
    shad = 0;
end
h1 = ell_plot(q, '*','Parent',hAxes);
if fil == 1
    h2 = fill(X(1, :), X(2, :), clrVec,'FaceAlpha',shad,'Parent',hAxes);
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

function [ellsArr, ellNum, uColorVec, vColorVec] = getEllParams(reg)

if numel(reg) == 1
    isnLastElemCMat = {0};
else
    isnLastElemCMat = num2cell([ones(1, numel(reg)-1), 0]);
end

[ellsCMat, uColorCMat, vColorCMat] = cellfun(@(x, y, z)getParams(x, y, z), reg, {reg{2:end}, []}, isnLastElemCMat, 'UniformOutput', false);
uColorVec = vertcat(uColorCMat{:});
vColorVec = vertcat(vColorCMat{:});
ellsArr = vertcat(ellsCMat{:});
ellNum = numel(ellsArr);

    function [ellVec, uColorVec, vColorVec] = getParams(ellArr, ellNextObjArr, isnLastElem)
        import elltool.core.GenEllipsoid;
        if isa(ellArr, 'elltool.core.GenEllipsoid')
            cnt    = numel(ellArr);
            ellVec = reshape(ellArr, cnt, 1);
         
            if isnLastElem && ischar(ellNextObjArr)
                colorVec = GenEllipsoid.getColorTable(ellNextObjArr);
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
        end
    end
end



function [minValVec, maxValVec] = findMinAndMaxInEachDim(ellsArr)

nDim = max(dimension(ellsArr));
[minValVec, maxValVec] = arrayfun(@(x) findMinAndMaxDim(ellsArr, x, nDim), 1:nDim);


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
