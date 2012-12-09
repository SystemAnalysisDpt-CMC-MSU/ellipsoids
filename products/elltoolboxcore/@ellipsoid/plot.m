function plObj = plot(varargin)
%
% PLOT - plots ellipsoids in 2D or 3D.
%
%
% Description:
% ------------
%
% PLOT(E, 'Property',PropValue) plots ellipsoid E if 1 <= dimension(E) <= 3.
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
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID.
%

%
% Author:
% -------
%
%    $Author: Ilya Lubich  <justenterrr@gmail.com> $    $Date: 1-december-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

import elltool.conf.Properties;

[reg,~,plObj,isNewFigure,isFill,lineWidth,colorVec,shad,...
    isRelPlotterSpec,~,isIsFill,isLineWidth,isColorVec,isShad]=modgen.common.parseparext(varargin,...
    {'relDataPlotter','newFigure','fill','lineWidth','color','shade';...
    [],0,[],[],[],0;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
    @(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x)});

if ~isRelPlotterSpec
        plObj=smartdb.disp.RelationDataPlotter('figureGetNewHandleFunc', @(varargin)gcf,'axesGetNewHandleFunc',@(varargin)gca);
end
ucolor    = [];
vcolor    = [];
ells      = [];
ell_count = 0;
for iReg = 1:size(reg,2)
    if isa(reg{iReg}, 'ellipsoid')
        Ell      = reg{iReg};
        [mEll, nEll] = size(Ell);
        cnt    = mEll * nEll;
        Ell1     = reshape(Ell, 1, cnt);
        ells   = [ells Ell1];
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
if size(colorVec, 1) < ell_count
    error('PLOT: not enough colors.');
end

dims = dimension(ells);
mDim    = min(dims);
nDim    = max(dims);
if mDim ~= nDim
    error('PLOT: ellipsoids must be of the same dimension.');
end
if (nDim > 3) || (nDim < 1)
    error('PLOT: ellipsoid dimension can be 1, 2 or 3.');
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
SData.clrVec = repmat({1},ell_count,1);
SData.widVec = lineWidth.';
SData.shadVec = shad.';
for iEll = 1:ell_count
    if isNewFigure
        SData.figureNameCMat{iEll}=sprintf('figure%d',iEll);
        SData.axesNameCMat{iEll} = sprintf('ax%d',iEll);
    end
    ell = ells(iEll);
    q = ell.center;
    qMat = ell.shape;
    
    if ucolor(iEll) == 1
        colorVec(iEll,:) = vcolor(iEll, :);    
    end
    switch nDim
        case 2,
            x = ellbndr_2d(ell);
            SData.x1CMat{iEll} = x(1,:);
            SData.x2CMat{iEll} = x(2,:);
            SData.qCMat{iEll} = q;
            %             h = ell_plot(x);
            %             set(h, 'Color', clr, 'LineWidth', Options.width(i));
            %             h = ell_plot(q, '.');
            %             set(h, 'Color', clr);
            
        case 3,
            x    = ellbndr_3d(ell);
            chll = convhulln(x');
            vs   = size(x, 2);
            SData.verXCMat{iEll} = x(1,:);
            SData.verYCMat{iEll} = x(2,:);
            SData.verZCMat{iEll} = x(3,:);
            SData.faceXCMat{iEll} = chll(:,1);
            SData.faceYCMat{iEll} = chll(:,2);
            SData.faceZCMat{iEll} = chll(:,3);  
            clr = colorVec(iEll,:);
            col = clr(ones(1, vs), :);
            SData.faceVertexCDataXCMat{iEll} = col(:,1);
            SData.faceVertexCDataYCMat{iEll} = col(:,2);
            SData.faceVertexCDataZCMat{iEll} = col(:,3);
        otherwise,
            SData.x1CMat{iEll} = q-sqrt(qMat);
            SData.x2CMat{iEll} = q+sqrt(qMat);
            SData.qCMat{iEll} = q(1, 1);
    end
    SData.clrVec{iEll} = colorVec(iEll,:);
end
SData.fill = (isFill~=0)';
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