 function plObj = plot(varargin)
%
% PLOT - plots ellipsoids in 2D or 3D.
%
%
% Usage:
%       plot(ell) - plots ellipsoid ell in default (red) color.
%       plot(ellArr) - plots an array of ellipsoids.
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
%
import elltool.plot.plotgeombodyarr;
import elltool.plot.GraphObjTypeEnum;
import elltool.plot.smartpatch;
if (nargin == 0)
    modgen.common.throwerror('wrongInput:emptyArray',...
        'Ellipsoids to display must be given as input');
end
dimsMatCVec = cellfun(@getEllDims, varargin, 'UniformOutput', false);
isObjVec = ~cellfun('isempty', dimsMatCVec);
mDim = min(cellfun(@(x)min(x(:)), dimsMatCVec(isObjVec)));
nDim = max(cellfun(@(x)max(x(:)), dimsMatCVec(isObjVec)));
ell2DVarargin = cellfun(@selectEll2D, varargin, dimsMatCVec, ...
                        'UniformOutput', false);
ell3DVarargin = cellfun(@selectEll3D, varargin, dimsMatCVec, ...
                        'UniformOutput', false);

extraArgCVec = cell(0);
if (mDim <= 2)
    [plObj,~,isHold]= plotgeombodyarr(...
        @(x)isa(x,'ellipsoid'), @(x)dimension(x), @fCalcBodyTriArr,...
        @(varargin)smartpatch(GraphObjTypeEnum.EllBoundary2D,true,...
                              {'FaceColor', 'none'}, varargin{:}),...
        ell2DVarargin{:}...
    );
    [reg]=...
        modgen.common.parseparext(ell2DVarargin,...
        {'relDataPlotter','priorHold','postHold';...
        [],[],[];
        });
    [plObj,~,isHold] = plotgeombodyarr(...
        @(x)isa(x, 'ellipsoid'), @(x)dimension(x), @fCalcCenterTriArr,...
        @(varargin)smartpatch(GraphObjTypeEnum.EllCenter2D,false,...
                              {'marker', '*'},varargin{:}),...
        reg{:},...
        'relDataPlotter',plObj,'priorHold',true,'postHold',isHold...
    );
    extraArgCVec = {'relDataPlotter',plObj,'postHold',isHold};
end
if (nDim >= 3)
    [plObj,~,~]=plotgeombodyarr(...
        @(x)isa(x, 'ellipsoid'), @(x)dimension(x), @fCalcBodyTriArr,...
        @(varargin)smartpatch(GraphObjTypeEnum.EllBoundary3D,true,...
                              {}, varargin{:}),...
        ell3DVarargin{:},extraArgCVec{:}...
    );
end
    %
    function dimsVec = getEllDims(arg)
        dimsVec = [];
        if (isa(arg, 'ellipsoid'))
            dimsVec = reshape(dimension(arg),[],1);
        end
    end
    function ell2D = selectEll2D(arg, dimsVec)
        if (isa(arg, 'ellipsoid'))
            ell2D = arg(dimsVec < 3);
        else
            ell2D = arg;
        end
    end
    function ell3D = selectEll3D(arg,dimsVec)
        if (isa(arg, 'ellipsoid'))
            ell3D = arg(dimsVec >= 3);
        else
            ell3D = arg;
        end
    end
    function [xMatCArr, fMatCArr, nDimArr] = fCalcBodyTriArr(bodyArr,varargin)
        nDim = dimension(bodyArr(1));
        if nDim == 1
            [bodyArr,nDim] = rebuildOneDim2TwoDim(bodyArr);
        end
        [xMatCArr, fMatCArr] = arrayfun(@(x)getRhoBoundary(x), bodyArr,...
            'UniformOutput', false);
        xMatCArr = cellfun(@(x) x.', xMatCArr, 'UniformOutput', false);
        nDimArr = repmat(nDim, size(xMatCArr));
    end
    %
    function [xCMat,fCMat,nDimArr] = fCalcCenterTriArr(bodyArr,varargin)
        nDim = dimension(bodyArr(1));
        if nDim == 1
            [bodyArr,nDim] = rebuildOneDim2TwoDim(bodyArr);
        end
        [xCMat,fCMat] = arrayfun(@(x)fCalcCenterTri(x),bodyArr,...
            'UniformOutput',false);
        nDimArr = repmat(nDim, size(xCMat));
        function [vCenterMat, fCenterMat] = fCalcCenterTri(plotEll)
            vCenterMat = plotEll.centerVec;
            fCenterMat = [1 1];
        end
    end
    %
    function [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr)
        ellsCMat = arrayfun(@(x) oneDim2TwoDim(x), ellsArr, ...
            'UniformOutput', false);
        ellsArr = vertcat(ellsCMat{:});
        nDim = 2;
        function ellTwoDim = oneDim2TwoDim(ell)
            [ellCenVec, qMat] = ell.double();
            ellTwoDim = feval(class(ellsArr),[ellCenVec, 0].', ...
                diag([qMat, 0]));
        end
    end
end
