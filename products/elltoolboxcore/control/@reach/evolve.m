function RS = evolve(CRS, T, lsys)
%
% EVOLVE - computes further evolution in time of the already existing reach set.
%
%
% Description:
% ------------
%
%       RS = EVOLVE(CRS, T)  Given existing reach set CRS, compute its further
%                            evolution in time until time T.
%
% RS = EVOLVE(CRS, T, LSYS)  Further evolution in time is computed according
%                            different linear system, specified by LSYS.
%
%
% Output:
% -------
%
%    RS - resulting reach set object.
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
  import elltool.logging.Log4jConfigurator;
    
  persistent logger;

  if nargin < 2
    error('EVOLVE: insufficient number of input arguments.');
  end

  if isprojection(CRS)
    error('EVOLVE: cannot compute the reach set for projection.');
  end

  RS = CRS;
  if nargin < 3
    lsys = RS.system;
  end

  if isempty(lsys)
    return;
  end

  [d1, du, dy, dd] = dimension(lsys);
  if d1 ~= dimension(CRS.system)
    error('EVOLVE: dimensions of the old and new linear systems do not match.');
  end

  RS.system = lsys;
  T         = [RS.time_values(end) T(1, 1)];

  if (RS.t0 > T(1)) & (T(1) < T(2))
    error('EVOLVE: reach set must evolve backward in time.');
  end
  if (RS.t0 < T(1)) & (T(1) > T(2))
    error('EVOLVE: reach set must evolve forward in time.');
  end
  
  Options               = [];
  Options.approximation = 2;
  if isempty(get_ea(CRS))
    Options.approximation = 1;
  elseif isempty(get_ia(CRS))
    Options.approximation = 0;
  end
  Options.minmax        = RS.minmax;
  
  if isempty(CRS.calc_data)
    Options.save_all = 0;
  else
    Options.save_all = 1;
  end

  % Create time grid
  if isdiscrete(lsys)
    T(1) = round(T(1));
    T(2) = round(T(2));
    if T(1) > T(2)
      RS.time_values = fliplr(T(2):T(1));
    else
      RS.time_values = T(1):T(2);
    end
  else
    RS.time_values = linspace(T(1), T(2), CRS.nTimeGridPoints());
  end

  if RS.time_values(1) > RS.time_values(end)
    back = 1;
    tvals = - RS.time_values;
  else
    back = 0;
    tvals = RS.time_values;
  end

  www = warning;
  warning off;

  RS.ea_values          = [];
  RS.ia_values          = [];
  RS.l_values           = [];
  RS.initial_directions = [];
  RS.center_values      = [];
  RS.calc_data          = [];

  %%% Get new initial directions. %%%
  LL = get_directions(CRS);
  nn = size(LL, 2);
  for i = 1:nn
    L                     = LL{i};
    RS.initial_directions = [RS.initial_directions L(:, end)];
  end

  %%% Perform matrix, control, disturbance and noise evaluations. %%%
  %%% Create splines if needed.                                   %%%

  if Properties.getIsVerbose()
    if isempty(logger)
      logger=Log4jConfigurator.getLogger();
    end
    logger.info('Performing preliminary function evaluations...');
  end

  mydata.A     = [];
  mydata.Bp    = [];
  mydata.BPB   = [];
  mydata.BPBsr = [];
  mydata.Gq    = [];
  mydata.GQG   = [];
  mydata.GQGsr = [];
  mydata.C     = [];
  mydata.w     = [];
  mydata.W     = [];
  mydata.Phi   = [];
  mydata.Phinv = [];
  mydata.delta = [];
  mydata.mu    = [];

  % matrix A
  if iscell(lsys.A)
    AA = [];
    DD = [];
    AC = [];
    for i = 1:size(RS.time_values, 2)
      A  = reach.matrix_eval(lsys.A, RS.time_values(i));
      AC = [AC reshape(A, d1*d1, 1)];
      if isdiscrete(lsys) & (rank(A) < d1)
        A = ell_regularize(A);
        DD = [DD 1];
      elseif isdiscrete(lsys)
        DD = [DD 0];
      end
      AA = [AA reshape(A, d1*d1, 1)];
    end
    if isdiscrete(lsys)
      mydata.A     = AA;
      mydata.delta = DD;
    else
      mydata.A = spline(RS.time_values, AA);
    end
  else
    AC = lsys.A;
    if isdiscrete(lsys) & (rank(lsys.A) < d1)
      mydata.A     = ell_regularize(lsys.A);
      mydata.delta = 1;
    elseif isdiscrete(lsys)
      mydata.A     = lsys.A;
      mydata.delta = 0;
    else
      mydata.A     = lsys.A;
    end
  end

  % matrix B
  if iscell(lsys.B)
    BB = [];
    for i = 1:size(RS.time_values, 2)
      B  = reach.matrix_eval(lsys.B, RS.time_values(i));
      BB = [BB reshape(B, d1*du, 1)];
    end
  else
    BB = reshape(lsys.B, d1*du, 1);
  end

  % matrix G
  GG = [];
  if iscell(lsys.G)
    for i = 1:size(RS.time_values, 2)
      B  = reach.matrix_eval(lsys.G, RS.time_values(i));
      GG = [GG reshape(B, d1*dd, 1)];
    end
  elseif ~(isempty(lsys.G))
    GG = reshape(lsys.G, d1*dd, 1);
  end

  % matrix C
  if iscell(lsys.C)
    CC = [];
    for i = 1:size(RS.time_values, 2)
      C  = reach.matrix_eval(lsys.C, RS.time_values(i));
      CC = [CC reshape(C, d1*dy, 1)];
    end
    if isdiscrete(lsys)
      mydata.C = CC;
    else
      mydata.C = spline(RS.time_values, CC);
    end
  else
    mydata.C = lsys.C;
  end

  % expressions Bp and BPB'
  if isa(lsys.control, 'ellipsoid')
    [p, P] = parameters(lsys.control);
    if size(BB, 2) == 1
      B            = reshape(BB, d1, du);
      mydata.Bp    = B * p;
      mydata.BPB   = B * P * B';
      mydata.BPBsr = sqrtm(mydata.BPB);
      mydata.BPBsr = 0.5*(mydata.BPBsr + (mydata.BPBsr)');
    else
      Bp    = [];
      BPB   = [];
      BPBsr = [];
      for i = 1:size(RS.time_values, 2)
        B     = reshape(BB(:, i), d1, du);
        Bp    = [Bp B*p];
	B     = B * P * B';
        BPB   = [BPB reshape(B, d1*d1, 1)];
	B     = sqrtm(B);
	B     = 0.5*(B + B');
        BPBsr = [BPBsr reshape(B, d1*d1, 1)];
      end
      if isdiscrete(lsys)
        mydata.Bp    = Bp;
        mydata.BPB   = BPB;
        mydata.BPBsr = BPBsr;
      else
        mydata.Bp    = spline(RS.time_values, Bp);
        mydata.BPB   = spline(RS.time_values, BPB);
        mydata.BPBsr = spline(RS.time_values, BPBsr);
      end
    end
  elseif isa(lsys.control, 'double')
    p  = lsys.control;
    if size(BB, 2) == 1
      mydata.Bp = reshape(BB, d1, du) * p;
    else
      Bp = [];
      for i = 1:size(RS.time_values, 2)
        B  = reshape(BB(:, i), d1, du);
        Bp = [Bp B*p];
      end
      if isdiscrete(lsys)
        mydata.Bp = Bp;
      else
        mydata.Bp = spline(RS.time_values, Bp);
      end
    end
  elseif iscell(lsys.control)
    p  = lsys.control;
    Bp = [];
    for i = 1:size(RS.time_values, 2)
      if size(BB, 2) == 1
        B = reshape(BB, d1, du);
      else
        B = reshape(BB(:, i), d1, du);
      end
      Bp = [Bp B*reach.matrix_eval(p, RS.time_values(i))];
    end
    if isdiscrete(lsys)
      mydata.Bp = Bp;
    else
      mydata.Bp = spline(RS.time_values, Bp);
    end
  elseif isstruct(lsys.control)
    if size(BB, 2) == 1
      B = reshape(BB, d1, du);
      if iscell(lsys.control.center) & iscell(lsys.control.shape)
        Bp    = [];
        BPB   = [];
        BPBsr = [];
        for i = 1:size(RS.time_values, 2)
          p = reach.matrix_eval(lsys.control.center, RS.time_values(i));
          P = reach.matrix_eval(lsys.control.shape, RS.time_values(i));
          if (P ~= P') | (min(eig(P)) < 0)
            error('EVOLVE: shape matrix of ellipsoidal control bounds must be positive definite.')
          end
          Bp    = [Bp B*p];
	  P     = B * P * B';
          BPB   = [BPB reshape(P, d1*d1, 1)];
          P     = sqrtm(P);
	  P     = 0.5*(P + P');
          BPBsr = [BPBsr reshape(P, d1*d1, 1)];
        end
        if isdiscrete(lsys)
          mydata.Bp    = Bp;
          mydata.BPB   = BPB;
          mydata.BPBsr = BPBsr;
        else
          mydata.Bp    = spline(RS.time_values, Bp);
          mydata.BPB   = spline(RS.time_values, BPB);
          mydata.BPBsr = spline(RS.time_values, BPBsr);
        end
      elseif iscell(lsys.control.center)
        Bp  = [];
        for i = 1:size(RS.time_values, 2)
          p  = reach.matrix_eval(lsys.control.center, RS.time_values(i));
          Bp = [Bp B*p];
        end
        if isdiscrete(lsys)
          mydata.Bp  = Bp;
        else
          mydata.Bp  = spline(RS.time_values, Bp);
        end
        mydata.BPB   = B * lsys.control.shape * B';
        mydata.BPBsr = sqrtm(mydata.BPB);
        mydata.BPBsr = 0.5*(mydata.BPBsr + (mydata.BPBsr)');
      else
        BPB   = [];
        BPBsr = [];
        for i = 1:size(RS.time_values, 2)
          P   = reach.matrix_eval(lsys.control.shape, RS.time_values(i));
          if (P ~= P') | (min(eig(P)) < 0)
            error('EVOLVE: shape matrix of ellipsoidal control bounds must be positive definite.')
          end
          P     = B * P * B';
          BPB   = [BPB reshape(P, d1*d1, 1)];
          P     = sqrtm(P);
          P     = 0.5*(P + P');
          BPBsr = [BPBsr reshape(P, d1*d1, 1)];
        end
        mydata.Bp = B * lsys.control.center;
        if isdiscrete(lsys)
          mydata.BPB   = BPB;
          mydata.BPBsr = BPBsr;
        else
          mydata.BPB   = spline(RS.time_values, BPB);
          mydata.BPBsr = spline(RS.time_values, BPBsr);
        end
      end
    else
      Bp    = [];
      BPB   = [];
      BPBsr = [];
      for i = 1:size(RS.time_values, 2)
        B = reshape(BB(:, i), d1, du);
        if iscell(lsys.control.center)
          p = reach.matrix_eval(lsys.control.center, RS.time_values(i));
        else
          p = lsys.control.center;
        end
        if iscell(lsys.control.shape)
          P = reach.matrix_eval(lsys.control.shape, RS.time_values(i));
          if (P ~= P') | (min(eig(P)) < 0)
            error('EVOLVE: shape matrix of ellipsoidal control bounds must be positive definite.')
          end
        else
          P = lsys.control.shape;
        end
        Bp    = [Bp B*p];
        P     = B * P * B';
        BPB   = [BPB reshape(P, d1*d1, 1)];
        P     = sqrtm(P);
        P     = 0.5*(P + P');
        BPBsr = [BPBsr reshape(P, d1*d1, 1)];
      end
      if isdiscrete(lsys)
        mydata.Bp    = Bp;
        mydata.BPB   = BPB;
        mydata.BPBsr = BPBsr;
      else
        mydata.Bp    = spline(RS.time_values, Bp);
        mydata.BPB   = spline(RS.time_values, BPB);
        mydata.BPBsr = spline(RS.time_values, BPBsr);
      end
    end
  end

  % expressions Gq and GQG'
  if ~(isempty(GG))
    if isa(lsys.disturbance, 'ellipsoid')
      [q, Q] = parameters(lsys.disturbance);
      if size(GG, 2) == 1
        G            = reshape(GG, d1, dd);
        mydata.Gq    = G * q;
        mydata.GQG   = G * Q * G';
        mydata.GQGsr = sqrtm(mydata.GQG);
        mydata.GQGsr = 0.5*(mydata.GQGsr + (mydata.GQGsr)');
      else
        Gq    = [];
        GQG   = [];
        GQGsr = [];
        for i = 1:size(RS.time_values, 2)
          G     = reshape(GG(:, i), d1, dd);
          Gq    = [Gq G*q];
          G     = G * Q * G';
          GQG   = [GQG reshape(G, d1*d1, 1)];
          G     = sqrtm(G);
          G     = 0.5*(G + G');
          GQGsr = [GQGsr reshape(G, d1*d1, 1)];
        end
        if isdiscrete(lsys)
          mydata.Gq    = Gq;
          mydata.GQG   = GQG;
          mydata.GQGsr = GQGsr;
        else
          mydata.Gq    = spline(RS.time_values, Gq);
          mydata.GQG   = spline(RS.time_values, GQG);
          mydata.GQGsr = spline(RS.time_values, GQGsr);
        end
      end
    elseif isa(lsys.disturbance, 'double')
      q  = lsys.disturbance;
      if size(GG, 2) == 1
        mydata.Gq = reshape(GG, d1, dd) * q;
      else
        Gq = [];
        for i = 1:size(RS.time_values, 2)
          G  = reshape(GG(:, i), d1, dd);
          Gq = [Gq G*q];
        end
        if isdiscrete(lsys)
          mydata.Gq = Gq;
        else
          mydata.Gq = spline(RS.time_values, Gq);
        end
      end
    elseif iscell(lsys.disturbance)
      q  = lsys.disturbance;
      Gq = [];
      for i = 1:size(RS.time_values, 2)
        if size(GG, 2) == 1
          G = reshape(GG, d1, dd);
        else
          G = reshape(GG(:, i), d1, dd);
        end
        Gq = [Gq G*reach.matrix_eval(q, RS.time_values(i), isdiscrete(lsys))];
      end
      if isdiscrete(lsys)
        mydata.Gq = Gq;
      else
        mydata.Gq = spline(RS.time_values, Gq);
      end
    elseif isstruct(lsys.disturbance)
      if size(GG, 2) == 1
        G = reshape(GG, d1, dd);
        if iscell(lsys.disturbance.center) & iscell(lsys.disturbance.shape)
          Gq    = [];
          GQG   = [];
          GQGsr = [];
          for i = 1:size(RS.time_values, 2)
            q = reach.matrix_eval(lsys.disturbance.center, RS.time_values(i));
            Q = reach.matrix_eval(lsys.disturbance.shape, RS.time_values(i));
            if (Q ~= Q') | (min(eig(Q)) < 0)
              error('EVOLVE: shape matrix of ellipsoidal disturbance bounds must be positive definite.')
            end
            Gq    = [Gq G*q];
            Q     = G * Q * G';
            GQG   = [GQG reshape(Q, d1*d1, 1)];
            Q     = sqrtm(Q);
            Q     = 0.5*(Q + Q');
            GQGsr = [GQGsr reshape(Q, d1*d1, 1)];
          end
          if isdiscrete(lsys)
            mydata.Gq    = Gq;
            mydata.GQG   = GQG;
            mydata.GQGsr = GQGsr;
          else
            mydata.Gq    = spline(RS.time_values, Gq);
            mydata.GQG   = spline(RS.time_values, GQG);
            mydata.GQGsr = spline(RS.time_values, GQGsr);
          end
        elseif iscell(lsys.disturbance.center)
          Gq  = [];
          for i = 1:size(RS.time_values, 2)
            q  = reach.matrix_eval(lsys.disturbance.center, RS.time_values(i));
            Gq = [Gq G*q];
          end
          if isdiscrete(lsys)
            mydata.Gq  = Gq;
          else
            mydata.Gq  = spline(RS.time_values, Gq);
          end
          mydata.GQG   = G * lsys.disturbance.shape * G';
          mydata.GQGsr = sqrtm(mydata.GQG);
          mydata.GQGsr = 0.5*(mydata.GQGsr + (mydata.GQGsr)');
        else
          GQG   = [];
          GQGsr = [];
          for i = 1:size(RS.time_values, 2)
            Q   = reach.matrix_eval(lsys.disturbance.shape, RS.time_values(i));
            if (Q ~= Q') | (min(eig(Q)) < 0)
              error('EVOLVE: shape matrix of ellipsoidal disturbance bounds must be positive definite.')
            end
            Q     = G * Q * G';
            GQG   = [GQG reshape(Q, d1*d1, 1)];
            Q     = sqrtm(Q);
            Q     = 0.5*(Q + Q');
            GQGsr = [GQGsr reshape(Q, d1*d1, 1)];
          end
          mydata.Gq  = G * lsys.disturbance.center;
          if isdiscrete(lsys)
            mydata.GQG   = GQG;
            mydata.GQGsr = GQGsr;
          else
            mydata.GQG   = spline(RS.time_values, GQG);
            mydata.GQGsr = spline(RS.time_values, GQGsr);
          end
        end
      else
        Gq    = [];
        GQG   = [];
        GQGsr = [];
        for i = 1:size(RS.time_values, 2)
          G = reshape(GG(:, i), d1, dd);
          if iscell(lsys.disturbance.center)
            q = reach.matrix_eval(lsys.disturbance.center, RS.time_values(i));
          else
            q = lsys.disturbance.center;
          end
          if iscell(lsys.disturbance.shape)
            Q = reach.matrix_eval(lsys.disturbance.shape, RS.time_values(i));
            if (Q ~= Q') | (min(eig(Q)) < 0)
              error('EVOLVE: shape matrix of ellipsoidal disturbance bounds must be positive definite.')
            end
          else
            Q = lsys.disturbance.shape;
          end
          Gq  = [Gq G*q];
          Q     = G * Q * G';
          GQG   = [GQG reshape(Q, d1*d1, 1)];
          Q     = sqrtm(Q);
          Q     = 0.5*(Q + Q');
          GQGsr = [GQGsr reshape(Q, d1*d1, 1)];
        end
        if isdiscrete(lsys)
          mydata.Gq    = Gq;
          mydata.GQG   = GQG;
          mydata.GQGsr = GQGsr;
        else
          mydata.Gq    = spline(RS.time_values, Gq);
          mydata.GQG   = spline(RS.time_values, GQG);
          mydata.GQGsr = spline(RS.time_values, GQGsr);
        end
      end
    end
  end

  % expressions w and W
  if ~(isempty(lsys.noise))
    if isa(lsys.noise, 'ellipsoid')
      [w, W]   = parameters(lsys.noise);
      mydata.w = w;
      mydata.W = W;
    elseif isa(lsys.noise, 'double')
      mydata.w = lsys.noise;
    elseif iscell(lsys.noise)
      w = [];
      for i = 1:size(RS.time_values, 2)
        w = [w reach.matrix_eval(lsys.noise.center, RS.time_values(i))];
      end
      if isdiscrete(lsys)
        mydata.w = w;
      else
        mydata.w = spline(RS.time_values, w);
      end
    elseif isstruct(lsys.noise)
      if iscell(lsys.noise.center) & iscell(lsys.noise.shape)
        w = [];
        W = [];
        for i = 1:size(RS.time_values, 2)
          w  = [w reach.matrix_eval(lsys.noise.center, RS.time_values(i))];
          ww = reach.matrix_eval(lsys.noise.shape, RS.time_values(i));
          if (ww ~= ww') | (min(eig(ww)) < 0)
            error('EVOLVE: shape matrix of ellipsoidal noise bounds must be positive definite.')
          end
          W  = [W reshape(ww, dy*dy, 1)];
        end
        if isdiscrete(lsys)
          mydata.w = w;
          mydata.W = W
        else
          mydata.w = spline(RS.time_values, w);
          mydata.W = spline(RS.time_values, W);
        end
      elseif iscell(lsys.noise.center)
        w = [];
        for i = 1:size(RS.time_values, 2)
          w = [w reach.matrix_eval(lsys.noise.center, RS.time_values(i))];
        end
        if isdiscrete(lsys)
          mydata.w = w;
        else
          mydata.w = spline(RS.time_values, w);
        end
        mydata.W = lsys.noise.shape;
      else
        W = [];
        for i = 1:size(RS.time_values, 2)
          ww = reach.matrix_eval(lsys.noise.shape, RS.time_values(i));
          if (ww ~= ww') | (min(eig(ww)) < 0)
            error('EVOLVE: shape matrix of ellipsoidal noise bounds must be positive definite.')
          end
          W  = [W reshape(ww, dy*dy, 1)];
        end
        mydata.w = lsys.noise.center;
        if isdiscrete(lsys)
          mydata.W = W;
        else
          mydata.W = spline(RS.time_values, W);
        end
      end
    end
  end
  clear A B C AA BB CC DD Bp BPB Gq GQG p P q Q w W ww;



  

  %%% Compute state transition matrix. %%%

  if Properties.getIsVerbose()
    if isempty(logger)
      logger=Log4jConfigurator.getLogger();
    end
    logger.info('Computing state transition matrix...');
  end

  if isdiscrete(lsys)
%    if min(size(mydata.A) == [d1 d1]) > 0   % discrete system with constant A
%      t0    = RS.time_values(1);
%      Phi   = [];
%      Phinv = [];
%      for i = 1:size(RS.time_values, 2)
%        P     = (mydata.A)^(abs(RS.time_values(i) - t0));
%        PP    = ell_inv(P);
%        Phi   = [Phi reshape(P, d1*d1, 1)];
%        Phinv = [Phinv reshape(PP, d1*d1, 1)];
%      end
%      mydata.Phi   = Phi;
%      mydata.Phinv = Phinv;
%    else   % discrete system with A[k]
%      P     = eye(d1);
%      Phi   = reshape(P, d1*d1, 1);
%      Phinv = reshape(P, d1*d1, 1);
%      for i = 1:(size(RS.time_values, 2) - 1)
%        if back > 0
%          P = P * ell_value_extract(mydata.A, i+1, [d1 d1]);
%        else
%          P = ell_value_extract(mydata.A, i, [d1 d1]) * P;
%        end
%        PP    = ell_inv(P);
%        Phi   = [Phi reshape(P, d1*d1, 1)];
%        Phinv = [Phinv reshape(PP, d1*d1, 1)];
%      end
%      mydata.Phi   = Phi;
%      mydata.Phinv = Phinv;
%    end
    mydata.Phi   = [];
    mydata.Phinv = [];
  else
    if isa(mydata.A, 'double')   % continuous system with constant A
      t0    = RS.time_values(1);
      Phi   = [];
      Phinv = [];
      for i = 1:size(RS.time_values, 2)
        P     = expm(mydata.A * abs(RS.time_values(i) - t0));
        PP    = ell_inv(P);
        Phi   = [Phi reshape(P, d1*d1, 1)];
        Phinv = [Phinv reshape(PP, d1*d1, 1)];
      end
      mydata.Phi   = spline(RS.time_values, Phi);
      mydata.Phinv = spline(RS.time_values, Phinv);
    else   % continuous system with A(t)
      I0        = reshape(eye(d1), d1*d1, 1);
      [tt, Phi] = ell_ode_solver(@ell_stm_ode, tvals, I0, mydata, d1, back);
      Phi       = Phi';
      Phinv     = [];
      for i = 1:size(RS.time_values, 2)
        Phinv = [Phinv reshape(ell_inv(reshape(Phi(:, i), d1, d1)), d1*d1, 1)];
      end
      mydata.Phi   = spline(RS.time_values, Phi);
      mydata.Phinv = spline(RS.time_values, Phinv);
    end
  end
  clear Phi Phinv P PP t0 I0;




  
  %%% Compute the center of the reach set. %%%

  if Properties.getIsVerbose()
    if isempty(logger)
      logger=Log4jConfigurator.getLogger();
    end
    logger.info('Computing the trajectory of the reach set center...');
  end

  x0 = CRS.center_values(:, end);
  
  if isdiscrete(lsys)   % discrete-time system
    xx = x0;
    x  = x0;
    for i = 1:(size(RS.time_values, 2) - 1)
      Bp = ell_value_extract(mydata.Bp, i+back, [d1 1]);
      if ~(isempty(mydata.Gq))
        Gq = ell_value_extract(mydata.Gq, i+back, [d1 1]);
      else
        Gq = zeros(d1, 1);
      end
      if back > 0
        A = ell_value_extract(mydata.A, i+back, [d1 d1]);
        x = ell_inv(A)*(x - Bp - Gq);
      else
        A = ell_value_extract(AC, i, [d1 d1]);
        x = A*x + Bp + Gq;
      end
      xx = [xx x];
    end
  else   % continuous-time system
    [tt, xx] = ell_ode_solver(@ell_center_ode, tvals, x0, mydata, d1, back);
    xx       = xx';
  end
  RS.center_values = xx;
  clear A AC xx;




  
  %%% Compute external shape matrices. %%%

  if (Options.approximation ~= 1)
    if Properties.getIsVerbose()
      if isempty(logger)
        logger=Log4jConfigurator.getLogger();
      end
      logger.info('Computing external shape matrices...');
    end

    LL = [];
    QQ = [];
    N  = size(CRS.ea_values, 2);
    for ii = 1:N
      EM = CRS.ea_values{ii};
      Q0 = EM(:, end);
      l0 = RS.initial_directions(:, ii);
      if isdiscrete(lsys)   % discrete-time system
        if hasdisturbance(lsys)
          [Q, L] = reach.eedist_de(size(tvals, 2), ...
                             Q0, ...
                             l0, ...
                             mydata, ...
                             d1, ...
                             back, ...
                             Options.minmax, RS.absTol);
        elseif ~(isempty(mydata.BPB))
          [Q, L] = reach.eesm_de(size(tvals, 2), Q0, l0, mydata, d1, back,RS.absTol);
        else
          Q = [];
          L = [];
        end
        LL = [LL {L}];
      else   % continuous-time system
        if hasdisturbance(lsys)
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
    RS.ea_values = QQ;
  end



  
  %%% Compute internal shape matrices. %%%

  if (Options.approximation ~= 0)
    if Properties.getIsVerbose()
      if isempty(logger)
        logger=Log4jConfigurator.getLogger();
      end
      logger.info('Computing internal shape matrices...');
    end

    LL = [];
    QQ = [];
    N  = size(CRS.ia_values, 2);
    for ii = 1:N
      EM = CRS.ia_values{ii};
      Q0 = EM(:, end);
      X0 = reshape(Q0, d1, d1);
      X0 = sqrtm(X0);
      X0 = 0.5*(X0 + X0');
      l0 = RS.initial_directions(:, ii);
      if isdiscrete(lsys)   % discrete-time system
        if hasdisturbance(lsys)
          [Q, L] = reach.iedist_de(size(tvals, 2), ...
                             Q0, ...
                             l0, ...
                             mydata, ...
                             d1, ...
                             back, ...
                             Options.minmax,RS.absTol);
        elseif ~(isempty(mydata.BPB))
          [Q, L] = reach.iesm_de(size(tvals, 2), Q0, l0, mydata, d1, back,RS.absTol);
        else
          Q = [];
          L = [];
        end
        LL = [LL {L}];
      else   % continuous-time system
        if hasdisturbance(lsys)
          [tt, Q] = ell_ode_solver(@ell_iedist_ode, tvals, reshape(Q0, d1*d1, 1), l0, mydata, d1, back);
          Q       = Q';
        elseif ~(isempty(mydata.BPB))
          [tt, Q] = ell_ode_solver(@ell_iesm_ode, tvals, reshape(X0, d1*d1, 1), X0*l0, l0, mydata, d1, back);
          Q       = reach.fix_iesm(Q', d1);
        else
          Q = [];
        end
      end
      QQ = [QQ {Q}];
    end
    RS.ia_values = QQ;
  end
  
  if Options.save_all > 0
    RS.calc_data = mydata;
  end
  
  LL = [];
  for ii = 1:N
    l0 = RS.initial_directions(:, ii);
    if isdiscrete(lsys)   % discrete-time system
      L = l0;
      l = l0;
      if back > 0
        for i = 2:size(RS.time_values, 2)
          A = ell_value_extract(mydata.A, i, [d1 d1]);
          l = A' * l;
          L = [L l];
        end
      else
        for i = 1:(size(RS.time_values, 2) - 1)
          A = ell_inv(ell_value_extract(mydata.A, i, [d1 d1]));
          l = A' * l;
          L = [L l];
        end
      end
    else   % continuous-time system
      L = [];
      for i = 1:size(RS.time_values, 2)
        t = RS.time_values(i);
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

  RS.l_values = LL;

  if www(1).state
    warning on;
  end

  return;
