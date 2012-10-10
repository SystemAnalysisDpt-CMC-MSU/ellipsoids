function checkgen(x,typeSpec,varName)
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
%           variable name determined auotmatically via inputname(10
%
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Applied Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$
%
import modgen.common.type.simple.lib.*;
import modgen.common.throwerror;
%
if nargin>2
    if ~modgen.common.type.simple.lib.isstring(varName)
        error([upper(mfilename),':wrongInput'],...
            'varName is expected to be a string');
    end
end
isChar=ischar(typeSpec);
if isChar&&~eval(typeSpec)||~isChar&&~feval(typeSpec,x)
    if nargin==2
        varName=inputname(1);
    end
    if ischar(typeSpec)
        checkName=typeSpec;
    else
        checkName=func2str(typeSpec);
    end
    %
    throwerror('wrongInput',...
        ['%s is expected to comply with all of the following ',...
        'conditions: %s'],...
        varName,checkName);
end