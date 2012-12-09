function plObj = plot_ea(varargin)
%
% PLOT_EA - plots external approximations of 2D and 3D reach sets.
%
%
% Description:
% ------------
%
%         PLOT_EA(RS, property,'propertyValue')  Plots the external approximation of the reach set RS
%                               using options in the OPTIONS structure.
%
%   properties:
%      'color'       - sets color of the picture in the form [x y z].
%      'width'      - sets line width for 2D plots.
%      'shade' = 0-1 - sets transparency level (0 - transparent, 1 - opaque).
%      'fill'        - if set to 1, reach set will be filled with color.
%       'relDataPlotter' - relation data plotter object
%
% Output:
% -------
%
%    plObj - returns the relation data plotter object
%
%
% See also:
% ---------
%
%    REACH/REACH, PLOT_IA, CUT, PROJECTION.
%

import elltool.conf.Properties;





[reg,~,plObj,isFill,lineWidth,colorVec,isShade,...
    isRelPlotterSpec]=modgen.common.parseparext(varargin,...
    {'relDataPlotter','fill','lineWidth','color','shade';...
    [],0,2,[0 0 1],0.3;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
    @(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x)});
rSet = reg{1};
if ~(isa(rSet, 'reach'))
    error('PLOT_EA: first input argument must be reach set.');
end

rSet = rSet(1, 1);
dim  = dimension(rSet);
if (dim < 2) || (dim > 3)
    msg = sprintf('PLOT_EA: cannot plot reach set of dimension %d.', dim);
    if dim > 3
        msg = sprintf('%s\nUse projection.', msg);
    end
    error(msg);
end

if ~isRelPlotterSpec
    plObj=smartdb.disp.RelationDataPlotter();
end

Ell   = get_ea(rSet);
if rSet.t0 > rSet.time_values(end)
    back = 'Backward reach set';
else
    back = 'Reach set';
end
if Properties.getIsVerbose()
    fprintf('Plotting reach set external approximation...\n');
end
if dim == 3
    EE  = move2origin(Ell(:, end));
    EE  = EE';
    M   = rSet.nPlot3dPoints()/2;
    nSize   = M/2;
    psy = linspace(0, pi, nSize);
    phi = linspace(0, 2*pi, M);
    X   = [];
    L   = [];
    for i = 2:(nSize - 1)
        arr = cos(psy(i))*ones(1, M);
        L   = [L [cos(phi)*sin(psy(i)); sin(phi)*sin(psy(i)); arr]];
    end
    n = size(L, 2);
    m = size(EE, 2);
    for i = 1:n
        l    = L(:, i);
        mval =  rSet.absTol();
        for j = 1:m
            if trace(EE(1, j)) > rSet.absTol()
                Q = parameters(inv(EE(1, j)));
                v = l' * Q * l;
                if v > mval
                    mval = v;
                end
            end
        end
        x = (l/sqrt(mval)) + rSet.center_values(:, end);
        X = [X x];
    end
    
    SData.verticesXMat = X(1,:);
    SData.verticesYMat = X(2,:);
    SData.verticesZMat = X(3,:);
    faceVertexCData = colorVec(ones(1,n),:).';
    SData.faceVertexCDataXMat = faceVertexCData(1,:);
    SData.faceVertexCDataYMat = faceVertexCData(2,:);
    SData.faceVertexCDataZMat = faceVertexCData(3,:);
    SData.axesName = 'ax';
    SData.figureName = 'fig';
    SData.shad = isShade;
    if isdiscrete(rSet.system);
        SData.tit = sprintf('%s at time step K = %d', back, rSet.time_values(end));
    else
        SData.tit = sprintf('%s at time T = %d', back, rSet.time_values(end));
    end
    
    rel=smartdb.relations.DynamicRelation(SData);
    
    plObj.plotGeneric(rel,@figureGetGroupNameFunc,...
        {'figureName'},@figureSetPropFunc,...
        {},  @axesGetNameSurfFunc,...
        {'axesName'},...
        @axesSetPropFunc,{'axesName','tit'},...
        {@plotCreatePatchFunc},...
        {'verticesXMat','verticesYMat','verticesZMat',...
        'faceVertexCDataXMat','faceVertexCDataYMat','faceVertexCDataZMat','shad'});
    return
end



if size(rSet.time_values, 2) == 1
    Ell   = move2origin(Ell');
    nSize   = rSet.nPlot2dPoints;
    phi = linspace(0, 2*pi, nSize);
    L   = [cos(phi); sin(phi)];
    X   = [];
    for i = 1:nSize
        l      = L(:, i);
        [v, x] = rho(Ell, l);
        idx    = find(isinternal((1+ rSet.absTol())*Ell, x, 'i') > 0);
        if ~isempty(idx)
            x = x(:, idx(1, 1)) + rSet.center_values;
            X = [X x];
        end
    end
    SData.col = colorVec;
    if ~isempty(X)
        X = [X X(:, 1)];
        if isFill ~= 0
            SData.xfMat = X(1,:);
            SData.yfMat = X(2,:);
            SData.fl = 1;
        else
            SData.xfMat =0;
            SData.yfMat = 0;
            SData.fl = 0;
        end
        SData.xelMat = X(1,:);
        SData.yelMat = X(2,:);
        SData.wid = lineWidth;
        SData.xcMat = rSet.center_values(1,:);
        SData.ycMat = rSet.center_values(2,:);
        SData.axesName = 'ax';
        SData.figureName = 'fig';
        if isdiscrete(rSet.system)
            SData.tit = sprintf('%s at time step K = %d', back, rSet.time_values);
        else
            SData.tit = sprintf('%s at time T = %d', back, rSet.time_values);
        end
       
        rel=smartdb.relations.DynamicRelation(SData);
        
        plObj.plotGeneric(rel,@figureGetGroupNameFunc,...
            {'figureName'},@figureSetPropFunc,...
            {},  @axesGetNameSurfFunc,...
            {'axesName'},...
            @axesSetPropFunc2,{'axesName','tit'},...
            {@plotCreateFillFunc,@plotCreateElPlot1Func,@plotCreateElPlot2Func},...
            {'xfMat','yfMat','col','fl','xelMat','yelMat','wid','xcMat','ycMat'});
    else
        warning('2D grid too sparse! Please, increase ''ellOptions.plot2d_grid'' parameter...');
    end
    return;
end
[m, n] = size(Ell);
s      = (1/2) * rSet.nPlot2dPoints();
phi    = linspace(0, 2*pi, s);
L      = [cos(phi); sin(phi)];

if isdiscrete(rSet.system)
    SData.xCMat = [];
    SData.yCMat = [];
    SData.zCMat = [];
    SData.xcCMat = [];
    SData.ycCMat = [];
    SData.zcCMat = [];
    SData.col = colorVec;
    SData.wid = linrWidth;
    SData.axesName = 'ax';
    SData.figureName = 'fig';
    if rSet.time_values(1) > rSet.time_values(end)
        SData.tit = 'Discrete-time backward reach tube';
    else
        SData.tit = 'Discrete-time reach tube';
    end
    for ii = 1:n
        EE = move2origin(Ell(:, ii));
        EE = EE';
        X  = [];
        for i = 1:s
            l = L(:, i);
            [v, x] = rho(EE, l);
            idx    =  find(isinternal((1+rSet.absTol())*EE, x, 'i') > 0);
            if ~isempty(idx)
                x = x(:, idx(1, 1)) + rSet.center_values(:, ii);
                X = [X x];
            end
        end
        tt = rSet.time_values(ii);
        if ~isempty(X)
            X  = [X X(:, 1)];
            tt = rSet.time_values(:, ii) * ones(1, size(X, 2));
            X  = [tt; X];
            if isFill ~= 0
                SData.fl = 1;
            else
                SData.fl = 0;
            end
            SData.xCMat = [SData.xCMat, {X(1,:)}];
            SData.yCMat = [SData.yCMat, {X(2,:)}];
            SData.zCMat = [SData.zCMat, {X(3,:)}];
        else
            warning('2D grid too sparse! Please, increase ''ellOptions.plot2d_grid'' parameter...');
        end
        SData.xcCMat = [SData.xcCMat, {tt(1,1)}];
        SData.ycCMat = [SData.ycCMat, {rSet.center_values(1, ii)}];
        SData.zcCMat = [SData.zcCMat, {rSet.center_values(2, ii)}];
    end
    rel=smartdb.relations.DynamicRelation(SData);
    
    plObj.plotGeneric(rel,@figureGetGroupNameFunc,...
        {'figureName'},@figureSetPropFunc,...
        {},  @axesGetNameSurfFunc,...
        {'axesName'},...
        @axesSetPropFunc3,{'axesName','tit'},...
        {@plotCreateFill3Func,@plotCreateElPlot3Func,@plotCreateElPlot4Func},...
        {'xCMat','yCMat','zCMat','col','fl','wid','xcCMat','ycCMat','zcCMat'});
else
    F = ell_triag_facets(s, size(rSet.time_values, 2));
    V = [];
    for ii = 1:n
        EE = move2origin(inv(Ell(:, ii)));
        EE = EE';
        X  = [];
        for i = 1:s
            l    = L(:, i);
            mval = rSet.absTol();
            for j = 1:m
                if 1
                    Q  = parameters(EE(1, j));
                    v  = l' * Q * l;
                    if v > mval
                        mval = v;
                    end
                end
            end
            x = (l/sqrt(mval)) + rSet.center_values(:, ii);
            X = [X x];
        end
        tt = rSet.time_values(ii) * ones(1, s);
        X  = [tt; X];
        V  = [V X];
    end
    vs = size(V, 2);
    SData.col = colorVec;
    SData.shad = isShade;
    SData.axesName = 'ax';
    SData.figureName = 'fig';
    SData.verticesXMat = V(1,:);
    SData.verticesYMat = V(2,:);
    SData.verticesZMat = V(3,:);
    SData.facesXMat = F(:,1)';
    SData.facesYMat = F(:,2)';
    SData.facesZMat = F(:,3)';
    faceVertexCData = colorVec(ones(1, vs), :);
    SData.faceVertexCDataXMat = faceVertexCData(:,1)';
    SData.faceVertexCDataYMat = faceVertexCData(:,2)';
    SData.faceVertexCDataZMat = faceVertexCData(:,3)';
    if rSet.time_values(1) > rSet.time_values(end)
        SData.tit = 'Backward reach tube';
    else
        SData.tit = 'Reach tube';
    end
    rel=smartdb.relations.DynamicRelation(SData);
    
    plObj.plotGeneric(rel,@figureGetGroupNameFunc,...
        {'figureName'},@figureSetPropFunc,...
        {},  @axesGetNameSurfFunc,...
        {'axesName'},...
        @axesSetPropFunc4,{'axesName','tit'},...
        {@plotCreatePatch2Func},...
        {'verticesXMat','verticesYMat','verticesZMat','facesXMat','facesYMat','facesZMat',...
        'faceVertexCDataXMat','faceVertexCDataYMat','faceVertexCDataZMat','shad'});
end
end
function hVec=plotCreatePatchFunc(hAxes,verticesX,verticesY,verticesZ,faceVertexCDataX,faceVertexCDataY,faceVertexCDataZ,faceAlpha)
vertices = [verticesX;verticesY;verticesZ];
faces = convhulln( vertices.');
faceVertexCData = [faceVertexCDataX;faceVertexCDataY;faceVertexCDataZ]';
h0 = patch('Vertices',vertices', 'Faces', faces, ...
    'FaceVertexCData', faceVertexCData, 'FaceColor','flat', ...
    'FaceAlpha', faceAlpha,'Parent',hAxes);
shading interp;
lighting phong;
material('metal');
view(3);
hVec  = h0;
end
function hVec=plotCreatePatch2Func(hAxes,verticesX,verticesY,verticesZ,facesX,facesY,facesZ,faceVertexCDataX,faceVertexCDataY,faceVertexCDataZ,faceAlpha)
vertices = [verticesX;verticesY;verticesZ];
faces = [facesX;facesY;facesZ];
faceVertexCData = [faceVertexCDataX;faceVertexCDataY;faceVertexCDataZ]';
h0 = patch('Vertices',vertices', 'Faces', faces', ...
    'FaceVertexCData', faceVertexCData, 'FaceColor','flat', ...
    'FaceAlpha', faceAlpha,'Parent',hAxes);
shading interp;
lighting phong;
material('metal');
view(3);
hVec  = h0;
end
function hVec=plotCreateFillFunc(hAxes,X,Y,col,fl,varargin)
if fl
    h =   fill(X,Y,col,'Parent',hAxes);
    hVec  = h;
else
    hVec = [];
end
end
function hVec=plotCreateFill3Func(hAxes,X,Y,Z,col,fl,varargin)
hVec =[];
for iEl = 1:size(X,2)
    if fl
        h =   fill3(X(iEl),Y(iEl),Z(iEl),col,'Parent',hAxes);
        hVec  = [hVec,h];
    else
        hVec = [];
    end
end
end
function hVec=plotCreateElPlot1Func(hAxes,~,~,col,~,X,Y,wid,varargin)
h =   ell_plot([X;Y]);
set(h,'Color',col,'LineWidth',wid,'Parent',hAxes);
hVec  = h;
end
function hVec=plotCreateElPlot2Func(hAxes,~,~,col,~,~,~,~,Xc,Yc)
h =   ell_plot([Xc;Yc],'.','Parent',hAxes);
set(h,'Color',col);
hVec  = h;
end
function hVec=plotCreateElPlot3Func(hAxes,X,Y,Z,col,~,wid,varargin)
hVec =[];
for iEl = 1:size(X,2)
    h =   ell_plot([X{iEl};Y{iEl};Z{iEl}],'Parent',hAxes);
    set(h,'Color',col,'LineWidth',wid);
    hVec  = [hVec, h];
end
end
function hVec=plotCreateElPlot4Func(hAxes,~,~,~,col,~,~,Xc,Yc,Zc)
hVec =[];
for iEl = 1:size(Xc,2)
    h =   ell_plot([Xc{iEl};Yc{iEl};Zc{iEl}],'.','Parent',hAxes);
    set(h,'Color',col);
    hVec  = [hVec,h];
end
end
function figureSetPropFunc(hFigure,figureName,~)
set(hFigure,'Name',figureName);
end

function figureGroupName=figureGetGroupNameFunc(figureName)
figureGroupName=[figureName];
end
function axesName=axesGetNameSurfFunc(axesName)
axesName = axesName;
end
function hVec=axesSetPropFunc(~,~,~,tit)
xlabel('x_1'); ylabel('x_2'); zlabel('x_3');
title(tit);
hVec=[];
end
function hVec=axesSetPropFunc2(~,~,~,tit)
xlabel('x_1'); ylabel('x_2');
title(tit);
hVec=[];
end
function hVec=axesSetPropFunc3(~,~,~,tit)
view(3);
xlabel('k'); ylabel('x_1'); zlabel('x_2');
title(tit);
hVec=[];
end
function hVec=axesSetPropFunc4(~,~,~,tit)
view(3);
xlabel('t'); ylabel('x_1'); zlabel('x_2');
title(tit);
hVec=[];
end