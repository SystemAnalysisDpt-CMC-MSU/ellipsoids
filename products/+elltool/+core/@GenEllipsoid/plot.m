function plObj = plot(varargin)

import elltool.conf.Properties;
import modgen.common.throwerror;
import elltool.core.GenEllipsoid;

[reg,~,plObj,isNewFigure,isFill,lineWidth,colorVec,shad,...
    isRelPlotterSpec,~,isIsFill,isLineWidth,isColorVec,isShad]=modgen.common.parseparext(varargin,...
    {'relDataPlotter','newFigure','fill','lineWidth','color','shade';...
    [],0,[],[],[],0;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
    @(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x)});


if ~isRelPlotterSpec
    plObj=smartdb.disp.RelationDataPlotter();
end

ucolor    = [];
vcolor    = [];
ells      = [];
ell_count = 0;

for iReg = 1:size(reg,2)
    if isa(reg{iReg}, 'elltool.core.GenEllipsoid')
        ellArr      = reg{iReg};
        [mEll, nEll] = size(ellArr);
        cnt    = mEll * nEll;
        ellVec     = reshape(ellArr, 1, cnt);
        ells   = [ells ellVec];
        if (iReg < size(reg,2)) && ischar(reg{iReg+1})
            clr = ellipsoid.my_color_table(reg{iReg+1});
            val = 1;
        else
            clr = [0 0 0];
            val = 0;
        end
        for jReg = (ell_count + 1):(ell_count + cnt)
            ucolor(jReg) = val;
            vcolor    = [vcolor; clr];
        end
        ell_count = ell_count + cnt;
    end
end


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
    
    auxcolors  = hsv(ell_count);
    colors     = auxcolors;
    multiplier = 7;
    if mod(size(auxcolors, 1), multiplier) == 0
        multiplier = multiplier + 1;
    end
    for iEll = 1:ell_count
        jj           = mod(iEll*multiplier, size(auxcolors, 1)) + 1;
        colors(iEll, :) = auxcolors(jj, :);
    end
    colors        = flipud(colors);
    colorVec = colors;
else
    if size(colorVec, 1) ~= ell_count
        if size(colorVec, 1) > ell_count
            colorVec = colorVec(1:ell_count, :);
        else
            colorVec = repmat(colorVec, ell_count, 1);
        end
    end
end

if ~isShad
    shad = 0.4*ones(1, ell_count);
else
    [mDim, nDim] = size(shad);
    mDim      = mDim * nDim;
    if mDim == 1
        shad = shad * ones(1, ell_count);
    else
        shad = reshape(shad, 1, mDim);
        if mDim < ell_count
            for iEll = (mDim + 1):ell_count
                shad = [shad 0.4];
            end
        end
    end
end
if ~isLineWidth
    lineWidth = ones(1, ell_count);
else
    [mDim, nDim] = size(lineWidth);
    mDim      = mDim * nDim;
    if mDim == 1
        lineWidth = lineWidth * ones(1, ell_count);
    else
        lineWidth = reshape(lineWidth, 1, mDim);
        if mDim < ell_count
            for iEll = (mDim + 1):ell_count
                lineWidth = [lineWidth 1];
            end
        end
    end
end
if ~isIsFill
    isFill = zeros(1, ell_count);
else
    [mDim, nDim] = size(isFill);
    mDim      = mDim * nDim;
    if mDim == 1
        isFill = isFill * ones(1, ell_count);
    else
        isFill = reshape(isFill, 1, mDim);
        if mDim < ell_count
            for iEll = (mDim + 1):ell_count
                isFill = [isFill 0];
            end
        end
    end
end


dims = dimension(ells);
mDim    = min(dims);
nDim    = max(dims);
if mDim ~= nDim
    throwerror('dimMismatch','Ellipsoids must be of the same dimension.');
end

if (mDim < 1) || (nDim > 3)
    throwerror('wrongDim','ellipsoid dimension can be 1, 2 or 3');
end


if Properties.getIsVerbose()
    if ell_count == 1
        fprintf('Plotting ellipsoid...\n');
    else
        fprintf('Plotting %d ellipsoids...\n', ell_count);
    end
end

SData.figureNameCMat=repmat({'figure'},ell_count,1);
SData.axesNameCMat = repmat({'ax'},ell_count,1);
SData.x1CMat = repmat({1},ell_count,1);
SData.x2CMat = repmat({1},ell_count,1);
SData.qCMat = repmat({1},ell_count,1);
SData.verXCMat = repmat({1},ell_count,1);
SData.verYCMat = repmat({1},ell_count,1);
SData.verZCMat = repmat({1},ell_count,1);
SData.faceXCMat = repmat({1},ell_count,1);
SData.faceYCMat = repmat({1},ell_count,1);
SData.faceZCMat = repmat({1},ell_count,1);
SData.axesNumCMat = repmat({1},ell_count,1);
SData.figureNumCMat = repmat({1},ell_count,1);
SData.faceVertexCDataXCMat = repmat({1},ell_count,1);
SData.faceVertexCDataYCMat = repmat({1},ell_count,1);
SData.faceVertexCDataZCMat = repmat({1},ell_count,1);

SData.widVec = lineWidth.';
SData.shadVec = shad.';

minx = Inf;
miny = Inf;
minz = Inf;
maxx = -Inf;
maxy = -Inf;
maxz = -Inf;

for iEll = 1:ell_count
    ell = ells(iEll);
    qCen = ell.getCenter();
    dMat = ell.getDiagMat();
    ell = GenEllipsoid(qCen, dMat);
    switch nDim
        case 2,
            [supportFun, curEllMax] = rho(ell, [1, 0]');
            [supportFun, curEllMin] = rho(ell, [-1, 0]');
            if (curEllMin(1) < minx)&& (curEllMin(1) > -Inf)
                minx = curEllMin(1);
            end
            if (curEllMax(1) > maxx) && (curEllMax(1) < Inf)
                maxx = curEllMax(1);
            end
            [supportFun, curEllMax] = rho(ell, [0, 1]');
            [supportFun, curEllMin] = rho(ell, [0, -1]');
            if (curEllMin(2) < miny) && (curEllMin(2) > -Inf)
                miny = curEllMin(2);
            end
            if (curEllMax(2) > maxy) && (curEllMax(2) < Inf)
                maxy = curEllMax(2);
            end

        case 3,
            [supportFun, curEllMax] = rho(ell, [1, 0, 0]');
            [supportFun, curEllMin] = rho(ell, [-1, 0, 0]');
            if (curEllMin(1) < minx) && (curEllMin(1) > -Inf)
                minx = curEllMin(1);
            end
            if (curEllMax(1) > maxx) && (curEllMax(1) < Inf)
                maxx = curEllMax(1);
            end
            [supportFun, curEllMax] = rho(ell, [0, 1, 0]');
            [supportFun, curEllMin] = rho(ell, [0, -1, 0]');
            if (curEllMin(2) < miny) && (curEllMin(2) > -Inf)
                miny = curEllMin(2);
            end
            if (curEllMax(2) > maxy) && (curEllMax(2) < Inf)
                maxy = curEllMax(2);
            end
            [supportFun, curEllMax] = rho(ell, [0, 0, 1]');
            [supportFun, curEllMin] = rho(ell, [0, 0, -1]');
            if (curEllMin(3) < minz) && (curEllMin(2) > -Inf)
                minz = curEllMin(3);
            end
            if (curEllMax(3) > maxz) && (curEllMax(2) < Inf)
                maxz = curEllMax(3);
            end

        otherwise
    end
end

for iEll = 1:ell_count
    if isNewFigure
        SData.figureNameCMat{iEll}=sprintf('figure%d',iEll);
        SData.axesNameCMat{iEll} = sprintf('ax%d',iEll);
    end
    plotEll = ells(iEll);
    qVec = plotEll.getCenter();
    diagMat = plotEll.getDiagMat();
    eigvMat = plotEll.getEigvMat();
    plotEll = GenEllipsoid(diagMat);
    if ucolor(iEll) == 1
        clr = vcolor(iEll, :);
    else
        clr = colorVec(iEll, :);
    end
    
    switch nDim
        case 2,
            xMat = ellPoints2d(plotEll);
            nPoints = size(xMat, 2);
            isInf = max(xMat == Inf, [], 2);
            diagVec = diag(plotEll.getDiagMat());
            if isInf(1)
                isInfMat = xMat(1, :) == Inf;
                isNegInfMat = xMat(1, :) == -Inf;

                maxEig = diagVec(2);
                if minx < Inf
                    maxVal = maxx;
                    minVal = minx;
                else
                    maxVal = 3*maxEig ;
                    minVal = -3*maxEig;
                end
                xMat(1, isInfMat) = maxVal;
                xMat(1, isNegInfMat) = minVal;
            end
            if isInf(2)
                isInfMat = xMat(2, :) == Inf;
                isNegInfMat = xMat(2, :) == -Inf;

                maxEig = diagVec(1);
                if miny < Inf
                    maxVal = maxy;
                    minVal = miny;
                else
                    maxVal = 3*maxEig;
                    minVal = -3*maxEig;
                end
                xMat(2, isInfMat) = maxVal;
                xMat(2, isNegInfMat) = minVal;
            end
            xMat = eigvMat.'*xMat + repmat(qVec, 1, nPoints);
            SData.x1CMat{iEll} = xMat(1,:);
            SData.x2CMat{iEll} = xMat(2,:);
            SData.qCMat{iEll} = qVec;
        case 3,
            [xMat, fMat] = ellPoints3d(plotEll);
            isInf = max(xMat == Inf, [], 2);
            diagVec = diag(plotEll.getDiagMat());

            nPoints = size(xMat, 2);
            if isInf(1)
                isInfMat = xMat(1, :) == Inf;
                isNegInfMat = xMat(1, :) == -Inf;

                maxEig = max(diagVec(diagVec < Inf));
                maxEig = max(maxEig, 1);
                if minx < Inf
                    maxVal = maxx;
                    minVal = minx;
                else
                    maxVal = 3*maxEig;
                    minVal = -3*maxEig;
                end
                xMat(1, isInfMat) = maxVal;
                xMat(1, isNegInfMat) = minVal;
            end
            if isInf(2)
                isInfMat = xMat(2, :) == Inf;
                isNegInfMat = xMat(2, :) == -Inf;

                maxEig = max(diagVec(diagVec < Inf));
                maxEig = max(maxEig, 1);
                if miny < Inf
                    maxVal = maxy;
                    minVal = miny;
                else
                    maxVal = 3*maxEig;
                    minVal = -3*maxEig;
                end
                xMat(2, isInfMat) = maxVal;
                xMat(2, isNegInfMat) = minVal;
            end
            if isInf(3)
                isInfMat = xMat(3, :) == Inf;
                isNegInfMat = xMat(3, :) == -Inf;

                maxEig = max(diagVec(diagVec < Inf));
                maxEig = max(maxEig, 1);
                if minz < Inf
                    maxVal = maxz;
                    minVal = minz;
                else
                    maxVal = 3*maxEig;
                    minVal = -3*maxEig;
                end
                xMat(3, isInfMat) = maxVal;
                xMat(3, isNegInfMat) = minVal;
            end
            xMat = eigvMat*xMat;
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

