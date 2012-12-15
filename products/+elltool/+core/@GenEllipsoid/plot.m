function plObj = plot(varargin)

import elltool.conf.Properties;
import modgen.common.throwerror;
import elltool.core.GenEllipsoid;
N_PLOT_POINTS = 500;
SPHERE_TRIANG_CONST = 5;
isHold = ishold;
[reg,~,plObj,isNewFigure,isFill,lineWidth,colorVec,shad,...
    isRelPlotterSpec,~,isIsFill,isLineWidth,isColorVec,isShad]=modgen.common.parseparext(varargin,...
    {'relDataPlotter','newFigure','fill','lineWidth','color','shade';...
    [],0,[],[],[],0;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
    @(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x)});


if ~isRelPlotterSpec
        plObj=smartdb.disp.RelationDataPlotter('figureGetNewHandleFunc', @(varargin)gcf,'axesGetNewHandleFunc',@(varargin)gca);
end

[ellsArr, ellNum, uColor, vColor] = getEllParams(reg);
[colorVec, shad, lineWidth, isFill] = getPlotParams(colorVec, shad,... 
    lineWidth, isFill);
checkDimensions();
SData = setUpSData();
[minValVec, maxValVec] = findMinAndMaxInEachDim(ellsArr);
minValVec = reshape(minValVec, numel(minValVec), 1);
maxValVec = reshape(maxValVec, numel(maxValVec), 1);
calcEllPoints();


rel=smartdb.relations.DynamicRelation(SData);
if ~isHold
    cla;
end
if (nDim==2)
    if isFill(iEll) ~= 0
        plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
            @figureSetPropFunc,{},...
            @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
            @axesSetPropDoNothingFunc,{},...
            @plotCreateFillPlotFunc,...
            {'xCMat''clrVec','fill','shadVec'});
    end
    plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
        @figureSetPropFunc,{},...
        @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
        @axesSetPropDoNothingFunc,{},...
        @plotCreateElPlotFunc,...
        {'xCMat','qCMat','clrVec','widVec'});
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
        nDim = max(dimension(ellsArr));
        if isNewFigure
            [SData.figureNameCMat, SData.axesNameCMat] = arrayfun(@(x)getSDataParams(x), 1:ellNum);
        end
        [xMat, fMat] = arrayfun(@(x) calcOneEllElem(x), ellsArr, 'UniformOutput', false);
        colMat = cellfun(@(x, y, z) getColor(x, y, z), num2cell(colorVec, 2), ...
            num2cell(vColor, 2), num2cell(uColor), 'UniformOutput', false);
        SData.verCMat = xMat;
        SData.xCMat = xMat;
        SData.faceCMat = fMat;
        SData.faceVertexCDataCMat = colMat;
        SData.qCMat = arrayfun(@(x) {x.getCenter()}, ellsArr);
        function colMat = getColor(colorVec, vColor, uColor)
            if uColor == 1
                clr = vColor;
            else
                clr = colorVec;
            end
            colMat = clr(ones(1, size(xMat{1}, 2)), :);
      
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
        SData.shadVec = shad.';
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
        
        shad = getPlotInitParam(shad, isShad, 0.4);
        lineWidth = getPlotInitParam(lineWidth, isLineWidth, 1);
        isFill = getPlotInitParam(isFill, isFill, 0);
        colorVec = getColorVec(colorVec);
    end

    function outParam = getPlotInitParam(inParam, isFilledParam, multConst)
        if ~isFilledParam
            outParam = multConst*ones(1, ellNum);
        else
            [mDim, nDim] = size(inParam);
            mDim      = mDim * nDim;
            if mDim == 1
                outParam = inParam*ones(1, ellNum);
            else
                outParam = reshape(inParam, 1, mDim);
                if mDim < ellNum
                    outParam = [outParam, multConst*ones(1, ellNum-mDim)];
                end
            end
        end
    end
 

    function colorVec = getColorVec(colorVec)
        
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
            colors     = auxcolors;
            multiplier = 7;
            if mod(size(auxcolors, 1), multiplier) == 0
                multiplier = multiplier + 1;
            end
            for iEll = 1:ellNum
                jj = mod(iEll*multiplier, size(auxcolors, 1)) + 1;
                colors(iEll, :) = auxcolors(jj, :);
            end
            colors = flipud(colors);
            colorVec = colors;
        else
            if size(colorVec, 1) ~= ellNum
                if size(colorVec, 1) > ellNum
                    colorVec = colorVec(1:ellNum, :);
                else
                    colorVec = repmat(colorVec, ellNum, 1);
                end
            end
        end
        
        
    end
    function [xMat, fMat] = ellPoints(ell, nDim)
        if nDim == 2
            lMat = gras.geom.circlepart(N_PLOT_POINTS);
            fMat = 1:N_PLOT_POINTS+1;
        else
            [lMat, fMat] = gras.geom.tri.spheretri(SPHERE_TRIANG_CONST);
        end
        lMat(lMat == 0) = eps;
        nPoints = size(lMat, 1);
        xMat = zeros(nDim, nPoints+1);
        dMat = ell.getDiagMat();
        qCen = ell.getCenter();
        xMat(:, 1:end-1) = dMat.^0.5*lMat.' + repmat(qCen, 1, nPoints);
        xMat(:, end) = xMat(:, 1);
    end

end


function hVec=plotCreateElPlotFunc(hAxes,X,q,clr,wid,varargin)
h1 = ell_plot(X,'Parent',hAxes);
set(h1, 'Color', clr, 'LineWidth', wid);
h2 = ell_plot(q, '.','Parent',hAxes);
set(h2, 'Color', clr);
hVec = [h1,h2];
end
function hVec=plotCreateEl2PlotFunc(hAxes,X,Y,q,clr,wid,varargin)
h1 = ell_plot([(X) (Y)],'Parent',hAxes);
set(h1, 'Color', clr, 'LineWidth', wid);
h2 = ell_plot(q, '*','Parent',hAxes);
set(h2, 'Color', clr);
hVec = [h1,h2];
end
function hVec=plotCreateFillPlotFunc(hAxes,X,Y,clr,fil,shad,varargin)
if fil
    hVec = fill(X, Y, clr,'FaceAlpha',shad,'Parent',hAxes);
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
    faceVertexCData,faceAlpha,clr)
hVec = patch('Vertices',vertices', 'Faces', faces, ...
    'FaceVertexCData', faceVertexCData, 'FaceColor','flat', ...
    'FaceAlpha', faceAlpha,'EdgeColor',clr,'Parent',hAxes);
shading interp;
lighting phong;
material('metal');
view(3);
end

function [ellsArr, ellNum, uColor, vColor] = getEllParams(reg)

if numel(reg) == 1
    isnLastElemCMat = {0};
else
    isnLastElemCMat = num2cell([ones(1, numel(reg)-1), 0]);
end

[ellsArr, uColor, vColor] = cellfun(@(x, y, z)getParams(x, y, z), reg, {reg{2:end}, []}, isnLastElemCMat, 'UniformOutput', false);
uColor = vertcat(uColor{:});
vColor = vertcat(vColor{:});
ellsArr = vertcat(ellsArr{:});
ellNum = numel(ellsArr);

    function [ellVec, uColor, vColor] = getParams(ellArr, ellNextArr, isnLastElem)
        import elltool.core.GenEllipsoid;
        if isa(ellArr, 'elltool.core.GenEllipsoid')
            cnt    = numel(ellArr);
            ellVec = reshape(ellArr, cnt, 1);
         
            if isnLastElem && ischar(ellNextArr)
                colorVec = GenEllipsoid.colorTable(ellNextArr);
                val = 1;
            else
                colorVec = [0 0 0];
                val = 0;
            end
            uColor = repmat(val, cnt, 1);
            vColor = repmat(colorVec, cnt, 1);
        else
            ellVec = [];
            uColor = [];
            vColor = [];
        end
    end
end



function [minValVec, maxValVec] = findMinAndMaxInEachDim(ellsArr)

nDim = max(dimension(ellsArr));
[minValVec, maxValVec] = arrayfun(@(x, y) findMinAndMaxDim(ellsArr, x, y), 1:nDim, repmat(nDim, 1, nDim));


    function [minValVec, maxValVec] = findMinAndMaxDim(ellsArr, dirDim, nDims)
        import elltool.core.GenEllipsoid;

        minlVec = zeros(nDims, 1);
        minlVec(dirDim) = -1;
        maxlVec = zeros(nDims, 1);
        maxlVec(dirDim) = 1;
        [minValVec, maxValVec] = arrayfun(@(x)findMinAndMaxDimEll(x), ellsArr);
        minValVec = min(minValVec);
        maxValVec = max(maxValVec);
        
        function [minVal, maxVal] = findMinAndMaxDimEll(ell)
            import elltool.core.GenEllipsoid;
            qCen = ell.getCenter();
            dMat = ell.getDiagMat();
            ell = GenEllipsoid(qCen, dMat);
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
            if (-3*maxEig+qCen(dirDim) < minVal) && (curEllMin(dirDim) == -Inf)
                minVal = -3*maxEig+qCen(dirDim);
            end
            if (3*maxEig+qCen(dirDim) > maxVal) && (curEllMax(dirDim) == Inf)
                maxVal = 3*maxEig+qCen(dirDim);
            end            
        end
    end
end
