function res = isempty(H)
%
% ISEMPTY - checks if hyperplanes in H are empty.
%
%
% Description:
% ------------
%
%    RES = ISEMPTY(H)  Checks if hyperplanes in H are empty objects or not,
%                      returns array of ones and zeros of the same size as H.
%
%
% Output:
% -------
%
%    1 - if hyperplane is empty, 0 - otherwise.
%
%
% See also:
% ---------
%
%    HYPERPLANE/HYPERPLANE, DIMENSION.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  global ellOptions;

  if ~isstruct(ellOptions)
    evalin('base', 'ellipsoids_init;');
  end

  if ~(isa(H, 'hyperplane'))
    error('ISEMPTY: input argument must be hyperplane.');
  end

  res = ~dimension(H);

  return;
