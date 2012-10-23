function throwwarn(msgTag,varargin)
% THROWWARN works similarly to built-in WARNING function in case 
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
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-05-25 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.*;
if nargin>1
    varargin{1}=strrep(varargin{1},'\','\\');
end
callerName=getcallername(2,'full');
callerName=strrep(callerName,'.',':');
warnMsg=[upper(callerName),':',msgTag];
warning(warnMsg,varargin{:});