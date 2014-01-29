function fail(msg)
% FAIL raises an error.
%
% Input:
%   regular:
%       msg: char[1,] - message to display in the thrown exception
%
% Example: fail('Test failed.');
%
% $Authors: Peter Gagarinov <pgagarinov@gmail.com>
% $Date: March-2013 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012-2013$
%
if (nargin == 0)
    msg = 'no message.';
end;
meObj=modgen.common.throwerror('MLUNITEXT:TESTFAILURE',msg);
throwAsCaller(meObj);

