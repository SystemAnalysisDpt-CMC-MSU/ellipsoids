function HA = polytope2hyperplane(P)
%
% POLYTOPE2HYPERPLANE - converts given Polyhedron object into
%                       the array of hyperplanes.
%                       
%
%
% Description:
% ------------
%
%    HA = POLYTOPE2HYPERPLANE(P)  Given Polyhedron object P,
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
%    Polyhedron/Polyhedron, HYPERPLANE/HYPERPLANE,
%    HYPERPLANE2POLYTOPE.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%    Peter Gagarinov<pgagarinov@gmail.com>

  import elltool.conf.Properties;
  import modgen.common.throwerror;

  if ~(isa(P, 'Polyhedron'))
    throwerror('wrongInput:class','input argument must be single Polyhedron.');
  end
  %
  P      = P(1, 1);
  H=P.H;
  A = H(:, 1:end-1);
  b = H(:, end);
  HA     = hyperplane(A', b');

end
