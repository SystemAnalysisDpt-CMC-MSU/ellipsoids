function [E] = ellipsoid(varargin)
%
% ELLIPSOID - constructor of the ellipsoid object.
%
%
% Description:
% ------------
%
%    
%          E = ELLIPSOID  Creates an empty ellipsoid.
%       E = ELLIPSOID(Q)  Creates an ellipsoid with shape matrix Q, centered at 0.
%    E = ELLIPSOID(q, Q)  Creates an ellipsoid with shape matrix Q and center q.
%
%    Here q is a vector in R^n, and Q in R^(nxn) is positive semi-definite matrix.
%    These parameters can be accessed by PARAMETERS(E) function call.
%    Also, DIMENSION(E) function call returns the dimension of the space
%    in which ellipsoid E is defined and the actual dimension of the ellipsoid;
%    function ISDEGENERATE(E) checks if ellipsoid E is degenerate.
%
%
% Output:
% -------
%
%    E = { x : <(x - q), Q^(-1)(x - q)> <= 1 } - ellipsoid.
%
%
% See also:
% ---------
%
%    ELLIPSOID/CONTENTS.
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

  if nargin == 0
    E.center = [];
    E.shape  = [];
    E        = class(E, 'ellipsoid');
    return;
  end

  if nargin > 2
    error('ELLIPSOID: arguments must be center (optional) and shape matrix.');
  end

  if nargin == 1
    Q      = real(varargin{1});
    [m, n] = size(Q);
    q      = zeros(n, 1);
    k      = n;
    l      = 1;
  else
    q      = real(varargin{1});
    Q      = real(varargin{2});
    [k, l] = size(q);
    [m, n] = size(Q);
  end
  
  if l > 1
    error('ELLIPSOID: center of an ellipsoid must be a vector.');
  end
  
  if (m ~= n) | (min(min((Q == Q'))) == 0)
    error('ELLIPSOID: shape matrix must be symmetric.');
  end

  % We cannot just check the condition 'min(eig(Q)) < 0'
  % because the zero eigenvalue may be internally represented
  % as something like -10^(-15).
  mev = min(eig(Q));
  if (mev < 0)
    %tol = n * norm(Q) * eps;
    tol = ellOptions.abs_tol;
    if abs(mev) > tol
      error('ELLIPSOID: shape matrix must be positive semi-definite.');
    end
  end
  if k ~= n
    error('ELLIPSOID: dimensions of the center and the shape matrix do not match.');
  end

  E.center = q;
  E.shape  = Q; 
  E        = class(E, 'ellipsoid');

  return;
