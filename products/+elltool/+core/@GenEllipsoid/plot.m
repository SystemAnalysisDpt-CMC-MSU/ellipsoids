function plObj = plot(varargin)

import elltool.conf.Properties;
import modgen.common.throwerror;
import elltool.core.GenEllipsoid;
N_PLOT_POINTS = 500;
SPHERE_TRIANG_CONST = 5;

[reg,~,plObj,isNewFigure,isFill,lineWidth,colorVec,shad,...
    isRelPlotterSpec,~,isIsFill,isLineWidth,isColorVec,isShad]=modgen.common.parseparext(varargin,...
    {'relDataPlotter','newFigure','fill','lineWidth','color','shade';...
    [],0,[],[],[],0;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
    @(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x)});


if ~isRelPlotterSpec
    plObj=smartdb.disp.RelationDataPlotter();
end

[ellsArr, ellNum, uColor, vColor] = getEllParams(reg);
colorVec = setColorVec(colorVec);
shad = setShad(shad);
lineWidth = setLineWidth(lineWidth);
isFill = setFill(isFill);
checkDimensions();
SData = setUpSData();

[minVal, maxVal] = findMinAndMaxInEachDim(ellsArr, ellNum);
SData = calcEllPoints(SData);
SData.fill = (isFill~=0)';
SData.clrVec = colorVec;

rel=smartdb.relations.DynamicRelation(SData);
if (nDim==2)
    
    
    if isFill(iEll) ~= 0
        plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
            @figureSetPropFunc,{},...
            @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
            @axesSetPropDoNothingFunc,{},...
            @plotCreateFillPlotFunc,...
            {'x1CMat','x2CMat','clrVec','fill','shadVec'});
    end
    plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
        @figureSetPropFunc,{},...
        @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
        @axesSetPropDoNothingFunc,{},...
        @plotCreateElPlotFunc,...
        {'x1CMat','x2CMat','qCMat','clrVec','widVec'});
elseif (nDim==3)
    plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
        @figureSetPropFunc,{},...
        @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
        @axesSetPropDoNothingFunc,{},...
        @plotCreatePatchFunc,...
        {'verXCMat','verYCMat','verZCMat','faceXCMat','faceYCMat','faceZCMat','faceVertexCDataXCMat','faceVertexCDataYCMat',...
        'faceVertexCDataZCMat','shadVec','clrVec'});
else
    plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
        @figureSetPropFunc,{},...
        @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
        @axesSetPropDoNothingFunc,{},...
        @plotCreateEl2PlotFunc,...
        {'x1CMat','x2CMat','qCMat','clrVec','widVec'});
end


    function SData = calcEllPoints(SData)
        import elltool.core.GenEllipsoid;
        nDim = max(dimension(ellsArr));
        for iEll = 1:ellNum
            if isNewFigure
                SData.figureNameCMat{iEll}=sprintf('figure%d',iEll);
                SData.axesNameCMat{iEll} = sprintf('ax%d',iEll);
            end
            plotEll = ellsArr(iEll);
            qVec = plotEll.getCenter();
            diagMat = plotEll.getDiagMat();
            eigvMat = plotEll.getEigvMat();
            plotEll = GenEllipsoid(diagMat);
            if uColor(iEll) == 1
                clr = vColor(iEll, :);
            else
                clr = colorVec(iEll, :);
            end
            switch nDim
                case 2,
                    xMat = ellPoints2d(plotEll, N_PLOT_POINTS);
                    nPoints = size(xMat, 2);
                    isInf = max(xMat == Inf, [], 2);
                    diagVec = diag(plotEll.getDiagMat());
                    if isInf(1)
                        xMat = getRidOfInfVal(xMat, 1);
                    end
                    if isInf(2)
                        xMat = getRidOfInfVal(xMat, 2);
                    end
                    xMat = eigvMat.'*xMat + repmat(qVec, 1, nPoints);
                    SData.x1CMat{iEll} = xMat(1,:);
                    SData.x2CMat{iEll} = xMat(2,:);
                    SData.qCMat{iEll} = qVec;
                    
                case 3,
                    [xMat, fMat] = ellPoints3d(plotEll, SPHERE_TRIANG_CONST);
                    isInf = max(xMat == Inf, [], 2);
                    diagVec = diag(plotEll.getDiagMat());
                    
                    nPoints = size(xMat, 2);
                    if isInf(1)
                        xMat = getRidOfInfVal(xMat, 1);
                    end
                    if isInf(2)
                        xMat = getRidOfInfVal(xMat, 2);
                    end
                    if isInf(3)
                        xMat = getRidOfInfVal(xMat, 3);
                    end
                    xMat = eigvMat.'*xMat + repmat(qVec, 1, nPoints);
                    SData.verXCMat{iEll} = xMat(1,:);
                    SData.verYCMat{iEll} = xMat(2,:);
                    SData.verZCMat{iEll} = xMat(3,:);
                    SData.faceXCMat{iEll} = fMat(:,1);
                    SData.faceYCMat{iEll} = fMat(:,2);
                    SData.faceZCMat{iEll} = fMat(:,3);
                    col = clr(ones(1, nPoints), :);
                    SData.faceVertexCDataXCMat{iEll} = col(:,1);
                    SData.faceVertexCDataYCMat{iEll} = col(:,2);
                    SData.faceVertexCDataZCMat{iEll} = col(:,3);
                    
                otherwise
            end
        end
        function xMat = getRidOfInfVal(xMat, dim)
            isInfMat = xMat(dim, :) == Inf;
            isNegInfMat = xMat(dim, :) == -Inf;
            
            maxEig = max(diagVec(diagVec < Inf));
            maxEig = max(maxEig, 1);
            if minVal(dim) < Inf
                maxCurVal = maxVal(dim);
                minCurVal = minVal(dim);
            else
                maxCurVal = 3*maxEig;
                minCurVal = -3*maxEig;
            end
            xMat(dim, isInfMat) = maxCurVal;
            xMat(dim, isNegInfMat) = minCurVal;
            
        end
    end
    function SData = setUpSData()
        SData.figureNameCMat=repmat({'figure'},ellNum,1);
        SData.axesNameCMat = repmat({'ax'},ellNum,1);
        SData.x1CMat = repmat({1},ellNum,1);
        SData.x2CMat = repmat({1},ellNum,1);
        SData.qCMat = repmat({1},ellNum,1);
        SData.verXCMat = repmat({1},ellNum,1);
        SData.verYCMat = repmat({1},ellNum,1);
        SData.verZCMat = repmat({1},ellNum,1);
        SData.faceXCMat = repmat({1},ellNum,1);
        SData.faceYCMat = repmat({1},ellNum,1);
        SData.faceZCMat = repmat({1},ellNum,1);
        SData.axesNumCMat = repmat({1},ellNum,1);
        SData.figureNumCMat = repmat({1},ellNum,1);
        SData.faceVertexCDataXCMat = repmat({1},ellNum,1);
        SData.faceVertexCDataYCMat = repmat({1},ellNum,1);
        SData.faceVertexCDataZCMat = repmat({1},ellNum,1);
        
        SData.widVec = lineWidth.';
        SData.shadVec = shad.';
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
    function shad = setShad(shad)
        
        if ~isShad
            shad = 0.4*ones(1, ellNum);
        else
            [mDim, nDim] = size(shad);
            mDim      = mDim * nDim;
            if mDim == 1
                shad = shad * ones(1, ellNum);
            else
                shad = reshape(shad, 1, mDim);
                if mDim < ellNum
                    for iEll = (mDim + 1):ellNum
                        shad = [shad 0.4];
                    end
                end
            end
        end
        
    end

    function lineWidth = setLineWidth(lineWidth)
        if ~isLineWidth
            lineWidth = ones(1, ellNum);
        else
            [mDim, nDim] = size(lineWidth);
            mDim      = mDim * nDim;
            if mDim == 1
                lineWidth = lineWidth * ones(1, ellNum);
            else
                lineWidth = reshape(lineWidth, 1, mDim);
                if mDim < ellNum
                    for iEll = (mDim + 1):ellNum
                        lineWidth = [lineWidth 1];
                    end
                end
            end
        end
        
    end

    function isFill = setFill(isFill)
        if ~isIsFill
            isFill = zeros(1, ellNum);
        else
            [mDim, nDim] = size(isFill);
            mDim      = mDim * nDim;
            if mDim == 1
                isFill = isFill * ones(1, ellNum);
            else
                isFill = reshape(isFill, 1, mDim);
                if mDim < ellNum
                    for iEll = (mDim + 1):ellNum
                        isFill = [isFill 0];
                    end
                end
            end
        end
    end

    function colorVec = setColorVec(colorVec)
        
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



end


function hVec=plotCreateElPlotFunc(hAxes,X,Y,q,clr,wid,varargin)
h1 = ell_plot([X;Y],'Parent',hAxes);
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
function hVec=plotCreatePatchFunc(hAxes,verticesX,verticesY,verticesZ,facesX,facesY,facesZ,...
    faceVertexCDataX,faceVertexCDataY,faceVertexCDataZ,faceAlpha,clr)
vertices = [verticesX;verticesY;verticesZ];
faces = [facesX,facesY,facesZ];
faceVertexCData = [faceVertexCDataX,faceVertexCDataY,faceVertexCDataZ];
h0 = patch('Vertices',vertices', 'Faces', faces, ...
    'FaceVertexCData', faceVertexCData, 'FaceColor','flat', ...
    'FaceAlpha', faceAlpha,'EdgeColor',clr,'Parent',hAxes);
shading interp;
lighting phong;
material('metal');
view(3);
hVec  = h0;


end

function [ellsArr, ellNum, uColor, vColor] = getEllParams(reg)
uColor    = [];
vColor    = [];
ellsArr      = [];
ellNum = 0;
for iReg = 1:size(reg,2)
    if isa(reg{iReg}, 'elltool.core.GenEllipsoid')
        ellArr      = reg{iReg};
        [mEll, nEll] = size(ellArr);
        cnt    = mEll * nEll;
        ellVec     = reshape(ellArr, 1, cnt);
        ellsArr   = [ellsArr ellVec];
        if (iReg < size(reg,2)) && ischar(reg{iReg+1})
            clr = ellipsoid.my_color_table(reg{iReg+1});
            val = 1;
        else
            clr = [0 0 0];
            val = 0;
        end
        for jReg = (ellNum + 1):(ellNum + cnt)
            uColor(jReg) = val;
            vColor    = [vColor; clr];
        end
        ellNum = ellNum + cnt;
    end
end

end



function [minVal, maxVal] = findMinAndMaxInEachDim(ellsArr, ellNum)

nDim = max(dimension(ellsArr));
minVal = [0, 0, 0].';
maxVal = [0, 0, 0].';
switch nDim
    case 2,
        [minVal(1), maxVal(1)] = findMinAndMaxDim(ellsArr, ellNum, 1, 2);
        [minVal(2), maxVal(2)] = findMinAndMaxDim(ellsArr, ellNum, 2, 2);
    case 3,
        [minVal(1), maxVal(1)] = findMinAndMaxDim(ellsArr, ellNum, 1, 3);
        [minVal(2), maxVal(2)] = findMinAndMaxDim(ellsArr, ellNum, 2, 3);
        [minVal(3), maxVal(3)] = findMinAndMaxDim(ellsArr, ellNum, 3, 3);
    otherwise
end

    function [minVal, maxVal] = findMinAndMaxDim(ellsArr, ellNum, dim, nDims)
        import elltool.core.GenEllipsoid;
        minVal = Inf;
        maxVal = -Inf;
        minlVec = zeros(nDims, 1);
        minlVec(dim) = -1;
        maxlVec = zeros(nDims, 1);
        maxlVec(dim) = 1;
        for iEll = 1:ellNum
            ell = ellsArr(iEll);
            qCen = ell.getCenter();
            dMat = ell.getDiagMat();
            ell = GenEllipsoid(qCen, dMat);
            [~, curEllMax] = rho(ell, maxlVec);
            [~, curEllMin] = rho(ell, minlVec);
            if (curEllMin(dim) < minVal)&& (curEllMin(dim) > -Inf)
                minVal = curEllMin(dim);
            end
            if (curEllMax(dim) > maxVal) && (curEllMax(dim) < Inf)
                maxVal = curEllMax(dim);
            end
            
        end
    end
end

function xMat = ellPoints2d(ell, nPoints)
lMat = gras.geom.circlepart(nPoints);
nDim = numel(ell.getCenter());
xMat = zeros(nDim, nPoints+1);
for iPoint = 1:nPoints
    [rVec, xVec] = rho(ell, lMat(iPoint, :).');
    xMat(:, iPoint) = xVec;
end
xMat(:, end) = xMat(:, 1);
end

function [xMat, fMat] = ellPoints3d(ell, recLevel)
[vMat, fMat] = gras.geom.tri.spheretri(recLevel);
nPoints = size(vMat, 1);
nDim = numel(ell.getCenter());
xMat = zeros(nDim, nPoints+1);
for iPoint = 1:nPoints
    [rVec, xVec] = rho(ell, vMat(iPoint, :).');
    xMat(:, iPoint) = xVec;
end
xMat(:, end) = xMat(:, 1);
end