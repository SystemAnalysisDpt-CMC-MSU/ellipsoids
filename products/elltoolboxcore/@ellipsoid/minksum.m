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

[reg,~,plObj,isFill,lineWidth,colorVec,shad,isShowAll...
    isRelPlotterSpec,isIsFill,isLineWidth,isColorVec,isShad,isIsShowAll]=modgen.common.parseparext(varargin,...
    {'relDataPlotter','fill','lineWidth','color','shade','showAll';...
    [],0,1,[1 0 0],0.4,0;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
    @(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x),@(x)isnumeric(x)});

% nAi = nargin;
if ~isRelPlotterSpec
    plObj=smartdb.disp.RelationDataPlotter('figureGetNewHandleFunc', @(varargin)gcf,'axesGetNewHandleFunc',@(varargin)gca);
end
if ~ishold
    isHold = false;
    cla
else
    isHold = true;
end
hold on;
fstInpArg = reg{1};
if ~isa(fstInpArg, 'ellipsoid')
    throwerror('wrongInput', ...
        'MINKSUM: input argument must be an array of ellipsoids.');
end

inpEllMat   = reg{1};
[mRows, nCols] = size(inpEllMat);
nInpEllip = mRows * nCols;
inpEllVec   = reshape(inpEllMat, 1, nInpEllip);
nDimsVec = dimension(inpEllVec);
minDim = min(nDimsVec);
maxDim = max(nDimsVec);

if minDim ~= maxDim
    throwerror('wrongSizes', ...
        'MINKSUM: ellipsoids must be of the same dimension.');
end
if maxDim > 3
    throwerror('wrongSizes', ...
        'MINKSUM: ellipsoid dimension must be not higher than 3.');
end

if (isShowAll ~= 0) && ((nargout == 1) || (nargout == 0))
    plObj = plot(inpEllVec, 'b','relDataPlotter',plObj);
end

if (Properties.getIsVerbose()) && (nInpEllip > 1)
    if nargout == 1
        fstStr = 'Computing and plotting geometric sum ';
        secStr = 'of %d ellipsoids...\n';
        fprintf([fstStr secStr], nInpEllip);
    else
        fprintf('Computing geometric sum of %d ellipsoids...\n', ...
            nInpEllip);
    end
end
SData = [];
SData.figureNameCMat={'figure'};
SData.axesNameCMat = {'ax'};
SData.axesNumCMat = {1};
SData.figureNumCMat = {1};
SData.clrVec = {colorVec};
SData.widVec = lineWidth;
SData.shadVec = shad;
for iEllip = 1:nInpEllip
    myEll = inpEllVec(iEllip);
    switch maxDim
        case 2,
            if iEllip == 1
                boundPointMat = ellbndr_2d(myEll);
                SData.boundPointXVec = boundPointMat(1,:);
                SData.boundPointYVec = boundPointMat(2,:);
                SData.centVec = myEll.center';
            else
                boundPointMat = boundPointMat + ellbndr_2d(myEll);
                SData.boundPointXVec = boundPointMat(1,:);
                SData.boundPointYVec = boundPointMat(2,:);
                SData.centVec = SData.centVec + myEll.center';
            end
        case 3,
            if iEllip == 1
                boundPointMat = ellbndr_3d(myEll);
                centVec = myEll.center;
            else
                boundPointMat = boundPointMat + ellbndr_3d(myEll);
                centVec = centVec + myEll.center;
            end
        otherwise,
            if iEllip == 1
                SData.centVec = myEll.center';
                SData.boundPointXVec = myEll.center - sqrt(myEll.shape);
                SData.boundPointYVec = myEll.center + sqrt(myEll.shape);
            else
                SData.centVec = SData.centVec + myEll.center';
                SData.boundPointXVec = SData.boundPointXVec + myEll.center...
                    - sqrt(myEll.shape);
                SData.boundPointYVec = SData.boundPointYVec + myEll.center...
                    + sqrt(myEll.shape);
            end
    end
end
SData.fill = (isFill~=0);
rel=smartdb.relations.DynamicRelation(SData);
if (maxDim==2)
    if isFill ~= 0
        plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
            @figureSetPropFunc,{},...
            @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
            @axesSetPropDoNothingFunc,{},...
            @plotCreateFillPlotFunc,...
            {'boundPointXVec','boundPointYVec','clrVec','fill','shadVec'});
    end
    plObj.plotGeneric(rel,@figureGetGroupNameFunc,{'figureNameCMat'},...
        @figureSetPropFunc,{},...
        @axesGetNameSurfFunc,{'axesNameCMat','axesNumCMat'},...
        @axesSetPropDoNothingFunc,{},...
        @plotCreateElPlotFunc,...
        {'boundPointXVec','boundPointYVec','centVec','clrVec','widVec'});
elseif (maxDim==3)
    chllMat = convhulln(boundPointMat');
    nBoundPoints = size(boundPointMat, 2);
    SData.verXCMat = {boundPointMat(1,:)};
    SData.verYCMat = {boundPointMat(2,:)};
    SData.verZCMat = {boundPointMat(3,:)};
    SData.faceXCMat = {chllMat(:,1)};
    SData.faceYCMat = {chllMat(:,2)};
    SData.faceZCMat = {chllMat(:,3)};
    clr = colorVec(ones(1, nBoundPoints),:);
    SData.faceVertexCDataXCMat = {clr(:,1)};
    size(SData.faceVertexCDataXCMat{1})
    SData.faceVertexCDataYCMat = {clr(:,2)};
    SData.faceVertexCDataZCMat = {clr(:,3)};
    rel=smartdb.relations.DynamicRelation(SData);
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
        {'boundPointXVec','boundPointYVec','centVec','clrVec','widVec'});
end
if (nargout == 1)||(nargout == 0)
    varargout = {plObj};
else
    varargout = {centVec, boundPointMat};
end
if ~isHold
    hold off
end
end
function hVec=plotCreateElPlotFunc(hAxes,X,Y,q,clr,wid,varargin)
h1 = ell_plot([X;Y],'Parent',hAxes);
set(h1, 'Color', clr, 'LineWidth', wid);
h2 = ell_plot(q', '.','Parent',hAxes);
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