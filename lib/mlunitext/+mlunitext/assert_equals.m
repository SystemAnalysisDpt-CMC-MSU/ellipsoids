function assert_equals(varargin)
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
% Faculty of Applied Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$
%
mlunit.assert_equals(varargin{:});
