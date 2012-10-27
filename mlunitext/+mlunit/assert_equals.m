function assert_equals(expectedValue, actualValue, msg)
% ASSERT_EQUALS checks whether expectedValue == actualValue and raises an error if not.
%
% Input:
%   regular:
%       expectedValue: any[] - expectedValue value
%       actualValue: any[] actualValue value
%   optional:
%       msg: char[1,] - message displayed in case of error
%
%
% Example: assert_equals(a, b);
%   The assertion will fail, if a is not equal to b.
%   In addition, a message can be specified:
%
% Example: assert_equals(a, b, 'a is not equal to b.');
%   The message is only used, if the assertion fails.
%
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$

if (nargin < 2)
    assert(0, 'assert_equals: Not enough input arguments.', 1);
end;
if (nargin == 2)
    msg = '';
end;
if (isempty(msg))
    if (isnumeric(expectedValue) || islogical(expectedValue))
        expStr = num2str(expectedValue);
    else
        expStr = expectedValue;
    end;
    if (isnumeric(actualValue) || islogical(actualValue))
        actStr = num2str(actualValue);
    else
        actStr = actualValue;
    end;
    msgOut = sprintf('expectedValue <%s>, but was <%s>.', ...
        expStr, ...
        actStr);
else
    msgOut = msg;
end;
if (~isequal(actualValue, expectedValue))
    try
        mlunit.fail(msgOut);
    catch meObj
        throwAsCaller(meObj)
    end
end;
