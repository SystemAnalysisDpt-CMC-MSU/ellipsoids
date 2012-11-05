function display(rs)
%
% Description:
% ------------
%
%    Displays the reach set object.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;

  fprintf('\n');
  disp([inputname(1) ' =']);

  [m, n] = size(rs);
  if (m > 1) | (n > 1)
    fprintf('%dx%d array of reach set objects\n\n', m, n);
    return;
  end

  if isempty(rs)
    fprintf('Empty reach set object.\n\n');
    return;
  end

  if isdiscrete(rs.system)
    ttyp = 'discrete-time';
    ttst = 'k = ';
    tts0 = 'k0 = ';
    tts1 = 'k1 = ';
  else
    ttyp = 'continuous-time';
    ttst = 't = ';
    tts0 = 't0 = ';
    tts1 = 't1 = ';
  end

  d = dimension(rs.system);

  if size(rs.time_values, 2) == 1
    if rs.time_values < rs.t0
      back = 1;
      fprintf('Backward reach set of the %s linear system in R^%d at time %s%d.\n', ttyp, d, ttst, rs.time_values);
    else
      back = 0;
      fprintf('Reach set of the %s linear system in R^%d at time %s%d.\n', ttyp, d, ttst, rs.time_values);
    end
  else
    if rs.time_values(1) > rs.time_values(end)
      back = 1;
      fprintf('Backward reach set of the %s linear system in R^%d in the time interval [%d, %d].\n', ttyp, d, rs.time_values(1), rs.time_values(end));
    else
      back = 0;
      fprintf('Reach set of the %s linear system in R^%d in the time interval [%d, %d].\n', ttyp, d, rs.time_values(1), rs.time_values(end));
    end
  end

  if ~(isempty(rs.projection_basis))
    fprintf('Projected onto the basis:\n');
    disp(rs.projection_basis);
  end

  fprintf('\n');

  if back > 0
    fprintf('Target set at time %s%d:\n', tts1, rs.t0);
  else
    fprintf('Initial set at time %s%d:\n', tts0, rs.t0);
  end
  disp(rs.X0);

  fprintf('Number of external approximations: %d\n', size(rs.ea_values, 2));
  fprintf('Number of internal approximations: %d\n', size(rs.ia_values, 2));

  if ~(isempty(rs.calc_data))
    fprintf('\nCalculation data preserved.\n');
  end

  fprintf('\n');

  return;
