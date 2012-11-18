function [d, g] = distpobjfun(x, E, y, varargin)
%
% DISTPOBJFUN - objective function for calculation of distance between
%               an ellipsoid and a point.
%

  q = E.center;
  Q = E.shape;

  d = x'*q + sqrt(x'*Q*x) - x'*y;
  g = q - y + ((Q*x)/sqrt(x'*Q*x));

end
