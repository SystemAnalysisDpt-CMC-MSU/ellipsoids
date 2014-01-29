function assert_not_equals(expectedVal, actualVal, msg)
% ASSERT_NOT_EQUALS checks whether expected ~= actual and raises an error
% if not.
%
% Input:
%   regular:
%       expectedValue: any[] - expectedValue value
%       actualValue: any[] actualValue value
%   optional:
%       msg: char[1,] - message displayed in case of error
%
% Example: assert_not_equals(a, b);
%   The assertion will fail, if a is equal to b.
%   In addition, a message can be specified:
%
% Example: assert_equals(a, b, 'a is equal to b.');
%   The message is only used, if the assertion fails.
%
%
% $Authors: Peter Gagarinov <pgagarinov@gmail.com>
% $Date: March-2013 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012-2013$

if (nargin == 2)
    msg = '';
end;
if (isempty(msg))
    if (isnumeric(expectedVal) || islogical(expectedVal))
        expStr = num2str(expectedVal);
    else
        expStr = expectedVal;
    end;
    msgOut = sprintf('Expected not equal to <%s>.', expStr);
else
    msgOut = msg;
end;
if (isequal(actualVal, expectedVal))
    try
        mlunitext.fail(msgOut);
    catch meObj
        throwAsCaller(meObj)
    end
end;
