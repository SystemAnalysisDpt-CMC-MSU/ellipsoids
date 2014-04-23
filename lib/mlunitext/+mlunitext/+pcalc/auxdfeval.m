function varargout=auxdfeval(varargin)
% AUXDFEVAL executes specified function in parallel
%
% This is a wrapper for the modgen.pcalc.auxdfeval function with a
% pre-defined startupFilePath property.
%
% $Author: Peter Gagarinov, 7-October-2012, <pgagarinov@gmail.com>$

[varargout{1:nargout}] = modgen.pcalc.auxdfeval(varargin{:});