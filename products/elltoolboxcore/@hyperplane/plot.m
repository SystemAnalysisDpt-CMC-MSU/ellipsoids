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

[plObj,nDim,isHold]= plotgeombodyarr(false,[],'hyperplane',@rebuildOneDim2TwoDim,@calcHypPoints,@patch,reg{:});
if  isHold
    hold on;
else
    hold off;
end



    function [xMat,fMat] = calcHypPoints(hypArr,nDim,lGetGridMat, fGetGridMat)
        hypNum = numel(hypArr);
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
        if (any(sizeVec < 0)) || any(isnan(sizeVec))...
                || any(isinf(sizeVec))
            throwerror('sizeVec', 'sizeVec must be greater than 0 and finite');
        end
        
        
        absTolMat = zeros(1,hypNum);
        for iCols = 1:hypNum
            absTolMat(iCols) = hypArr(iCols).absTol;
        end
        minAbs = min(absTolMat);
        [xMat, fMat] = arrayfun(@(x,y,z) hypPoints(x,y,z, nDim), hypArr,num2cell(centerVec,2),sizeVec, ...
            'UniformOutput', false);
        
        
        function outParamVec = getPlotInitParam(inParamArr, ...
                isFilledParam, multConst)
            import modgen.common.throwerror;
            if ~isFilledParam
                outParamVec = repmat(multConst, hypNum,1);
            else
                nParams = numel(inParamArr);
                if nParams == 1
                    outParamVec = repmat(inParamArr, hypNum,1);
                else
                    if nParams ~= hypNum
                        throwerror('wrongParamsNumber',...
                            'Number of params is not equal to number of ellipsoids');
                    end
                    outParamVec = reshape(inParamArr, 1, nParams);
                end
            end
        end
        function [xMat, fMat] = hypPoints(hyp,center,size, nDim)
            center = cell2mat(center);
            q = hyp.normal;
            g = hyp.shift;
            if g < 0
                g = -g;
                q = -q;
            end
            x0 = center';
            if ~(contains(hyp, x0))
                x0 = (g*q)/(q'*q);
            end
            c = size/2;
            [U,~,~] = svd(q);
            e1      = U(:, 2);
            x1      = x0 - c*e1;
            x2      = x0 + c*e1;
            if nDim == 2
                xMat = [x1, x2];
                fMat = [];
            else
                e2 = U(:, 3);
                %                 absTolMat = zeros(1,nDim);
                %                 for iCols = 1:nDim
                %                     absTolMat(1,iCols) = hyp(1,iCols).absTol;
                %                 end
                %                 if min(min(abs(x0))) < min(absTolMat(:))
                %                     x0 = x0 + min(absTolMat(:)) * ones(3, 1);
                %                 end
                if min(min(abs(x0))) < minAbs
                    x0 = x0 + min(absTolMat(:)) * ones(3, 1);
                end
                x3 = x0 - c*e2;
                x4 = x0 + c*e2;
                
                xMat = [x1,x2,x3,x4];
                %
                %                 patch('Vertices', [x1 x3 x2 x4]', 'Faces', ch, ...
                %                     'FaceVertexCData', clr(ones(1, 4), :), 'FaceColor', 'flat', ...
                %                     'FaceAlpha', Options.shade(1, i));
                %                 shading interp;
                %                 lighting phong;
                %                 material('metal');
                %                 view(3);
                %                 %camlight('headlight','local');
                %                 %camlight('headlight','local');
                %                 %camlight('right','local');
                %                 %camlight('left','local');
                fMat = convhulln([x1 x3 x2 x4]', {'QJ', 'QbB', 'Qs', 'QR0', 'Pp'});
            end
            
            
        end
    end
    function [hypArr,nDim] = rebuildOneDim2TwoDim(hypArr)
%         import modgen.common.throwerror;
%         throwerror('wrongDimension','hyperplane dimension must be 2 or 3.');
                hypCMat = arrayfun(@(x) oneDim2TwoDim(x), hypArr, ...
                    'UniformOutput', false);
                hypArr = vertcat(hypCMat{:});
                nDim = 2;
                function hypTwoDim = oneDim2TwoDim(hyp)
                    [normVec, hypScal] = hyp.double();
                    hypTwoDim = hyperplane([normVec, 0].', ...
                        hypScal);
                end
    end

end




