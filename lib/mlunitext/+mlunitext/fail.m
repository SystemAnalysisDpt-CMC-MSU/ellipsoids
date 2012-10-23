function fail(varargin)
% FAIL raises an error.
%
% Input:
%   regular:
%       msg: char[1,] - message to display in the thrown exception
%
% Example: fail('Test failed.');
%
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$
%
try
    mlunit.fail(varargin{:});
catch meObj
    throwAsCaller(meObj);
end