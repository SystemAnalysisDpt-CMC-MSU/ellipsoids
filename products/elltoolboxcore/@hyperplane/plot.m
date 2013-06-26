function plObj = plot(varargin)
%
% PLOT - plots hyperplaces in 2D or 3D.
%
%
% Usage:
%       plot(hyp) - plots hyperplace hyp in default (red) color.
%       plot(hypArr) - plots an array of hyperplaces.
%       plot(hypArr, 'Property',PropValue,...) - plots hypArr with setting
%                                                properties.
%
% Input:
%   regular:
%       hypArr:  Hyperplace: [dim11Size,dim12Size,...,dim1kSize] -
%                array of 2D or 3D hyperplace objects. All hyperplaces in hypArr
%                must be either 2D or 3D simutaneously.
%   optional:
%       color1Spec: char[1,1] - color specification code, can be 'r','g',
%                               etc (any code supported by built-in Matlab function).
%       hyp2Arr: Hyperplane: [dim21Size,dim22Size,...,dim2kSize] -
%                                           second Hyperplane array...
%       color2Spec: char[1,1] - same as color1Spec but for hyp2Arr
%       ....
%       hypNArr: Hyperplane: [dimN1Size,dim22Size,...,dimNkSize] -
%                                            N-th Hyperplane array
%       colorNSpec - same as color1Spec but for hypNArr.
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
%       'size': double[1,1] - length of the line segment in 2D, or square diagonal in 3D.
%       'center': double[1,dimHyp] - center of the line segment in 2D, of the square in 3D
%       'relDataPlotter' - relation data plotter object.
%       Notice that property vector could have different dimensions, only
%       total number of elements must be the same.
% Output:
%   regular:
%       plObj: smartdb.disp.RelationDataPlotter[1,1] - returns the relation
%       data plotter object.
%


% $Author: <Ilya Lyubich>  <lubi4ig@gmail.com> $    $Date: <6 January  2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $

import elltool.plot.plotgeombodyarr;
[reg,~,centerVec,sizeVec,...
    isCenterVec,isSizeVec]=...
    modgen.common.parseparext(varargin,...
    {'center','size' ;...
    [],0;
    @(x)isa(x,'double'),...
    @(x)isa(x,'double')});

[plObj]= plotgeombodyarr(@(x)isa(x,'hyperplane'),...
        @(x)dimension(x),@fCalcBodyTriArr,@patch,reg{:});




    function [xMat,fMat] = fCalcBodyTriArr(hypArr)
        hypNum = numel(hypArr);
        nDim = dimension(hypArr(1));
        DEFAULT_CENTER = zeros(1,nDim);
        DEFAULT_SIZE = 100;
        centerVec = getPlotInitParam(centerVec, isCenterVec, DEFAULT_CENTER);
        sizeVec = getPlotInitParam(sizeVec, isSizeVec, DEFAULT_SIZE);
        
        import modgen.common.throwerror;
        if  any(isnan(centerVec(:))) || ...
                any(isinf(centerVec(:)))
            throwerror('wrongCenterVec', ...
                'CenterVec must be finite');
        end
        if (any(sizeVec(:) < 0)) || any(isnan(sizeVec(:)))...
                || any(isinf(sizeVec(:)))
            throwerror('wrongSizeVec', 'sizeVec must be greater than 0 and finite');
        end
        
        
        
        [xMat, fMat] = arrayfun(@(x,y,z) fCalcBodyTri(x,y,z, nDim), hypArr,num2cell(centerVec,2),sizeVec, ...
            'UniformOutput', false);
        
        
        function outParamVec = getPlotInitParam(inParamArr, ...
                isFilledParam, multConst)
            import modgen.common.throwerror;
            if ~isFilledParam
                outParamVec = repmat(multConst, hypNum,1);
            else
                nParams = size(inParamArr,1);
                if nParams == 1
                    outParamVec = repmat(inParamArr, hypNum,1);
                else
                    if nParams ~= hypNum
                        throwerror('wrongParamsNumber',...
                            'Number of params is not equal to number of hyperplanes');
                    end
                    outParamVec = inParamArr;
                end
            end
        end
        function [xMat, fMat] = fCalcBodyTri(hyp,center,size, nDim)
            center = cell2mat(center);
            normal = hyp.normal;
            shift = hyp.shift;
            if shift < 0
                shift = -shift;
                normal = -normal;
            end
            centVec = center';
            if ~(contains(hyp, centVec))
                centVec = (shift*normal)/(normal'*normal);
            end
            if nDim == 1
                xMat = [centVec ;0];
                fMat = [1 1];
            else
                side = size/2;
                [U,~,~] = svd(normal);
                eVec      = U(:, 2);
                firstVec      = centVec - side*eVec;
                secondVec      = centVec + side*eVec;
                
                
                if nDim ==2
                    xMat = [firstVec, secondVec];
                    fMat = [1 2 1] ;
                else
                    eVec2 = U(:, 3);
                    thirdVec = centVec - side*eVec2;
                    forthVec = centVec + side*eVec2;
                    
                    xMat = [firstVec,secondVec,thirdVec,forthVec];
                    
                    fMat = [1,3,2,4,1];
                end
            end
            
        end
    end


end




