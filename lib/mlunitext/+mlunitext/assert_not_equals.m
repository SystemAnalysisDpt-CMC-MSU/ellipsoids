function assert_not_equals(varargin)
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
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$
try
    mlunit.assert_not_equals(varargin{:});
catch meObj
    throwAsCaller(meObj);
end