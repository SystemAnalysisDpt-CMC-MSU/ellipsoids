classdef reach < handle
%REACH class of reach sets
    properties
        absTol
        relTol 
        nPlot2dPoints
        nPlot3dPoints
        nTimeGridPoints
        system
        t0
        X0
        initial_directions
        time_values
        center_values
        l_values 
        ea_values
        ia_values
        mu_values
        minmax
        projection_basis
        calc_data
    end
    methods
        function RS = reach(lsys, X0, L0, T, Options,varargin)
        % REACH - computes reach set approximation of the linear system for the given
        %         time interval.
        %
        %
        % Description:
        % ------------
        %
        % RS = REACH(LSYS, X0, L0, T, Options)  Given ellipsoidal set of initial conditions X0,
        %                                       computes the reach set approximations of
        %                                       linear system LSYS in directions specified
        %                                       by columns of matrix L0 for the time
        %                                       interval T, T = [t0 t1] (T = [k0 k1] in
        %                                       discrete-time case), using options 
        %                                       in the Options structure:
        %                                         Options.approximation = 0 for external,
        %                                                               = 1 for internal,
        %                                                               = 2 for both (default).
        %                                         Options.save_all = 1 to save intermediate
        %                                                              calculation data,
        %                                                          = 0 (default) to delete intermediate
        %                                                              calculation data.
        %                                         Options.minmax = 1 compute minmax reach set,
        %                                                        = 0 (default) compute maxmin reach set.
        %                                                        This option makes sense only for
        %                                                        discrete-time systems with disturbance.
        %                                       
        %
        % RS = REACH(LSYS, X0, L0, T, Options, prop) the same as RS = REACH(LSYS, X0, L0, T, Options), 
        %                                            but with "Properties" specified in prop. In other cases 
        %                                            "Properties" are taken from current values stored in elltool.conf.Properties
        % As "Properties" we understand here such list of ellipsoid
        % properties:
        %       absTol
        %       relTol 
        %       nPlot2dPoints
        %       nPlot3dPoints
        %       nTimeGridPoints
        % Output:
        % -------
        %
        %    RS - reach set object.
        %
        %
        % See also:
        % ---------
        %
        %    REACH/CONTENTS.
        %

        %
        % Author:
        % -------
        %
        %    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
        %

        display(varargin);
          import elltool.conf.Properties;
          neededPropNameList = {'absTol','relTol','nPlot2dPoints','nPlot3dPoints','nTimeGridPoints'};
          [absTolVal, relTolVal, nPlot2dPointsVal,nPlot3dPointsVal,nTimeGridPointsVal] =...
                            elltool.conf.Properties.parseProp(varargin,neededPropNameList);

          RS.absTol = absTolVal;
          RS.relTol = relTolVal;
          RS.nPlot2dPoints = nPlot2dPointsVal;
          RS.nPlot3dPoints = nPlot3dPointsVal;
          RS.nTimeGridPoints = nTimeGridPointsVal;
          if isstruct(lsys) & (nargin == 1)
            return;
          end


          RS.system             = [];
          RS.t0                 = [];
          RS.X0                 = [];
          RS.initial_directions = [];
          RS.time_values        = [];
          RS.center_values      = [];
          RS.l_values           = [];
          RS.ea_values          = [];
          RS.ia_values          = [];
          RS.mu_values          = [];
          RS.minmax             = [];
          RS.projection_basis   = [];
          RS.calc_data          = [];

          if (nargin == 0) | isempty(lsys)
            return;
          end

          if nargin < 4
            error('REACH: insufficient number of input arguments.');
          end

          if ~(isa(lsys, 'linsys'))
            error('REACH: first input argument must be linear system object.');
          end
          lsys = lsys(1, 1);
          [d1, du, dy, dd] = dimension(lsys);

          if ~(isa(X0, 'ellipsoid'))
            error('REACH: set of initial conditions must be ellipsoid.');
          end
          X0 = X0(1, 1);
          d2 = dimension(X0);

          if d1 ~= d2
            error('REACH: dimensions of linear system and set of initial conditions do not match.');
          end

          [k, l] = size(T);
          if ~(isa(T, 'double')) | (k ~= 1) | ((l ~= 2) & (l ~= 1))
            error('REACH: time interval must be specified as ''[t0 t1]'', or, in discrete-time - as ''[k0 k1]''.');
          end

          [m, N] = size(L0);
          if m ~= d2
            error('REACH: dimensions of state space and direction vector do not match.');
          end

          if (nargin < 5) | ~(isstruct(Options))
            Options               = [];
            Options.approximation = 2;
            Options.save_all      = 0;
            Options.minmax        = 0;
          else
            if ~(isfield(Options, 'approximation')) | ...
                 (Options.approximation < 0) | (Options.approximation > 2)
              Options.approximation = 2;
            end
            if ~(isfield(Options, 'save_all')) | ...
                 (Options.save_all < 0) | (Options.save_all > 2)
              Options.save_all = 0;
            end
            if ~(isfield(Options, 'minmax')) | ...
                 (Options.minmax < 0) | (Options.minmax > 1)
              Options.minmax = 0;
            end
          end

          RS.system             = lsys;
          RS.X0                 = X0;
          RS.initial_directions = L0;
          RS.minmax             = Options.minmax;

          % Create time grid
          if isdiscrete(lsys)
            if size(T, 2) == 1
              RS.t0 = 0;
              h     = round(T);
            else
              RS.t0 = round(T(1));
              h     = round(T(2));
            end
            if h < RS.t0
              RS.time_values = fliplr(h:(RS.t0));
            else
              RS.time_values = (RS.t0):h;
            end
          else
            if size(T, 2) == 1
              RS.time_values = linspace(0, T, nTimeGridPointsVal());
              RS.t0          = 0;
            else
              RS.time_values = linspace(T(1), T(2), nTimeGridPointsVal());
              RS.t0          = T(1);
            end
          end

          if RS.time_values(1) > RS.time_values(end)
            back  = 1;
            tvals = - RS.time_values;
          else
            back  = 0;
            tvals = RS.time_values;
          end

          www = warning;
          warning off;

          %%% Perform matrix, control, disturbance and noise evaluations. %%%
          %%% Create splines if needed.                                   %%%

          if Properties.getIsVerbose()
            fprintf('Performing preliminary function evaluations...\n');
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
            AA = zeros(d1*d1, size(RS.time_values, 2));
            DD = zeros(1, size(RS.time_values, 2));
            AC = zeros(d1*d1, size(RS.time_values, 2));
            for i = 1:size(RS.time_values, 2)
              if (back > 0) & ~(isdiscrete(lsys)) & 0
                A  = matrix_eval(lsys.A, -RS.time_values(i));
              else
                A  = matrix_eval(lsys.A, RS.time_values(i));
              end
              AC(:, i) = reshape(A, d1*d1, 1);
              if isdiscrete(lsys) & (rank(A) < d1)
                A        = ell_regularize(A);
                DD(1, i) = 1;
              elseif isdiscrete(lsys)
                DD(1, i) = 0;
              end
              AA(:, i) = reshape(A, d1*d1, 1);
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
            BB = zeros(d1*du, size(RS.time_values, 2));
            for i = 1:size(RS.time_values, 2)
              B        = matrix_eval(lsys.B, RS.time_values(i));
              BB(:, i) = reshape(B, d1*du, 1);
            end
          else
            BB = reshape(lsys.B, d1*du, 1);
          end

          % matrix G
          GG = zeros(d1*dd, size(RS.time_values, 2));
          if iscell(lsys.G)
            for i = 1:size(RS.time_values, 2)
              B        = matrix_eval(lsys.G, RS.time_values(i));
              GG(:, i) = reshape(B, d1*dd, 1);
            end
          elseif ~(isempty(lsys.G))
            GG = reshape(lsys.G, d1*dd, 1);
          end

          % matrix C
          if iscell(lsys.C)
            CC = zeros(d1*dy, size(RS.time_values, 2));
            for i = 1:size(RS.time_values, 2)
              C        = matrix_eval(lsys.C, RS.time_values(i));
              CC(:, i) = reshape(C, d1*dy, 1);
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
              mydata.BPBsr = sqrtm(full(mydata.BPB));
              mydata.BPBsr = 0.5*(mydata.BPBsr + (mydata.BPBsr)');
            else
              Bp    = zeros(d1, size(RS.time_values, 2));
              BPB   = zeros(d1*d1, size(RS.time_values, 2));
              BPBsr = zeros(d1*d1, size(RS.time_values, 2));
              for i = 1:size(RS.time_values, 2)
                B           = reshape(BB(:, i), d1, du);
                Bp(:, i)    = B*p;
                B           = B * P * B';
                BPB(:, i)   = reshape(B, d1*d1, 1);
                B           = sqrtm(B);
                B           = 0.5*(B + B');
                BPBsr(:, i) = reshape(B, d1*d1, 1);
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
              Bp = zeros(d1, size(RS.time_values, 2));
              for i = 1:size(RS.time_values, 2)
                B        = reshape(BB(:, i), d1, du);
                Bp(:, i) = B*p;
              end
              if isdiscrete(lsys)
                mydata.Bp = Bp;
              else
                mydata.Bp = spline(RS.time_values, Bp);
              end
            end
          elseif iscell(lsys.control)
            p  = lsys.control;
            Bp = zeros(d1, size(RS.time_values, 2));
            for i = 1:size(RS.time_values, 2)
              if size(BB, 2) == 1
                B = reshape(BB, d1, du);
              else
                B = reshape(BB(:, i), d1, du);
              end
              Bp(:, i) = B*matrix_eval(p, RS.time_values(i));
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
                Bp    = zeros(d1, size(RS.time_values, 2));
                BPB   = zeros(d1*d1, size(RS.time_values, 2));
                BPBsr = zeros(d1*d1, size(RS.time_values, 2));
                for i = 1:size(RS.time_values, 2)
                  p = matrix_eval(lsys.control.center, RS.time_values(i));
                  P = matrix_eval(lsys.control.shape, RS.time_values(i));
                  if (P ~= P') | (min(eig(P)) < 0)
                    error('REACH: shape matrix of ellipsoidal control bounds must be positive definite.')
                  end
                  Bp(:, i)    = B*p;
                  P           = B * P * B';
                  BPB(:, i)   = reshape(P, d1*d1, 1);
              P           = sqrtm(P);
              P           = 0.5*(P + P');
                  BPBsr(:, i) = reshape(P, d1*d1, 1);
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
                Bp  = zeros(d1, size(RS.time_values, 2));
                for i = 1:size(RS.time_values, 2)
                  p  = matrix_eval(lsys.control.center, RS.time_values(i));
                  Bp(:, i) = B*p;
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
                BPB   = zeros(d1*d1, size(RS.time_values, 2));
                BPBsr = zeros(d1*d1, size(RS.time_values, 2));
                for i = 1:size(RS.time_values, 2)
                  P = matrix_eval(lsys.control.shape, RS.time_values(i));
                  if (P ~= P') | (min(eig(P)) < 0)
                    error('REACH: shape matrix of ellipsoidal control bounds must be positive definite.')
                  end
                  P           = B * P * B';
                  BPB(:, i)   = reshape(P, d1*d1, 1);
                  P           = sqrtm(P);
                  P           = 0.5*(P + P');
                  BPBsr(:, i) = reshape(P, d1*d1, 1);
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
              Bp    = zeros(d1, size(RS.time_values, 2));
              BPB   = zeros(d1*d1, size(RS.time_values, 2));
              BPBsr = zeros(d1*d1, size(RS.time_values, 2));
              for i = 1:size(RS.time_values, 2)
                B = reshape(BB(:, i), d1, du);
                if iscell(lsys.control.center)
                  p = matrix_eval(lsys.control.center, RS.time_values(i));
                else
                  p = lsys.control.center;
                end
                if iscell(lsys.control.shape)
                  P = matrix_eval(lsys.control.shape, RS.time_values(i));
                  if (P ~= P') | (min(eig(P)) < 0)
                    error('REACH: shape matrix of ellipsoidal control bounds must be positive definite.')
                  end
                else
                  P = lsys.control.shape;
                end
                Bp(:, i)    = B*p;
                P           = B * P * B';
                BPB(:, i)   = reshape(P, d1*d1, 1);
                P           = sqrtm(P);
                P           = 0.5*(P + P');
                BPBsr(:, i) = reshape(P, d1*d1, 1);
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
                Gq    = zeros(d1, size(RS.time_values, 2));
                GQG   = zeros(d1*d1, size(RS.time_values, 2));
                GQGsr = zeros(d1*d1, size(RS.time_values, 2));
                for i = 1:size(RS.time_values, 2)
                  G           = reshape(GG(:, i), d1, dd);
                  Gq(:, i)    = G*q;
                  G           = G * Q * G';
                  GQG(:, i)   = reshape(G, d1*d1, 1);
                  G           = sqrtm(G);
                  G           = 0.5*(G + G');
                  GQGsr(:, i) = reshape(G, d1*d1, 1);
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
                Gq = zeros(d1, size(RS.time_values, 2));
                for i = 1:size(RS.time_values, 2)
                  G  = reshape(GG(:, i), d1, dd);
                  Gq(:, i) = G*q;
                end
                if isdiscrete(lsys)
                  mydata.Gq = Gq;
                else
                  mydata.Gq = spline(RS.time_values, Gq);
                end
              end
            elseif iscell(lsys.disturbance)
              q  = lsys.disturbance;
              Gq = zeros(d1, size(RS.time_values, 2));
              for i = 1:size(RS.time_values, 2)
                if size(GG, 2) == 1
                  G = reshape(GG, d1, dd);
                else
                  G = reshape(GG(:, i), d1, dd);
                end
                Gq(:, i) = G*matrix_eval(q, RS.time_values(i));
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
                  Gq    = zeros(d1, size(RS.time_values, 2));
                  GQG   = zeros(d1*d1, size(RS.time_values, 2));
                  GQGsr = zeros(d1*d1, size(RS.time_values, 2));
                  for i = 1:size(RS.time_values, 2)
                    q = matrix_eval(lsys.disturbance.center, RS.time_values(i));
                    Q = matrix_eval(lsys.disturbance.shape, RS.time_values(i));
                    if (Q ~= Q') | (min(eig(Q)) < 0)
                      error('REACH: shape matrix of ellipsoidal disturbance bounds must be positive definite.')
                    end
                    Gq(:, i)    = G*q;
                    Q           = G * Q * G';
                    GQG(:, i)   = reshape(Q, d1*d1, 1);
                    Q           = sqrtm(Q);
                    Q           = 0.5*(Q + Q');
                    GQGsr(:, i) = reshape(Q, d1*d1, 1);
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
                  Gq  = zeros(d1, size(RS.time_values, 2));
                  for i = 1:size(RS.time_values, 2)
                    q  = matrix_eval(lsys.disturbance.center, RS.time_values(i));
                    Gq(:, i) = G*q;
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
                  GQG   = zeros(d1*d1, size(RS.time_values, 2));
                  GQGsr = zeros(d1*d1, size(RS.time_values, 2));
                  for i = 1:size(RS.time_values, 2)
                    Q = matrix_eval(lsys.disturbance.shape, RS.time_values(i));
                    if (Q ~= Q') | (min(eig(Q)) < 0)
                      error('REACH: shape matrix of ellipsoidal disturbance bounds must be positive definite.')
                    end
                    Q           = G * Q * G';
                    GQG(:, i)   = reshape(Q, d1*d1, 1);
                    Q           = sqrtm(Q);
                    Q           = 0.5*(Q + Q');
                    GQGsr(:, i) = reshape(Q, d1*d1, 1);
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
                Gq    = zeros(d1, size(RS.time_values, 2));
                GQG   = zeros(d1*d1, size(RS.time_values, 2));
                GQGsr = zeros(d1*d1, size(RS.time_values, 2));
                for i = 1:size(RS.time_values, 2)
                  G = reshape(GG(:, i), d1, dd);
                  if iscell(lsys.disturbance.center)
                    q = matrix_eval(lsys.disturbance.center, RS.time_values(i));
                  else
                    q = lsys.disturbance.center;
                  end
                  if iscell(lsys.disturbance.shape)
                    Q = matrix_eval(lsys.disturbance.shape, RS.time_values(i));
                    if (Q ~= Q') | (min(eig(Q)) < 0)
                      error('REACH: shape matrix of ellipsoidal disturbance bounds must be positive definite.')
                    end
                  else
                    Q = lsys.disturbance.shape;
                  end
                  Gq(:, i)    = G*q;
                  Q           = G * Q * G';
                  GQG(:, i)   = reshape(Q, d1*d1, 1);
                  Q           = sqrtm(Q);
                  Q           = 0.5*(Q + Q');
                  GQGsr(:, i) = reshape(Q, d1*d1, 1);
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
                w = [w matrix_eval(lsys.noise.center, RS.time_values(i))];
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
                  w  = [w matrix_eval(lsys.noise.center, RS.time_values(i))];
                  ww = matrix_eval(lsys.noise.shape, RS.time_values(i));
                  if (ww ~= ww') | (min(eig(ww)) < 0)
                    error('REACH: shape matrix of ellipsoidal noise bounds must be positive definite.')
                  end
                  W  = [W reshape(ww, dy*dy, 1)];
                end
                if isdiscrete(lsys)
                  mydata.w = w;
                  mydata.W = W;
                else
                  mydata.w = spline(RS.time_values, w);
                  mydata.W = spline(RS.time_values, W);
                end
              elseif iscell(lsys.noise.center)
                w = [];
                for i = 1:size(RS.time_values, 2)
                  w = [w matrix_eval(lsys.noise.center, RS.time_values(i))];
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
                  ww = matrix_eval(lsys.noise.shape, RS.time_values(i));
                  if (ww ~= ww') | (min(eig(ww)) < 0)
                    error('REACH: shape matrix of ellipsoidal noise bounds must be positive definite.')
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
            fprintf('Computing state transition matrix...\n');
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
              Phi   = zeros(d1*d1, size(RS.time_values, 2));
              Phinv = zeros(d1*d1, size(RS.time_values, 2));
              for i = 1:size(RS.time_values, 2)
                P           = expm(mydata.A * abs(RS.time_values(i) - t0));
                PP          = ell_inv(P);
                Phi(:, i)   = reshape(P, d1*d1, 1);
                Phinv(:, i) = reshape(PP, d1*d1, 1);
              end
              mydata.Phi   = spline(RS.time_values, Phi);
              mydata.Phinv = spline(RS.time_values, Phinv);
            else   % continuous system with A(t)
              I0        = reshape(eye(d1), d1*d1, 1);
              [tt, Phi] = ell_ode_solver(@ell_stm_ode, tvals, I0, mydata, d1, back);
              Phi       = Phi';
              Phinv     = zeros(d1*d1, size(RS.time_values, 2));
              for i = 1:size(RS.time_values, 2)
                Phinv(:, i) = reshape(ell_inv(reshape(Phi(:, i), d1, d1)), d1*d1, 1);
              end
              mydata.Phi   = spline(RS.time_values, Phi);
              mydata.Phinv = spline(RS.time_values, Phinv);
            end
          end
          clear Phi Phinv P PP t0 I0;





          %%% Compute the center of the reach set. %%%

          if Properties.getIsVerbose()
            fprintf('Computing the trajectory of the reach set center...\n');
          end

          [x0, X0] = parameters(X0);

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
              fprintf('Computing external shape matrices...\n');
            end

            LL = [];
            QQ = [];
            Q0 = reshape(X0, d1*d1, 1);
            for ii = 1:N
              l0 = L0(:, ii);
              if isdiscrete(lsys)   % discrete-time system
                if hasdisturbance(lsys)
                  [Q, L] = eedist_de(size(tvals, 2), ...
                                     Q0, ...
                                     l0, ...
                                     mydata, ...
                                     d1, ...
                                     back, ...
                                     Options.minmaxRS.absTol);
                elseif ~(isempty(mydata.BPB))
                  [Q, L] = eesm_de(size(tvals, 2), Q0, l0, mydata, d1, back,RS.absTol);
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
              fprintf('Computing internal shape matrices...\n');
            end

            LL = [];
            QQ = [];
            Q0 = reshape(X0, d1*d1, 1);
            M  = sqrtm(X0);
            M  = 0.5*(M + M');
            for ii = 1:N
              l0 = L0(:, ii);
              if isdiscrete(lsys)   % discrete-time system
                if hasdisturbance(lsys)
                  [Q, L] = iedist_de(size(tvals, 2), ...
                                     Q0, ...
                                     l0, ...
                                     mydata, ...
                                     d1, ...
                                     back, ...
                                     Options.minmax, RS.absTol);
                elseif ~(isempty(mydata.BPB))
                  [Q, L] = iesm_de(size(tvals, 2), Q0, l0, mydata, d1, back,RS.absTol);
                else
                  Q = [];
                  L = [];
                end
                LL = [LL {L}];
              else   % continuous-time system
                if hasdisturbance(lsys)
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
            RS.ia_values = QQ;
          end

          if Options.save_all > 0
            RS.calc_data = mydata;
          end

          if ~isdiscrete(lsys)
            LL = [];
            for ii = 1:N
              l0 = L0(:, ii);
              L  = zeros(d1, size(RS.time_values, 2));
              for i = 1:size(RS.time_values, 2)
                t = RS.time_values(i);
                if back > 0
                  F = ell_value_extract(mydata.Phi, t, [d1 d1]);
                else
                  F = ell_value_extract(mydata.Phinv, t, [d1 d1]);
                end
                L(:, i) = F'*l0;
              end
              LL = [LL {L}];
            end
          end

          RS.l_values = LL;

          if www(1).state
            warning on;
          end

        end
    end
    
    methods(Access = private)
        propValMat = getProperty(rsMat,propName)
    end
end
