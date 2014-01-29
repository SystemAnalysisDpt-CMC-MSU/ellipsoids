function assert(expr, msg)
% ASSERT checks whether the expr is true or not and throws an error if not.
%
% Input:
%   regular:
%       expr: logical[1,1] - logical expression to calculate
%   optional:
%       msg: char[1,] - message to display in case of error
%       isInternalCall: logical[1,1] - indicates whether the call is
%           internal. The parameter is used to trim the top
%           entries of the stack trace, e.g. for user-defined
%           assert methods (see the code of assert_equals for an example).
%
% Example: assert(a == b);
%   The assertion will fail, if a is not equal to b.
%   In addition, a message can be specified:
%
% Example: assert(a == b, 'a is not equal to b.');
%   The message is only used, if the assertion fails.
%
%
% $Authors: Peter Gagarinov <pgagarinov@gmail.com>
% $Date: March-2013 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012-2013$
%
if nargin==1
    msg='no message';
end
if ~expr
    try
        mlunitext.fail(msg);
    catch meObj
        throwAsCaller(meObj)
    end
end
