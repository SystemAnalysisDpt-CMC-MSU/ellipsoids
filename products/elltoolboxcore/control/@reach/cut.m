function C = cut(rs, T)
%
% CUT - extracts the piece of reach tube from given start time to given end time.
%
%
% Description:
% ------------
%
%    C = CUT(RS, T)  Given reach set RS, find states that are reachable within
%                    time interval specified by T.
%                    If T is a scalar, then reach set at given time is returned.
%
%
% Output:
% -------
%
%    C - reach set resulting from the CUT operation.
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

  if ~(isa(rs, 'reach'))
    error('CUT: first input argument must be reach set object.');
  end

  C = rs;
  
  if isempty(rs)
    return;
  end

  if rs.time_values(1) > rs.time_values(end)
    back = 1;
    Tmn  = rs.time_values(end);
    Tmx  = rs.time_values(1);
  else
    back = 0;
    Tmn  = rs.time_values(1);
    Tmx  = rs.time_values(end);
  end

  [m, n] = size(T);
  if ~(isa(T, 'double')) | (m ~= 1) | ((n ~= 1) & (n ~= 2))
    if isdiscrete(rs.system)
      if back > 0
        error('CUT: second input argument must specify time interval in the form ''[k1 k0]'', or ''k''.');
      else
        error('CUT: second input argument must specify time interval in the form ''[k0 k1]'', or ''k''.');
      end
    else
      if back > 0
        error('CUT: second input argument must specify time interval in the form ''[t1 t0]'', or ''t''.');
      else
        error('CUT: second input argument must specify time interval in the form ''[t0 t1]'', or ''t''.');
      end
    end
  end

  tmn = min(T);
  tmx = max(T);
  if isdiscrete(rs.system)
    tmn = round(tmn);
    tmx = round(tmx);
  end

  smx = min([tmx Tmx]);
  smn = max([tmn Tmn]);
  if smn > smx
    error('CUT: specified time interval is out of range.');
  end

  TT = rs.time_values;
  NV = size(TT, 2);
  if isdiscrete(rs.system)   % discrete-time
    indarr = find((TT == smn) | ((TT > smn) & (TT < smx)) | (TT == smx));
  else  % continuous-time
    indarr = find((TT > smn) & (TT < smx));
  end
  N1 = size(rs.ea_values, 2);
  N2 = size(rs.ia_values, 2);
  d  = dimension(rs);
  
  if isdiscrete(rs.system)   % discrete-time
    if size(indarr, 2) == 1
      k               = find(TT == smn);
      C.time_values   = rs.time_values(k);
      C.center_values = rs.center_values(:, k);

      QQ = [];
      for i = 1:N1
        Q  = rs.ea_values{i};
        QQ = [QQ {Q(:, k)}];
      end
      C.ea_values = QQ;

      QQ = [];
      for i = 1:N2
        Q  = rs.ia_values{i};
        QQ = [QQ {Q(:, k)}];
      end
      C.ia_values = QQ;

      if ~(isempty(rs.calc_data))
        md = rs.calc_data;
        if ~(isempty(md.A)) & (size(md.A, 2) == NV)
          md.A = md.A(:, k);
        end
        if ~(isempty(md.Bp)) & (size(md.Bp, 2) == NV)
          md.Bp = md.Bp(:, k);
        end
        if ~(isempty(md.BPB)) & (size(md.BPB, 2) == NV)
          md.BPB = md.BPB(:, k);
        end
        if ~(isempty(md.BPBsr)) & (size(md.BPBsr, 2) == NV)
          md.BPBsr = md.BPBsr(:, k);
        end
        if ~(isempty(md.Gq)) & (size(md.Gq, 2) == NV)
          md.Gq = md.Gq(:, k);
        end
        if ~(isempty(md.GQG)) & (size(md.GQG, 2) == NV)
          md.GQG = md.GQG(:, k);
        end
        if ~(isempty(md.GQGsr)) & (size(md.GQGsr, 2) == NV)
          md.GQGsr = md.GQGsr(:, k);
        end
        if ~(isempty(md.C)) & (size(md.C, 2) == NV)
          md.C = md.C(:, k);
        end
        if ~(isempty(md.w)) & (size(md.w, 2) == NV)
          md.w = md.w(:, k);
        end
        if ~(isempty(md.W)) & (size(md.W, 2) == NV)
          md.W = md.W(:, k);
        end
        if ~(isempty(md.Phi)) & (size(md.Phi, 2) == NV)
          md.Phi = md.Phi(:, k);
        end
        if ~(isempty(md.Phinv)) & (size(md.Phinv, 2) == NV)
          md.Phinv = md.Phinv(:, k);
        end
        if ~(isempty(md.delta)) & (size(md.delta, 2) == NV)
          md.delta = md.delta(:, k);
        end
        C.calc_data = md;
      elseif ~(isempty(rs.l_values))
        N3 = size(rs.l_values, 2);
        LL = [];
        for i = 1:N3
          L  = rs.l_values{i};
          LL = [LL, {L(:, k)}];
        end
        C.l_values = LL;
      end
    else
      is              = indarr(1) - 1;
      ie              = indarr(end) - 1;
      C.time_values   = rs.time_values(is:ie);
      C.center_values = rs.center_values(:, is:ie);

      QQ = [];
      for i = 1:N1
        Q  = rs.ea_values{i};
        QQ = [QQ {Q(:, is:ie)}];
      end
      C.ea_values = QQ;

      QQ = [];
      for i = 1:N2
        Q  = rs.ia_values{i};
        QQ = [QQ {Q(:, is:ie)}];
      end
      C.ia_values = QQ;

      if ~(isempty(rs.calc_data))
        md = rs.calc_data;
        if ~(isempty(md.A)) & (size(md.A, 2) == NV)
          md.A = md.A(:, is:ie);
        end
        if ~(isempty(md.Bp)) & (size(md.Bp, 2) == NV)
          md.Bp = md.Bp(:, is:ie);
        end
        if ~(isempty(md.BPB)) & (size(md.BPB, 2) == NV)
          md.BPB = md.BPB(:, is:ie);
        end
        if ~(isempty(md.BPBsr)) & (size(md.BPBsr, 2) == NV)
          md.BPBsr = md.BPBsr(:, is:ie);
        end
        if ~(isempty(md.Gq)) & (size(md.Gq, 2) == NV)
          md.Gq = md.Gq(:, is:ie);
        end
        if ~(isempty(md.GQG)) & (size(md.GQG, 2) == NV)
          md.GQG = md.GQG(:, is:ie);
        end
        if ~(isempty(md.GQGsr)) & (size(md.GQGsr, 2) == NV)
          md.GQGsr = md.GQGsr(:, is:ie);
        end
        if ~(isempty(md.C)) & (size(md.C, 2) == NV)
          md.C = md.C(:, is:ie);
        end
        if ~(isempty(md.w)) & (size(md.w, 2) == NV)
          md.w = md.w(:, is:ie);
        end
        if ~(isempty(md.W)) & (size(md.W, 2) == NV)
          md.W = md.W(:, is:ie);
        end
        if ~(isempty(md.Phi)) & (size(md.Phi, 2) == NV)
          md.Phi = md.Phi(:, is:ie);
        end
        if ~(isempty(md.Phinv)) & (size(md.Phinv, 2) == NV)
          md.Phinv = md.Phinv(:, is:ie);
        end
        if ~(isempty(md.delta)) & (size(md.delta, 2) == NV)
          md.delta = md.delta(:, is:ie);
        end
        C.calc_data = md;
      elseif ~(isempty(rs.l_values))
        N3 = size(rs.l_values, 2);
        LL = [];
        for i = 1:N3
          L  = rs.l_values{i};
          LL = [LL, {L(:, is:ie)}];
        end
        C.l_values = LL;
      end
    end
  else   % continuous-time
    if isempty(indarr)
      C.time_values   = smn;
      cs              = spline(rs.time_values, rs.center_values);
      C.center_values = ell_value_extract(cs, smn, [d 1]);

      QQ = [];
      for i = 1:N1
        Q  = rs.ea_values{i};
        ss = spline(rs.time_values, Q);
        QQ = [QQ {ell_value_extract(ss, smn, [d*d 1])}];
      end
      C.ea_values = QQ;

      QQ = [];
      for i = 1:N2
        Q  = rs.ia_values{i};
        ss = spline(rs.time_values, Q);
        QQ = [QQ {ell_value_extract(ss, smn, [d*d 1])}];
      end
      C.ia_values = QQ;

      if ~(isempty(rs.l_values))
        N3 = size(rs.l_values, 2);
        LL = [];
        for i = 1:N3
          L  = rs.l_values{i};
          d1 = size(L, 1);
          ss = spline(rs.time_values, L);
          LL = [LL {ell_value_extract(ss, smn, [d1 1])}];
        end
        C.l_values = LL;
      end
    else
      is = indarr(1);
      ie = indarr(end);
      cs = spline(rs.time_values, rs.center_values);
      qn = ell_value_extract(cs, smn, [d 1]);
      qx = ell_value_extract(cs, smx, [d 1]);
      if back > 0
        C.time_values   = [smx rs.time_values(is:ie) smn];
        C.center_values = [qx rs.center_values(:, is:ie) qn];
      else
        C.time_values   = [smn rs.time_values(is:ie) smx];
        C.center_values = [qn rs.center_values(:, is:ie) qx];
      end

      QQ = [];
      for i = 1:N1
        Q  = rs.ea_values{i};
        ss = spline(rs.time_values, Q);
        Qn = ell_value_extract(ss, smn, [d*d 1]);
        Qx = ell_value_extract(ss, smx, [d*d 1]);
        if back > 0
          E = [Qx Q(:, is:ie) Qn];
        else
          E = [Qn Q(:, is:ie) Qx];
	end
        QQ = [QQ {E}];
      end
      C.ea_values = QQ;

      QQ = [];
      for i = 1:N2
        Q  = rs.ia_values{i};
        ss = spline(rs.time_values, Q);
        Qn = ell_value_extract(ss, smn, [d*d 1]);
        Qx = ell_value_extract(ss, smx, [d*d 1]);
        if back > 0
          E = [Qx Q(:, is:ie) Qn];
        else
          E = [Qn Q(:, is:ie) Qx];
	end
        QQ = [QQ {E}];
      end
      C.ia_values = QQ;

      if ~(isempty(rs.l_values))
        N3 = size(rs.l_values, 2);
        LL = [];
        for i = 1:N3
          L  = rs.l_values{i};
          d1 = size(L, 1);
          ss = spline(rs.time_values, L);
          Ln = ell_value_extract(ss, smn, [d1 1]);
          Lx = ell_value_extract(ss, smx, [d1 1]);
          if back > 0
            E = [Lx L(:, is:ie) Ln];
          else
            E = [Ln L(:, is:ie) Lx];
          end
          LL = [LL {E}];
        end
        C.l_values = LL;
      end
    end
  end

  return;
