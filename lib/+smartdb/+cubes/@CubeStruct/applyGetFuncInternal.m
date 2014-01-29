function resVec=applyGetFuncInternal(self,varargin)
% APPLYGETFUNC applies a function to the specified fields as columns, i.e.
% the function is applied to each field as whole, not to each cell
% separately
%
% Input:
%   regular:
%       hFunc: function_handle[1,1] - function to apply to each of the
%          field values
%   optional:
%       toFieldNameList: char/cell[1,] of char - a list of fields to which
%          the function specified by hFunc is to be applied
%
%   properties:
%
%       SData: struct[1,1] - data structure to apply the function to, if
%          not specified, self.SData is used
%   
%     Note: hFunc can optionally be specified after toFieldNameList parameter
%
% Notes: this function currently has a lots of limitations:
%   1) it assumes that the output is uniform
%   2) the function is applies to SData part of field value
%   3) no additional arguments can be passed
%   All this limitations will eventually go away though so stay tuned...
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
[reg,prop]=modgen.common.parseparams(varargin,{'SData'},[1 2]);
if isempty(prop)
    SData=self.SData;
else
    SData=prop{2};
end
%
nReg=numel(reg);
if nReg>2
    error([upper(mfilename),':wrongInput'],...
        'a number of regular arguments cannot exceed 2');
end
if nReg>0
    if isa(reg{1},'function_handle')
        hFunc=reg{1};
        if nReg>1
            toFieldNameList=reg{2};
        else
            toFieldNameList=self.getFieldNameList();
        end
    elseif nReg>1&&isa(reg{2},'function_handle')
            hFunc=reg{2};
            toFieldNameList=reg{1};
    else
            error([upper(mfilename),':wrongInput'],...
                'hFunc is an regular parameter and cannot be ommited');
    end
else
    error([upper(mfilename),':wrongInput'],...
        'at least one regular argument is expected');
end
if ischar(toFieldNameList)
    toFieldNameList={toFieldNameList};
end
%
self.checkIfObjectScalar();
if nargin==2
    resVec=transpose(structfun(hFunc,SData));
else
    if ischar(toFieldNameList)
        toFieldNameList={toFieldNameList};
    end
    nFields=length(toFieldNameList);
    resCVec=cell(1,nFields);
    for iField=1:nFields
        resCVec{iField}=hFunc(SData.(toFieldNameList{iField}));
    end
    resVec=horzcat(resCVec{:});
end