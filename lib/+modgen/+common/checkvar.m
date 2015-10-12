function checkvar(x,typeSpec,varargin)
% CHECKVAR checks a generic condition provided by typeSpec string in the
% following format: 'isnumeric(x)&&isa(x,'int32')||isscalar(x)' etc
% In case validation fails an exception is thrown
%
% Input:
%   regular:
%       x: anyType[]
%       typeSpec: char[1,]/function_handle - check string in
%           the folowing format: 'isnumeric(x)&&ischar(x)'
%                       OR
%           function_handle[1,1]
%
%   optional:
%       varName: char[1,] - variable name - used optionally instead of
%           variable name determined auotmatically via inputname(1)
%   properties:
%
%       errorTag: char[1,] - tag for MException object thrown
%           in case of error. If not specified 
%           '<CALLER_NAME>wrongInput' tag is used
%
%       errorMessage: char[1,] - error message for MException object
%           thrown in case of error. If not specified the message 
%           is generated automatically.
%
%       nCallerStackStepsUp: numeric[1,1] - number of steps up in the call
%           stacks for the caller, by which name the full message tag is to
%           be generated, =1 by default
% Example:
%   modgen.common.checkvar(int32(1),@(x)isa(x,'double'),'myVar',...
%       'errorTag','wrongInput:badType','errorMessage','Type is wrong')
%
%   modgen.common.checkvar([1,2],'iscol(x)','myVar',...
%       'errorTag','wrongInput:badType','errorMessage','Type is wrong')
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-11-28 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.throwerror;
import modgen.common.type.simple.lib.*;
%
isChar=ischar(typeSpec);
if isChar&&~eval(typeSpec)||~isChar&&~builtin('feval',typeSpec,x)
    %
    if ischar(typeSpec)
        checkName=typeSpec;
    else
        checkName=func2str(typeSpec);
    end
    %
    defaultErrorMessage=['%s is expected to comply with all of ',...
        'the following conditions: %s'];
    %
    [reg,~,errorTag,errorMessage,nCallerStackStepsUp]=modgen.common.parseparext(...
        varargin,...
        {'errorTag','errorMessage','nCallerStackStepsUp';...
        'wrongInput',defaultErrorMessage,1;...
        @ischarstring,@ischarstring,...
        'isscalar(x)&&isnumeric(x)&&isreal(x)'},[0,1],...
        'regDefList',{inputname(1)},...
        'regCheckList',{@ischarstring});
    varName=reg{1};
    errorMessage=sprintf(errorMessage,varName,checkName);    
    %
    throwerror(errorTag,errorMessage,...
        'nCallerStackStepsUp',1+nCallerStackStepsUp);
end
