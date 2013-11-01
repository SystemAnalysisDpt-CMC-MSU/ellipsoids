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


import elltool.plot.plotgeombodyarr;
[plObj,nDim,isHold]= plotgeombodyarr(@(x)isa(x,'ellipsoid'),...
    @(x)dimension(x),@fCalcBodyTriArr,...
    @patch,varargin{:});
if (nDim < 3)
    [reg]=...
        modgen.common.parseparext(varargin,...
        {'relDataPlotter','priorHold','postHold';...
        [],[],[];
        });
    plObj= plotgeombodyarr(@(x)isa(x,'ellipsoid'),...
        @(x)dimension(x),@fCalcCenterTriArr,...
        @(varargin)patch(varargin{:},'marker','*'),...
        reg{:},...
        'relDataPlotter',plObj, 'priorHold',true,'postHold',isHold);
end


    function [xCMat,fCMat] = fCalcBodyTriArr(bodyArr,varargin)
        [xCMat,fCMat] = arrayfun(@(x)fCalcBodyTri(x),bodyArr,...
            'UniformOutput',false);
        function [xMat, fMat] = fCalcBodyTri(ell)
            nDim = dimension(ell(1));
            if nDim == 1
                [ell,nDim] = rebuildOneDim2TwoDim(ell);
            end
            [lGetGridMat, fGetGridMat] = getGridByFactor(ell);
            nPoints = size(lGetGridMat, 1);
            xMat = zeros(nDim, nPoints+1);
            [qCenVec,qMat] = ell.double();
            xMat(:, 1:end-1) = sqrtm(qMat)*lGetGridMat.' + ...
                repmat(qCenVec, 1, nPoints);
            xMat(:, end) = xMat(:, 1);
            fMat = fGetGridMat;
        end
    end

    function [xCMat,fCMat] = fCalcCenterTriArr(bodyArr,varargin)
        [xCMat,fCMat] = arrayfun(@(x)fCalcCenterTri(x),bodyArr,...
            'UniformOutput',false);
        function [vCenterMat, fCenterMat] = fCalcCenterTri(plotEll)
            if nDim == 1
                [plotEll,nDim] = rebuildOneDim2TwoDim(plotEll);
            end
            vCenterMat = plotEll.centerVec();
            fCenterMat = [1 1];
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







