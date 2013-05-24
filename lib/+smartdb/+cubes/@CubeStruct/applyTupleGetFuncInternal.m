function varargout=applyTupleGetFuncInternal(self,varargin)
% APPLYTUPLEGETFUNCINTERNAL applies a function to the specified fields 
% separately to each tuple 
%
% Input:
%   regular:
%       hFunc: function_handle[1,1] - function to apply to the specified
%          fields
%   optional:
%       toFieldNameList: char/cell[1,] of char - a list of fields to which
%          the function specified by hFunc is to be applied
%
%   properties:
%       uniformOutput: logical[1,1] - if true, output is expected to be
%           uniform as in cellfun with 'UniformOutput'=true, default 
%			value is true
%
% Output:
%   funcOut1Arr: <type1>[] - array corresponding to the first output of the
%       applied function
%           ....
%   funcOutNArr: <typeN>[] - array corresponding to the last output of the
%       applied function
%
% Notes: this function currently has a lots of limitations:
%   1) it assumes that the output is uniform
%   2) the function is applies to SData part of field value
%   3) no additional arguments can be passed
%   All this limitations will eventually go away though so stay tuned...
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-12-13 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
[reg,~,isUniformOutput]=modgen.common.parseparext(varargin,...
    {'uniformOutput';true;'islogical(x)&&isscalar(x)'},...
    [1 2],...
    'regCheckList',...
    {'isfunction(x)','iscellofstring(x)||isstring(x)'});
%
hFunc=reg{1};
if length(reg)>1
    toFieldNameList=reg{2};
    if ischar(toFieldNameList)
        toFieldNameList={toFieldNameList};
    end
    inpArgList={'fieldNameList',toFieldNameList};
else
    inpArgList={};
end
%
self.checkIfObjectScalar();
colCVec=self.toArray(...
    'structNameList',{'SData'},inpArgList{:},'replaceNull',...
    false,'groupByColumns',true,'outputType','adaptiveCell');
%
varargout=cell(1,nargout);
if numel(colCVec)>0
    [varargout{:}]=cellfun(hFunc,colCVec{:},'UniformOutput',false);
else
    [varargout{:}]=hFunc();
    minDimSizeVec=[self.getMinDimensionSize(),1];
    varargout=cellfun(@(x)repmat({x},minDimSizeVec),varargout,...
        'UniformOutput',false);
end
if isUniformOutput
    varargout=cellfun(@(x)modgen.cell.cell2mat(x),varargout,...
        'UniformOutput',false);
end