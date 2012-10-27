function logprintf(varargin)
% LOGPRINTF passes a printf-formatted message to a log4j logger
%
% Input:
%   regular:
%     logLevel: char[1,] - log level for log4j. Possible values:
%       trace, debug, info, warn, error, fatal
%   optional:
%     printf arguments (see sprintf documentation)
%
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$

mlunit.logprintf(varargin{:});
