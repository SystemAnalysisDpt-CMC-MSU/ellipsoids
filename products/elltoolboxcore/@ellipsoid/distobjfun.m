function [d, g] = distobjfun(x, E1, E2, varargin)
%
% DISTOBJFUN - objective function for calculation of distance between two ellipsoids.
%

  q1 = E1.center;
  Q1 = E1.shape;
  q2 = E2.center;
  Q2 = E2.shape;

  d = x'*q2 + sqrt(x'*Q1*x) + sqrt(x'*Q2*x) - x'*q1;
  g = q2 - q1 + ((Q1*x)/sqrt(x'*Q1*x)) + ((Q2*x)/sqrt(x'*Q2*x));

  return;
