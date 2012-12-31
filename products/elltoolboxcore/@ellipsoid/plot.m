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
%       ellArr:  Ellipsoid: [dim11Size,dim12Size,...,dim1kSize] -
%                array of 2D or 3D Ellipsoids objects. All ellipsoids in ellArr
%                must be either 2D or 3D simutaneously.
%   optional:
%       color1Spec: char[1,1] - color specification code, can be 'r','g',
%                               etc (any code supported by built-in Matlab function).
%       ell2Arr: Ellipsoid: [dim21Size,dim22Size,...,dim2kSize] -
%                                           second ellipsoid array...
%       color2Spec: char[1,1] - same as color1Spec but for ell2Arr
%       ....
%       ellNArr: Ellipsoid: [dimN1Size,dim22Size,...,dimNkSize] -
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

% $Author: <Ilya Lyubich>  <lubi4ig@gmail.com> $    $Date: <23 December 2012> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $

import elltool.conf.Properties;
import modgen.common.throwerror;
import elltool.plot.plotPrepareGeomBodyArr;
N_PLOT_POINTS = 80;
SPHERE_TRIANG_CONST = 3;
[SData,plObj,ellsArr,ellNum,uColorVec,vColorVec,colorVec,nDim,isNewFigure] = plotPrepareGeomBodyArr('ellipsoid',varargin{:});
if nDim == 1
    rebuildOneDim2TwoDim();
end
[lGetGridMat, fGetGridMat] = calcGrid();
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
end
if  isHold
    hold on;
else
    hold off;
end
    function calcEllPoints()
        
        if isNewFigure
            [SData.figureNameCMat, SData.axesNameCMat] =...
                arrayfun(@(x)getSDataParams(x), (1:ellNum).',...
                'UniformOutput', false);
            
        end
        [xMat, fMat] = arrayfun(@(x) ellPoints(x, nDim), ellsArr, ...
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
        SData.qCMat = arrayfun(@(x) {x.center}, ellsArr);
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
        function [figureNameCMat, axesNameCMat] = getSDataParams(iEll)
            figureNameCMat = sprintf('figure%d',iEll);
            axesNameCMat = sprintf('ax%d',iEll);
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
        [qCenVec,qMat] = ell.double();
        xMat(:, 1:end-1) = sqrtm(qMat)*lGetGridMat.' + ...
            repmat(qCenVec, 1, nPoints);
        xMat(:, end) = xMat(:, 1);
        fMat = fGetGridMat;
    end
    function rebuildOneDim2TwoDim()
        ellsCMat = arrayfun(@(x) oneDim2TwoDim(x), ellsArr, ...
            'UniformOutput', false);
        ellsArr = vertcat(ellsCMat{:});
        nDim = 2;
        function ellTwoDim = oneDim2TwoDim(ell)
            [ellCenVec, qMat] = ell.double();
            ellTwoDim = ellipsoid([ellCenVec, 0].', ...
               diag([qMat, 0]));
        end
    end

end

function hVec=plotCreateFillPlotFunc(hAxes,X,q,clrVec,isFill,...
    shade,widVec,varargin)
if ~isFill
    shade = 0;
end
h1 = ell_plot(q, '*','Parent',hAxes);
if isFill
    h2 = fill(X(1, :), X(2, :), clrVec,'FaceAlpha',shade,'Parent',hAxes);
end
h3 = ell_plot(X,'Parent',hAxes);

set(h1, 'Color', clrVec);
set(h3, 'Color', clrVec, 'LineWidth', widVec);
if isFill
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






