function [QQ, LL] = iedist_de(ntv, X0, l0, mydata, N, back, mnmx)
%
% IEDIST_DE - recurrence relation for the shape matrix of internal ellipsoid
%             for discrete-time system with disturbance.
%

  global ellOptions;

  LL                 = l0;
  l                  = l0;
  QQ                 = X0;
  Q                  = reshape(X0, N, N);
  vrb                = ellOptions.verbose;
  ellOptions.verbose = 0;

  if back > 0
    for i = 2:ntv
      A   = ell_value_extract(mydata.A, i, [N N]);
      Ai  = ell_inv(A);
      BPB = Ai * ell_value_extract(mydata.BPB, i, [N N]) * Ai';
      GQG = Ai * ell_value_extract(mydata.GQG, i, [N N]) * Ai';
      BPB = 0.5 * (BPB + BPB');
      GQG = 0.5 * (GQG + GQG');
      Q   = Ai * Q * Ai';
      if rank(Q) < N
        Q = ell_regularize(Q);
      end
      if rank(BPB) < N
        BPB = ell_regularize(BPB);
      end
      if rank(GQG) < N
        GQG = ell_regularize(GQG);
      end
      l = A' * l;
      if mnmx > 0 % minmax case
        E = minkmp_ia(ellipsoid(0.5*(Q+Q')), ellipsoid(0.5*(GQG+GQG')), ellipsoid(0.5*(BPB+BPB')), l);
      else
        E = minkpm_ia([ellipsoid(0.5*(Q+Q')) ellipsoid(0.5*(BPB+BPB'))], ellipsoid(0.5*(GQG+GQG')), l);
      end
      if ~isempty(E)
        Q = parameters(E);
      else
        Q = zeros(N, N);
      end
      QQ = [QQ reshape(Q, N*N, 1)];
      LL = [LL l];
    end
  else
    for i = 1:(ntv - 1)
      A   = ell_value_extract(mydata.A, i, [N N]);
      Ai  = ell_inv(A);
      BPB = ell_value_extract(mydata.BPB, i, [N N]);
      GQG = ell_value_extract(mydata.GQG, i, [N N]);
      BPB = 0.5 * (BPB + BPB');
      GQG = 0.5 * (GQG + GQG');
      Q   = A * Q * A';
      if size(mydata.delta, 2) > 1
        dd = mydata.delta(i);
      elseif isempty(mydata.delta)
        dd = 0;
      else
        dd = mydata.delta(1);
      end
      if dd > 0
        %e1  = max(svd(A)) * max(svd(Q)) * 4 * eps;
        e1  = ellOptions.abs_tol;
        e2  = sqrt(e1*e1 + 2*max(eig(BPB))*e1);
        BPB = ell_regularize(BPB, e2);
      elseif rank(BPB) < N
        BPB = ell_regularize(BPB);
      end
      if rank(GQG) < N
        GQG = ell_regularize(GQG);
      end
      l = Ai' * l;
      if mnmx > 0 % minmax case
        E = minkmp_ia(ellipsoid(0.5*(Q+Q')), ellipsoid(0.5*(GQG+GQG')), ellipsoid(0.5*(BPB+BPB')), l);
      else
        E = minkpm_ia([ellipsoid(0.5*(Q+Q')) ellipsoid(0.5*(BPB+BPB'))], ellipsoid(0.5*(GQG+GQG')), l);
      end
      if ~isempty(E)
        Q = parameters(E);
      else
        Q = zeros(N, N);
      end
      QQ  = [QQ reshape(Q, N*N, 1)];
      LL = [LL l];
    end
  end

  ellOptions.verbose = vrb;

  return;
