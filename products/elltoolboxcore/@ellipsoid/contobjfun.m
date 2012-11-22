function [d, g] = contobjfun(x, E1, E2, varargin)
%
% CONTOBJFUN - objective function for containment checking of two ellipsoids (E2 in E1).
%

  q1 = E1.center;
  Q1 = E1.shape;
  q2 = E2.center;
  Q2 = E2.shape;

  d = x'*q1 + sqrt(x'*Q1*x) - x'*q2 - sqrt(x'*Q2*x);
  g = q1 + ((Q1*x)/sqrt(x'*Q1*x)) - q2 - ((Q2*x)/sqrt(x'*Q2*x));

end
