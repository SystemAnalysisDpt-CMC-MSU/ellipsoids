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


import elltool.plot.plotGeomBodyArr;
[plObj,nDim,isHold]= plotGeomBodyArr(false,[],'ellipsoid',@rebuildOneDim2TwoDim,@calcEllPoints,@patch,varargin{:});
if (nDim < 3)
    hold on
    plObj= plotGeomBodyArr(true,plObj,'ellipsoid',@rebuildOneDim2TwoDim,@calcCenterEllPoints,@(varargin)patch(varargin{:},'marker','*'),varargin{:});
    hold off
end
if  isHold
    hold on;
else
    hold off;
end


    function [xMat,fMat] = calcCenterEllPoints(ellsArr,nDim,lGetGridMat, fGetGridMat)
        [xMat, fMat] = arrayfun(@(x) calcOneCenterEllElem(x), ellsArr, ...
            'UniformOutput', false);
        function [xMat, fMat] = calcOneCenterEllElem(plotEll)
            xMat = plotEll.center();
            fMat = fGetGridMat;
        end
    end
    function [xMat,fMat] = calcEllPoints(ellsArr,nDim,lGetGridMat, fGetGridMat)
        [xMat, fMat] = arrayfun(@(x) ellPoints(x, nDim), ellsArr, ...
            'UniformOutput', false);
        
        
        function [xMat, fMat] = ellPoints(ell, nDim)
            nPoints = size(lGetGridMat, 1);
            xMat = zeros(nDim, nPoints+1);
            [qCenVec,qMat] = ell.double();
            xMat(:, 1:end-1) = sqrtm(qMat)*lGetGridMat.' + ...
                repmat(qCenVec, 1, nPoints);
            xMat(:, end) = xMat(:, 1);
            fMat = fGetGridMat;
        end
    end
    function [ellsArr,nDim] = rebuildOneDim2TwoDim(ellsArr)
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







