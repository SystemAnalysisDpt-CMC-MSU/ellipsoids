function F = cut(varargin)
%CUT Defines a cut constraint
%   
% The syntax for CUT is exactly the same as the
% syntax for SET. In fact, the result from CUT is
% a SET object.
%
% The difference between a ordinary constraint and 
% a cut constraint is that the CUT will not be used
% in the solution of the upper bound problem in a
% global solver, but only in the relxation for the 
% lower problem.
%
%    See also   SET

% Author Johan L�fberg 
% $Id: cut.m,v 1.2 2004-07-01 11:17:09 johanl Exp $


switch nargin
case 0
    F = lmi;
case 1
    F = lmi(varargin{1});
case 2
    F = lmi(varargin{1},varargin{2});
case 3
    F = lmi(varargin{1},varargin{1},varargin{3});
otherwise
end
    
F = setcutflag(F);