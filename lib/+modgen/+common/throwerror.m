function meObj=throwerror(msgTag,varargin)
% THROWERROR works similarly to built-in ERROR function in case 
% when there is no output arguments but simpler to use
% as it automatically generates tags based on caller name
% When output argument is specified an exception object is returned instead
%
% Input:
%   regular:
%       msgTag: char[1,] error tag suffix which is complemented by 
%           automatically generated part
%       ...
%       same inputs as in error function
%       ...
%
% Output:
%   optional: meObj: MException[1,1]
%   
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$
%
import modgen.common.*;
if nargin>1
    varargin{1}=strrep(varargin{1},'\','\\');
end
callerName=getcallername(2,'full');
callerName=strrep(callerName,'.',':');

meObj=MException([upper(callerName),':',msgTag],varargin{:});
if nargout==0
    throwAsCaller(meObj);
end
