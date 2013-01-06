function plObj = plot(varargin)
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
%       figHandleVec: double[1,n] - array with handles of figures hyperplanes
%       were plotted in. Where n is number of figures.
%
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $    $Date: <1 november> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department <2012> $


import elltool.plot.plotgeombodyarr;
[reg,centerVec,sizeVec,...
    isCenterVec,isSizeVec]=...
    modgen.common.parseparext(varargin,...
    {'center','size' ;...
    [],0;
    @(x)isa(x,'double'),...
    @(x)isa(x,'double')});

[plObj,nDim,isHold]= plotgeombodyarr(false,[],'hyperplane',@rebuildOneDim2TwoDim,@calcHypPoints,@patch,varargin{:});
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
        throwerror('wrongDimension','hyperplane dimension must be 2 or 3.');
        %         hypCMat = arrayfun(@(x) oneDim2TwoDim(x), hypArr, ...
        %             'UniformOutput', false);
        %         hypArr = vertcat(hypCMat{:});
        %         nDim = 2;
        %         function hypTwoDim = oneDim2TwoDim(hyp)
        %             [normVec, hypScal] = hyp.double();
        %             hypTwoDim = ellipsoid([normVec, 0].', ...
        %                 diag([qMat, 0]));
        %         end
    end

end




