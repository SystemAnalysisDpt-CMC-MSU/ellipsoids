function [F0, F, G0, G] = ellconstraint(x, Q1, Q2, varargin)
%
% Description:
% ------------
%
%    This function describes ellipsoidal constraint
%                          <l, Q l> = 1,
%    where Q is positive semidefinite.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  % Parameters Q1, Q2 are ignored,
  % F0, G0 must be empty.

  F0 = [];
  G0 = [];

  if nargin > 3
    Q = varargin{1};
    F = (x' * Q * x) - 1;
    G = 2 * Q * x;
  else
    F = (x' * x) - 1;
    G = 2 * x;
  end

end
