function display(S)
%
% Description:
% ------------
%
%    Displays the details of linear system object.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  fprintf('\n');
  disp([inputname(1) ' =']);

  [m, n] = size(S);
  if (m > 1) | (n > 1)
    fprintf('%dx%d array of linear systems.\n\n', m, n);
    return;
  end

  if isempty(S)
    fprintf('Empty linear system object.\n\n');
    return;
  end

  if isdiscrete(S)
    s0 = '[k]';
    s1 = 'x[k+1]  =  ';
    s2 = '  y[k]  =  ';
    s3 = ' x[k]';
  else
    s0 = '(t)';
    s1 = 'dx/dt  =  ';
    s2 = ' y(t)  =  ';
    s3 = ' x(t)';
  end

  fprintf('\n');
  if iscell(S.A)
    if isdiscrete(S)
      fprintf('A[k]:\n');
      s4 = 'A[k]';
    else
      fprintf('A(t):\n');
      s4 = 'A(t)';
    end
  else
    fprintf('A:\n');
    s4 = 'A';
  end
  disp(S.A);
  if iscell(S.B)
    if isdiscrete(S)
      fprintf('\nB[k]:\n');
      s5 = '  +  B[k]';
    else
      fprintf('\nB(t):\n');
      s5 = '  +  B(t)';
    end
  else
    fprintf('\nB:\n');
    s5 = '  +  B';
  end
  disp(S.B);

  fprintf('\nControl bounds:\n');
  s6 = [' u' s0];
  if isempty(S.control)
    fprintf('     Unbounded\n');
  elseif isa(S.control, 'ellipsoid')
    [q, Q] = parameters(S.control);
    fprintf('   %d-dimensional constant ellipsoid with center\n', size(S.B, 2));
    disp(q);
    fprintf('   and shape matrix\n'); disp(Q);
  elseif isstruct(S.control)
    U = S.control;
    fprintf('   %d-dimensional ellipsoid with center\n', size(S.B, 2));
    disp(U.center);
    fprintf('   and shape matrix\n'); disp(U.shape);
  elseif isa(S.control, 'double')
    fprintf('   constant vector\n'); disp(S.control);
    s6 = ' u';
  else
    fprintf('   vector\n'); disp(S.control);
  end

  if ~(isempty(S.G)) & ~(isempty(S.disturbance))
    if iscell(S.G)
      if isdiscrete(S)
        fprintf('\nG[k]:\n');
        s7 = '  +  G[k]';
      else
        fprintf('\nG(t):\n');
        s7 = '  +  G(t)';
      end
    else
      fprintf('\nG:\n');
      s7 = '  +  G';
    end
    disp(S.G);
    fprintf('\nDisturbance bounds:\n');
    s8 = [' v' s0];
    if isa(S.disturbance, 'ellipsoid')
      [q, Q] = parameters(S.disturbance);
      fprintf('   %d-dimensional constant ellipsoid with center\n', size(S.G, 2));
      disp(q);
      fprintf('   and shape matrix\n'); disp(Q);
    elseif isstruct(S.disturbance)
      U = S.disturbance;
      fprintf('   %d-dimensional ellipsoid with center\n', size(S.G, 2));
      disp(U.center);
      fprintf('   and shape matrix\n'); disp(U.shape);
    elseif isa(S.disturbance, 'double')
      fprintf('   constant vector\n'); disp(S.disturbance);
      s8 = ' v';
    else
      fprintf('   vector\n'); disp(S.disturbance);
    end
  else
    s7 = '';
    s8 = '';
  end

  if iscell(S.C)
    if isdiscrete(S)
      fprintf('\nC[k]:\n');
      s9 = 'C[k]';
    else
      fprintf('\nC(t):\n');
      s9 = 'C(t)';
    end
  else
    fprintf('\nC:\n');
    s9 = 'C';
  end
  disp(S.C);

  s10 = ['  +  w' s0];
  if ~(isempty(S.noise))
    fprintf('\nNoise bounds:\n');
    if isa(S.noise, 'ellipsoid')
      [q, Q] = parameters(S.noise);
      fprintf('   %d-dimensional constant ellipsoid with center\n', size(S.C, 1));
      disp(q);
      fprintf('   and shape matrix\n'); disp(Q);
    elseif isstruct(S.noise)
      U = S.noise;
      fprintf('   %d-dimensional ellipsoid with center\n', size(S.C, 1));
      disp(U.center);
      fprintf('   and shape matrix\n'); disp(U.shape);
    elseif isa(S.noise, 'double')
      fprintf('   constant vector\n'); disp(S.noise);
      s10 = '  +  w';
    else
      fprintf('   vector\n'); disp(S.noise);
    end
  else
    s10 = '';
  end

  fprintf('%d-input, ', size(S.B, 2));
  fprintf('%d-output ', size(S.C, 1));
  if S.dt > 0
    fprintf('discrete-time linear ');
  else
    fprintf('continuous-time linear ');
  end
  if S.lti > 0
    fprintf('time-invariant system ');
  else
    fprintf('system ');
  end
  fprintf('of dimension %d', size(S.A, 1));
  if ~(isempty(S.G))
    if size(S.G, 2) == 1
      fprintf('\nwith 1 disturbance input');
    elseif size(S.G, 2) > 1
      fprintf('\nwith %d disturbance input', size(S.G, 2));
    end
  end
  fprintf(':\n%s%s%s%s%s%s%s\n%s%s%s%s\n\n', s1, s4, s3, s5, s6, s7, s8, s2, s9, s3, s10);

  return;
