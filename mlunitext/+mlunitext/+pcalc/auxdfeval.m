function varargout=auxdfeval(varargin)
% AUXDFEVAL executes specified function in parallel
%
% This is a wrapper for the modgen.pcalc.auxdfeval function with a
% pre-defined startupFilePath property.
%
% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$

reg = modgen.common.parseparams(varargin,{'startupFilePath'});
[varargout{1:nargout}] = modgen.pcalc.auxdfeval(reg{:}, ...
    'startupFilePath',fileparts(mfilename('fullpath')));
