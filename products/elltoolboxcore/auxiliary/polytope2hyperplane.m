function HA = polytope2hyperplane(P)
%
% POLYTOPE2HYPERPLANE - converts given polytope object into
%                       the array of hyperplanes.
%                       
%
%
% Description:
% ------------
%
%    HA = POLYTOPE2HYPERPLANE(P)  Given polytope object P,
%              returns array of hyperplane objects HA.
%              Requires Multi-Parametric Toolbox.
%
%
% Output:
% -------
%
%    HA - array of hyperplanes.
%
%
% See also:
% ---------
%
%    POLYTOPE/POLYTOPE, HYPERPLANE/HYPERPLANE,
%    HYPERPLANE2POLYTOPE.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;
  import modgen.common.throwerror;

  if ~(isa(P, 'polytope'))
    throwerror('wrongInput:class','input argument must be single polytope.');
  end
  
  P      = P(1, 1);
  [A, b] = double(P);
  HA     = hyperplane(A', b');

end
