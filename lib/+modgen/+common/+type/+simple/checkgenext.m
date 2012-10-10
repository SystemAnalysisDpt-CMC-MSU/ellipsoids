function checkgenext(typeSpec,nPlaceHolders,varargin)
% CHECKGENEXT checks a generic condition provided by typeSpec string in the
% following format: 'isnumeric(x1)&&isa(x2,'int32')||isscalar(x2)' etc
% In case validation fails an exception is thrown
%
% Input:
%   regular:
%       typeSpec: char[1,]/function_handle - check string in
%           the folowing format: 'isnumeric(x)&&ischar(x)'
%                       OR
%           function_handle[1,1]
%       nPlaceHolders: numberic[1,1] - number of place holders/arguments in
%           typeSpec
%       
%       x1: anyType[]
%       x2: anyType[]
%       x3: anyType[]
%       
%   optional:
%       x1VarName: char[1,] - variable name - used optionally instead of
%           variable name determined auotmatically via inputname
%       x2VarName: char[1,] - same but for x2
%
% Example:
%
%   modgen.common.type.simple.checkgenext('numel(x1)==numel(x2)',2,a,b,'Alpha')
%
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Applied Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$
%
import modgen.common.type.simple.lib.*;
import modgen.common.throwerror;
%
nVarArgs=length(varargin);
if isempty(nPlaceHolders)
    nPlaceHolders=nVarArgs;
end
%
if nVarArgs<nPlaceHolders
    throwerror('wrongInput',['Values are expected to be provided for ',...
        'each placeholder exceed a number of place holders']);
end
%
nVarNames=nVarArgs-nPlaceHolders;
%
if nVarNames>0
    modgen.common.type.simple.checkcellofstr(varargin(nPlaceHolders+1:end));
end
%
if nVarNames>nPlaceHolders
    throwerror('wrongInput',['Number of variable names cannot ',...
        'exceed a number of place holders']);
end
%
isChar=ischar(typeSpec);
if isChar
    for iVar=1:nPlaceHolders
        assignIn(sprintf('x%d',iVar),varargin{iVar});
    end
    isOk=eval(typeSpec);
else
    isOk=feval(typeSpec,varargin{1:nPlaceHolders});
end
if ~isOk
    %
    varNameList=cell(1,nPlaceHolders);
    varNameList(1:nVarNames)=varargin(nPlaceHolders+1:end);
    for iVar=nVarNames+1:nPlaceHolders
        varNameList{iVar}=inputname(2+iVar);
    end
    %
    if ischar(typeSpec)
        checkName=typeSpec;
    else
        checkName=func2str(typeSpec);
    end
    %
    throwerror('wrongInput',...
        ['%s is expected to comply with all of the following ',...
        'conditions: %s'],...
        cell2sepstr([],varNameList,','),checkName);
end
end
function assignIn(varName,varValue)
assignin('caller',varName,varValue);
end