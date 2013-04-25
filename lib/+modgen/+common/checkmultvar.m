function checkmultvar(typeSpec,nPlaceHolders,varargin)
% CHECKMULTVAR checks a generic condition provided by typeSpec string in the
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
%   properties:
%       varNameList: cell[1,nVars] of char[1,] - list of variable names
%           used in the automatically generated error message.
%           Moreover the condition nVars<=nPlaceHolders must hold.
%       errorTag: char[1,] - tag for MException object thrown
%           in case of error. If not specified
%           '<CALLER_NAME>:wrongInput' tag is used
%       errorMessage: char[1,] - error message for MException object
%           thrown in case of error. If not specified the message
%           is generated automatically.
%
% Example:
%
%   modgen.common.checkmultvar('numel(x1)==numel(x2)',2,a,b,...
%       'varNameList',{'Alpha'},'errorTag','wrongInput:badType',...
%       'errorMessage','Inputs are wrong')
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-11-28 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
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
        'each placeholder']);
end

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
    if ischar(typeSpec)
        checkName=typeSpec;
    else
        checkName=func2str(typeSpec);
    end
    defaultErrorMessage=...
        ['%s is expected to comply with all of the following ',...
        'conditions: %s'];
    %
    [~,~,varNameList,errorTag,errorMessage]=modgen.common.parseparext(...
        varargin((nPlaceHolders+1):end),...
        {...
        'varNameList','errorTag','errorMessage';...
        {},'wrongInput',defaultErrorMessage;...
        'iscellofstring(x)','isstring(x)','isstring(x)'...
        },0);
    %
    nVarNames=length(varNameList);
    if nVarNames>nPlaceHolders
        throwerror('wrongInput',['Number of variable names exceeds ',...
            'a number of place holders']);
    end
    varNameList=[varNameList,cell(1,nPlaceHolders-nVarNames)];
    %
    for iVar=nVarNames+1:nPlaceHolders
        varNameList{iVar}=inputname(2+iVar);
    end
    errorMessage=sprintf(errorMessage,cell2sepstr([],varNameList,','),...
        checkName);
    %
    throwerror(errorTag,errorMessage);
end
end
function assignIn(varName,varValue)
assignin('caller',varName,varValue);
end
