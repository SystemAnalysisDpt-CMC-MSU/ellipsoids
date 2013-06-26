function varargout = minkCommonAction(getEllArr,fCalcBodyTriArr,...
    fCalcCenterTriArr,varargin)
%
% MINKCOMMONACTION - plot Minkowski operation  of ellipsoids in 2D or 3D.
% Usage:
% minkCommonAction(getEllArr,fCalcBodyTriArr,...
%    fCalcCenterTriArr,varargin) -  plot Minkowski operation  of
%            ellipsoids in 2D or 3D, using triangulation  of output object
%
% Input:
%   regular:
%       getEllArr:  Ellipsoid: [dim11Size,dim12Size,...,dim1kSize] -
%                array of 2D or 3D Ellipsoids objects. All ellipsoids in 
%                ellArr must be either 2D or 3D simutaneously.
% fCalcBodyTriArr - function, calculeted triangulation of output object
%    fCalcCenterTriArr - function, calculeted center  of output object
%            properties:
%       'shawAll': logical[1,1] - if 1, plot all ellArr.
%                    Default value is 0.
%       'fill': logical[1,1]/logical[dim11Size,dim12Size,...,dim1kSize]  -
%               if 1, ellipsoids in 2D will be filled with color.
%               Default value is 0.
%       'lineWidth': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
%                    line width for 1D and 2D plots. Default value is 1.
%       'color': double[1,3]/double[dim11Size,dim12Size,...,dim1kSize,3] -
%                sets default colors in the form [x y z]. 
%               Default value is [1 0 0].
%       'shade': double[1,1]/double[dim11Size,dim12Size,...,dim1kSize]  -
%                level of transparency between 0 and 1
%                   (0 - transparent, 1 - opaque).
%                Default value is 0.4.
%       'relDataPlotter' - relation data plotter object.
%
% Output:
%   centVec: double[nDim, 1] - center of the resulting set.
%   boundPointMat: double[nDim, nBoundPoints] - set of boundary
%       points (vertices) of resulting set.
%
% 
% 
% $Author: <Ilya Lyubich>  <lubi4ig@gmail.com> $   
% $Date: <8 January 2013> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics
import elltool.plot.plotgeombodyarr;
if (nargout == 1)||(nargout == 0)
    charColor = 'empty';
    cellfun(@(x)findColorChar(x),varargin);
    [reg,~,isShowAll]=...
        modgen.common.parseparext(varargin,...
        {'showAll' ;...
        false;
        @(x)isa(x,'logical')});
    
    if ~strcmp(charColor,'empty')
        reg = {reg{1},charColor,reg{2:end}};
    end
    [plObj,nDim,isHold]= plotgeombodyarr(@(x)isa(x,'ellipsoid'),...
        @(x)dimension(x),fCalcBodyTriArr,...
        @patch,reg{:});
    if (nDim < 3)
        [reg]=...
            modgen.common.parseparext(reg,...
            {'relDataPlotter';...
            [],;@(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
            });
        plObj= plotgeombodyarr(@(x)isa(x,'ellipsoid'),...
            @(x)dimension(x),fCalcCenterTriArr,...
            @(varargin)patch(varargin{:},'marker','*'),...
            reg{:},...
            'relDataPlotter',plObj, 'priorHold',true,'postHold',isHold);
    end
    if isShowAll
        [reg]=...
            modgen.common.parseparext(reg,...
            {'relDataPlotter','newFigure','fill','lineWidth','color',...
            'shade','priorHold','postHold'});
        ellArr = cellfun(@(x)getEllArr(x),reg,'UniformOutput', false);
        ellArr = vertcat(ellArr{:});
        plObj = ellArr.plot('color', [0 0 0],'relDataPlotter',plObj,...
            'priorHold',true);
    end
    if nargout == 1
        varargout = {{plObj,isHold}};
    end
else
    [reg]=...
        modgen.common.parseparext(varargin,...
        {'relDataPlotter','newFigure','fill','lineWidth','color',...
        'shade','priorHold','postHold';...
        [],0,[],[],[],0,false,false;...
        @(x)isa(x,'smartdb.disp.RelationDataPlotter'),...
        @(x)isa(x,'logical'),@(x)isa(x,'logical'),@(x)isa(x,'double'),...
        @(x)isa(x,'double'),...
        @(x)isa(x,'double'), @(x)isa(x,'logical'),@(x)isa(x,'logical')});
    ellsCMat = cellfun(@(x)getEllArr(x),reg,'UniformOutput', false);
    ellsArr = vertcat(ellsCMat{:});
    ellsArrDims = dimension(ellsArr);
    mDim    = min(ellsArrDims);
    nDim    = max(ellsArrDims);
    if mDim ~= nDim
        throwerror('dimMismatch', ...
            'Objects must have the same dimensions.');
    end
    
    xSumCMat = fCalcBodyTriArr(ellsArr);
    qSumCMat = fCalcCenterTriArr(ellsArr);
    varargout(1) = qSumCMat;
    varargout(2) = xSumCMat;
end
    function findColorChar(value)
        if ischar(value)&&isColorDef(value)
            charColor = value;
        end
        function isColor = isColorDef(value)
            isColor = strcmp(value, 'r') || strcmp(value, 'g') || ...
                strcmp(value, 'b') || ...
                strcmp(value, 'y') || strcmp(value, 'c') || ...
                strcmp(value, 'm') || strcmp(value, 'w')||...
                strcmp(value, 'k');
        end
    end
end