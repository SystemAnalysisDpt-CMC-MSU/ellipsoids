function checkgen(x,typeSpec,varargin)
% CHECKGEN checks a generic condition provided by typeSpec string in the
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
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-05-24 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
if isempty(varargin),
    reg=varargin;
    nCallerStackStepsUp=1;
else
    [reg,~,nCallerStackStepsUp]=modgen.common.parseparext(varargin,...
        {'nCallerStackStepsUp';1},'propRetMode','separate');
end
modgen.common.checkvar(x,typeSpec,reg{:},'nCallerStackStepsUp',...
    1+nCallerStackStepsUp);
