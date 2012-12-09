function relationDataPlotter = plot(varargin)
%
% PLOT - plots hyperplanes in 2D or 3D.
%
%
% Usage:
%       plot(h) - plots hyperplane H in default (red) color.
%       plot(hM) -plots hyperplanes contained in hyperplane matrix.
%       plot(hM1, 'cSpec1', hM2, 'cSpec1',...) - plots hyperplanes in h1 in
%           cSpec1 color, hyperplanes in h2 in cSpec2 color, etc.
%       plot(hM1, hM2,..., hMn, option) - plots h1,...,hn using options given
%           in the option structure.
%
% Input:
%   regular:
%       hMat: hyperplane[m,n] - matrix of 2D or 3D hyperplanes. All hyperplanes
%             in hM must be either 2D or 3D simutaneously.
%   optional:
%       colorSpec: char[1,1] - specify wich color hyperplane plots will
%                  have
%       option: structure[1,1], containing some of follwing fields:
%           option.newfigure: boolean[1,1]   - if 1, each plot command will open a new figure window.
%           option.size: double[1,1] - length of the line segment in 2D, or square diagonal in 3D.
%           option.center: double[1,1] - center of the line segment in 2D, of the square in 3D.
%           option.width: double[1,1] - specifies the width (in points) of the line for 2D plots.
%           option.color: double[1,3] - sets default colors in the form [x y z], .
%           option.shade = 0-1 - level of transparency (0 - transparent, 1 - opaque).
%           NOTE: if using options and colorSpec simutaneously, option.color is
%           ignored
%
% Output:
%   regular:
%       relationDataPlotter
%
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $    $Date: <1 november> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department <2012> $


import elltool.conf.Properties;

nai = nargin;
H   = varargin{1};
if ~(isa(H, 'hyperplane'))
    error('PLOT: input argument must be hyperplane.');
end

if nai > 1
    if isstruct(varargin{nai}) && ~(isa(varargin{nai}, 'hyperplane'))
        Options = varargin{nai};
        nai     = nai - 1;
    else
        Options = [];
    end
else
    Options = [];
end

if ~isfield(Options, 'newfigure')
    Options.newfigure = 0;
end

ucolor   = [];
vcolor   = [];
hps      = [];
hp_count = 0;
fl = 0;
for i = 1:nai
    if isa(varargin{i}, 'hyperplane')
        H      = varargin{i};
        [m, n] = size(H);
        cnt    = m * n;
        H1     = reshape(H, 1, cnt);
        hps    = [hps H1];
        if (i < nai) && ischar(varargin{i + 1})&&(~strcmp('plotter',varargin{i + 1}))
            clr = my_color_table(varargin{i + 1});
            val = 1;
        else
            clr = [0 0 0];
            val = 0;
        end
        for j = (hp_count + 1):(hp_count + cnt)
            ucolor(j) = val;
            vcolor    = [vcolor; clr];
        end
        hp_count = hp_count + cnt;
    elseif strcmp('plotter',varargin{i})&&isa(varargin{i+1},'smartdb.disp.RelationDataPlotter')
        plObj = varargin{i+1};
        fl = 1;
    end
end
if ~fl
    plObj=smartdb.disp.RelationDataPlotter(...
        'nMaxAxesRows',2 ,'nMaxAxesCols', 2,...
        'figureGroupKeySuffFunc',@(x)sprintf('_gr%d',x));
end
if ~isfield(Options, 'color')
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
    
    auxcolors  = hsv(hp_count);
    colors     = auxcolors;
    multiplier = 7;
    if mod(size(auxcolors, 1), multiplier) == 0
        multiplier = multiplier + 1;
    end
    
    for i = 1:hp_count
        jj           = mod(i*multiplier, size(auxcolors, 1)) + 1;
        colors(i, :) = auxcolors(jj, :);
    end
    colors        = flipud(colors);
    Options.color = colors;
else
    if size(Options.color, 1) ~= hp_count
        if size(Options.color, 1) > hp_count
            Options.color = Options.color(1:hp_count, :);
        else
            Options.color = repmat(Options.color, hp_count, 1);
        end
    end
end
if ~isfield(Options, 'shade')
    Options.shade = 0.25 * ones(1, hp_count);
else
    [m, n] = size(Options.shade);
    m      = m * n;
    if m == 1
        Options.shade = Options.shade * ones(1, hp_count);
    else
        Options.shade = reshape(Options.shade, 1, m);
        if m < hp_count
            for i = (m + 1):hp_count
                Options.shade = [Options.shade 0.25];
            end
        end
    end
end

if ~isfield(Options, 'size')
    Options.size = 100 * ones(1, hp_count);
else
    [m, n] = size(Options.size);
    m      = m * n;
    if m == 1
        Options.size = Options.size * ones(1, hp_count);
    else
        Options.size = reshape(Options.size, 1, m);
        if m < hp_count
            for i = (m + 1):hp_count
                Options.size = [Options.size 100];
            end
        end
    end
end

if ~isfield(Options, 'center')
    Options.center = zeros(1, hp_count);
    m = size(Options.center, 2);
    if m < hp_count
        for i = (m + 1):hp_count
            Options.center = [Options.center (Options.center(:, 1) - Options.center(:, 1))];
        end
    end
end

if ~isfield(Options, 'width')
    Options.width = ones(1, hp_count);
else
    [m, n] = size(Options.width);
    m      = m * n;
    if m == 1
        Options.width = Options.width * ones(1, hp_count);
    else
        Options.width = reshape(Options.width, 1, m);
        if m < hp_count
            for i = (m + 1):hp_count
                Options.width = [Options.width 1];
            end
        end
    end
end
%
SData.clr = Options.color;
SData.wid = Options.width.';
SData.shad = Options.shade.';
%
if size(Options.color, 1) < hp_count
    error('PLOT: not enough colors.');
end
dims = dimension(hps);
m    = min(dims);
n    = max(dims);
if m ~= n
    error('PLOT: hyperplanes must be of the same dimension.');
end
if (n < 2) || (n > 3)
    error('PLOT: hyperplane dimension must be 2 or 3.');
end

if Properties.getIsVerbose()
    if hp_count == 1
        fprintf('Plotting hyperplane...\n');
    else
        fprintf('Plotting %d hyperplanes...\n', hp_count);
    end
end
SData.figureName=repmat({'figure'},hp_count,1);
SData.axesName = repmat({'ax'},hp_count,1);
SData.x1 = repmat({1},hp_count,1);
SData.x2 = repmat({1},hp_count,1);
SData.VerX = repmat({1},hp_count,1);
SData.VerY = repmat({1},hp_count,1);
SData.VerZ = repmat({1},hp_count,1);
SData.FaceX = repmat({1},hp_count,1);
SData.FaceY = repmat({1},hp_count,1);
SData.FaceZ = repmat({1},hp_count,1);
SData.axesNum = repmat({1},hp_count,1);
SData.figureNum = repmat({1},hp_count,1);
SData.FaceVertexCDataX = repmat({1},hp_count,1);
SData.FaceVertexCDataY = repmat({1},hp_count,1);
SData.FaceVertexCDataZ = repmat({1},hp_count,1);
for i = 1:hp_count
    if Options.newfigure
        SData.figureName{i}=sprintf('figure%d',i);
        SData.axesName{i} = sprintf('ax%d',i);
    end
    H = hps(i);
    q = H.normal;
    g = H.shift;
    if g < 0
        g = -g;
        q = -q;
    end
    c = Options.size(i)/2;
    
    if ucolor(i) == 1
        clr = vcolor(i, :);
    else
        clr = Options.color(i, :);
    end
    if size(Options.center, 1) == n
        x0 = Options.center(:, i);
        if ~(contains(H, x0))
            x0 = (g*q)/(q'*q);
        end
    else
        x0 = (g*q)/(q'*q);
    end
    [U,~,~] = svd(q);
    e1      = U(:, 2);
    x1      = x0 - c*e1;
    x2      = x0 + c*e1;
    if n == 2
        SData.x1{i} = x1;
        SData.x2{i} = x2;
    else
        e2 = U(:, 3);
        [nRows, nCols] = size(hps);
        absTolMat = zeros(nRows,nCols);
        for iRows = 1:nRows
            for iCols = 1:nCols
                absTolMat(iRows,iCols) = hps(iRows,iCols).absTol;
            end
        end
        if min(min(abs(x0))) < min(absTolMat(:))
            x0 = x0 + min(absTolMat(:)) * ones(3, 1);
        end
        x3 = x0 - c*e2;
        x4 = x0 + c*e2;
        if strcmp(version('-release'), '13')
            ch = convhulln([x1 x3 x2 x4]');
        else
            ch = convhulln([x1 x3 x2 x4]', {'QJ', 'QbB', 'Qs', 'QR0', 'Pp'});
        end
        Ver = [x1 x3 x2 x4];
        SData.VerX{i} = Ver(1,:);
        SData.VerY{i} = Ver(2,:);
        SData.VerZ{i} = Ver(3,:);
        SData.FaceX{i} = ch(:,1);
        SData.FaceY{i} = ch(:,2);
        SData.FaceZ{i} = ch(:,3);
        col = clr(ones(1, 4), :);
        SData.FaceVertexCDataX{i} = col(:,1);
        SData.FaceVertexCDataY{i} = col(:,2);
        SData.FaceVertexCDataZ{i} = col(:,3);
    end
end
rel=smartdb.relations.DynamicRelation(SData);
if (n==2)
    plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureName'},...
        @figureSetPropFunc,{},...
        @axesGetNameSurfFunc,{'axesName','axesNum'},...
        @axesSetPropDoNothingFunc,{},...
        @plotCreateElPlotFunc,...
        {'x1','x2','clr','wid'});
else
    plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureName'},...
        @figureSetPropFunc,{},...
        @axesGetNameSurfFunc,{'axesName','axesNum'},...
        @axesSetPropDoNothingFunc,{},...
        @plotCreatePatchFunc,...
        {'VerX','VerY','VerZ','FaceX','FaceY','FaceZ','FaceVertexCDataX','FaceVertexCDataY','FaceVertexCDataZ','shad'});
end

relationDataPlotter = plObj;
end
function res = my_color_table(ch)
%
% MY_COLOR_TABLE - returns the code of the color defined by single letter.
%

if ~(ischar(ch))
    res = [0 0 0];
    return;
end

switch ch
    case 'r',
        res = [1 0 0];
        
    case 'g',
        res = [0 1 0];
        
    case 'b',
        res = [0 0 1];
        
    case 'y',
        res = [1 1 0];
        
    case 'c',
        res = [0 1 1];
        
    case 'm',
        res = [1 0 1];
        
    case 'w',
        res = [1 1 1];
        
    otherwise,
        res = [0 0 0];
end
end
function hVec=plotCreateElPlotFunc(hAxes,X,Y,col,wid,varargin)
h =   ell_plot([X Y],'Parent',hAxes);
set(h,'Color',col,'LineWidth',wid);
hVec  = h;
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
function hVec=plotCreatePatchFunc(hAxes,verticesX,verticesY,verticesZ,facesX,facesY,facesZ,faceVertexCDataX,faceVertexCDataY,faceVertexCDataZ,faceAlpha)
vertices = [verticesX;verticesY;verticesZ];
faces = [facesX,facesY,facesZ];
faceVertexCData = [faceVertexCDataX,faceVertexCDataY,faceVertexCDataZ];
h0 = patch('Vertices',vertices', 'Faces', faces, ...
    'FaceVertexCData', faceVertexCData, 'FaceColor','flat', ...
    'FaceAlpha', faceAlpha,'Parent',hAxes);
shading interp;
lighting phong;
material('metal');
view(3);
hVec  = h0;
end