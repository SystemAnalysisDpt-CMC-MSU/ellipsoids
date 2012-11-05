function RRS = refine(RS, L0, Options)
%
% REFINE - adds new approximations computed for the specified directions
%          to the given reach set.
%
%
% Description:
% ------------
%
% RRS = REFINE(RS, L0, OPTIONS)  Given nonempty reach set RS and direction
%                                vectors specified by matrix L0,
%                                adds new approximations computed for those
%                                directions to this reach set.
%                                This refinement is possible only if the reach
%                                set was obtained by the REACH call with option
%                                'save_all' set to 1 (intermediate calculation
%                                information is saved in the reach set object).
%                                Optional OPTIONS parameter is a structure:
%                                  Options.approximation = 0 for external,
%                                                        = 1 for internal,
%                                                        = 2 for both (default).
%                                  Options.save_all = 1 (default) to save intermediate
%                                                       calculation data,
%                                                   = 0 to delete intermediate
%                                                       calculation data.
%                                  Options.minmax = 1 compute minmax reach set,
%                                  Options.minmax = 0 (default) compute maxmin reach set.
%                                                 This option makes sense only for
%                                                 discrete-time systems with disturbance.
%
%    WARNING! This function does not work with reach set objects resulting
%             form CUT and/or PROJECTION operation.
%                                       
%
%
% Output:
% -------
%
%    RRS - refined reach set.
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

  import elltool.conf.Properties;

  RRS = RS(1, 1);
  if isempty(RRS)
    return;
  end
  
  if nargin < 2
    error('REFINE: insufficient number of input arguments.');
  end

  if iscut(RRS)
    error('REFINE: cannot perform a refinement on a cut of the reach set.');
  end
  
  if isprojection(RRS)
    error('REFINE: cannot perform a refinement on a projection of the reach set.');
  end

  d1 = dimension(RRS);
  k  = size(RRS.initial_directions, 1);
  if isempty(L0)
    m = k;
  else
    [m, n] = size(L0);
  end
  if (k ~= m) | (d1 ~= m)
    error('REFINE: dimensions of the reach set and direction vectors do not matcch.');
  end

  mydata = RRS.calc_data;
  if isempty(mydata) | ~(isstruct(mydata))
    error('REFINE: cannot perform a refinement without intermediate calculation info.');
  end

  if (nargin < 3) | ~(isstruct(Options))
    Options               = [];
    Options.approximation = 2;
    Options.save_all      = 1;
    Options.minmax        = 0;
  else
    if ~(isfield(Options, 'approximation')) | ...
         (Options.approximation < 0) | (Options.approximation > 2)
      Options.approximation = 2;
    end
    if ~(isfield(Options, 'save_all')) | ...
         (Options.save_all < 0) | (Options.save_all > 2)
      Options.save_all = 1;
    end
    if ~(isfield(Options, 'minmax')) | ...
         (Options.minmax < 0) | (Options.minmax > 1)
      Options.minmax = 0;
    end
  end

  www = warning;
  warning off;

  tvals = RRS.time_values;
  if tvals(1) > tvals(end)
    tvals = -tvals;
    back  = 1;
  else
    back  = 0;
  end

  RRS.initial_directions = [RRS.initial_directions L0];
  N                      = size(RRS.initial_directions, 2);
  EN                     = size(RRS.ea_values, 2);
  IN                     = size(RRS.ia_values, 2);
  X0                     = parameters(RRS.X0);

  
  %%% Compute external shape matrices. %%%

  if (Options.approximation ~= 1)
    if Properties.getIsVerbose()
      if (N - EN) > 0
        fprintf('Computing external shape matrices...\n');
      end
    end

    LL = [];
    QQ = [];
    Q0 = reshape(X0, d1*d1, 1);
    for ii = (EN + 1):N
      l0 = RRS.initial_directions(:, ii);
      if isdiscrete(RRS.system)   % discrete-time system
        if hasdisturbance(RRS.system)
          [Q, L] = eedist_de(size(tvals, 2), ...
                             Q0, ...
                             l0, ...
                             mydata, ...
                             d1, ...
                             back, ...
                             Options.minmax);
        elseif ~(isempty(mydata.BPB))
          [Q, L] = eesm_de(size(tvals, 2), Q0, l0, mydata, d1, back);
        else
          Q = [];
          L = [];
        end
        LL = [LL {L}];
      else   % continuous-time system
        if hasdisturbance(RRS.system)
          [tt, Q] = ell_ode_solver(@ell_eedist_ode, tvals, Q0, l0, mydata, d1, back);
          Q       = Q';
        elseif ~(isempty(mydata.BPB))
          [tt, Q] = ell_ode_solver(@ell_eesm_ode, tvals, Q0, l0, mydata, d1, back);
          Q       = Q';
        else
          Q = [];
        end
      end
      QQ = [QQ {Q}];
    end
    RRS.ea_values = [RRS.ea_values QQ];
  end




  
  %%% Compute internal shape matrices. %%%

  if (Options.approximation ~= 0)
    if Properties.getIsVerbose()
      if (N - IN) > 0
        fprintf('Computing internal shape matrices...\n');
      end
    end

    LL = [];
    QQ = [];
    Q0 = reshape(X0, d1*d1, 1);
    M  = sqrtm(X0);
    M  = 0.5*(M + M');
    for ii = (IN + 1):N
      l0 = RRS.initial_directions(:, ii);
      if isdiscrete(RRS.system)   % discrete-time system
        if hasdisturbance(RRS.system)
          [Q, L] = iedist_de(size(tvals, 2), ...
                             Q0, ...
                             l0, ...
                             mydata, ...
                             d1, ...
                             back, ...
                             Options.minmax);
        elseif ~(isempty(mydata.BPB))
          [Q, L] = iesm_de(size(tvals, 2), Q0, l0, mydata, d1, back);
        else
          Q = [];
          L = [];
        end
        LL = [LL {L}];
      else   % continuous-time system
        if hasdisturbance(RRS.system)
          [tt, Q] = ell_ode_solver(@ell_iedist_ode, tvals, reshape(X0, d1*d1, 1), l0, mydata, d1, back);
          Q       = Q';
        elseif ~(isempty(mydata.BPB))
          [tt, Q] = ell_ode_solver(@ell_iesm_ode, tvals, reshape(M, d1*d1, 1), M*l0, l0, mydata, d1, back);
          Q       = fix_iesm(Q', d1);
        else
          Q = [];
        end
      end
      QQ = [QQ {Q}];
    end
    RRS.ia_values = [RRS.ia_values QQ];
  end
  


  % Save direction values if necessary.
  if Options.save_all == 0
    RRS.calc_data = [];
  end

  LL = [];
  for ii = 1:N
    l0 = RRS.initial_directions(:, ii);
    if isdiscrete(RRS.system)   % discrete-time system
      L = l0;
      l = l0;
      if back > 0
        for i = 2:size(RRS.time_values, 2)
          A = ell_value_extract(mydata.A, i, [d1 d1]);
          l = A' * l;
          L = [L l];
        end
      else
        for i = 1:(size(RRS.time_values, 2) - 1)
          A = ell_inv(ell_value_extract(mydata.A, i, [d1 d1]));
          l = A' * l;
          L = [L l];
        end
      end
    else   % continuous-time system
      L  = [];
      for i = 1:size(RRS.time_values, 2)
        t = RRS.time_values(i);
        if back > 0
          F = ell_value_extract(mydata.Phi, t, [d1 d1]);
        else
          F = ell_value_extract(mydata.Phinv, t, [d1 d1]);
        end
        L = [L F'*l0];
      end
    end
    LL = [LL {L}];
  end

  RRS.l_values  = LL;

  if www(1).state
    warning on;
  end

  return;
