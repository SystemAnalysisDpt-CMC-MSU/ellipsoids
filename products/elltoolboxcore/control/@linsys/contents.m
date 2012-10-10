% Linear system object of the Ellipsoidal Toolbox.
%
% 
%  linsys         - Constructor of linear system object.
%  dimension      - Returns state space dimension, number of inputs, number of
%                   outputs and number of disturbance inputs.
%  isempty        - Checks if the linear system object is empty.
%  isdiscrete     - Returns 1 if linear system is discrete-time,
%                   0 - if continuous-time.
%  islti          - Returns 1 if the system is time-invariant, 0 - otherwise.
%  hasdisturbance - Returns 1 if unknown bounded disturbance is present,
%                   0 - if there is no disturbance, or disturbance vector is fixed.
%  hasnoise       - Returns 1 if unknown bounded noise at the output is present,
%                   0 - if there is no noise, or noise vector is fixed.
%
%
% Author:
% -------
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
