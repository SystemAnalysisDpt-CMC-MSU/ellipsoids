function P = projection(rs, B)
%
% PROJECTION - projects the reach set onto the given orthogonal basis.
%
%
% Description:
% ------------
%
%    P = PROJECTION(RS, B)  Projects the reach set RS onto the orthogonal basis
%                           specified by the columns of matrix B.
%
%
% Output:
% -------
%
%    P - projected reach set.
%
%
% See also:
% ---------
%
%    REACH/REACH.
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

  if ~(isa(rs, 'reach'))
    error('PROJECTION: first input argument must be reach set object.');
  end

  if ~(isa(B, 'double'))
    error('PROJECTION: second input argument must be matrix of basis vectors.');
  end

  rs = rs(1, 1);
  P  = rs;
  if isempty(rs)
    return;
  end
  
  d      = dimension(rs);
  [m, n] = size(B);

  if m ~= d
    error('PROJECTION: dimensions of the reach set and the basis vectors do not match.');
  end

  EA = [];
  if ~(isempty(rs.ea_values))
    EA = projection(get_ea(rs), B);
  end
  IA = [];
  if ~(isempty(rs.ia_values))
    IA = projection(get_ia(rs), B);
  end

  % normalize the basis vectors
  for i = 1:n
    BB(:, i) = B(:, i)/norm(B(:, i));
  end

  P.center_values    = BB' * rs.center_values;
  P.projection_basis = BB;

  [m, k] = size(EA);
  QQ     = [];
  for i = 1:m
    Q = []; 
    for j = 1:k
      E = parameters(EA(i, j));
      Q = [Q reshape(E, n*n, 1)];
    end
    QQ = [QQ {Q}];
  end
  P.ea_values = QQ;
  
  [m, k] = size(IA);
  QQ     = [];
  for i = 1:m
    Q = []; 
    for j = 1:k
      E = parameters(IA(i, j));
      Q = [Q reshape(E, n*n, 1)];
    end
    QQ = [QQ {Q}];
  end
  P.ia_values = QQ;

  return;
