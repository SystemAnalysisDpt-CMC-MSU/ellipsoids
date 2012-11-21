function [isEqual, reportStr] = eq(Ell1Vec, Ell2Vec)
%
%
% Description:
% ------------
%
%    Implementation of '==' operation.
%
%
% Output:
% -------
%
%    1 - if E1 = E2, 0 - otherwise.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
  import modgen.common.throwerror;
  import gras.la.sqrtm;
  import elltool.conf.Properties;
  reportStr='';
  if  ~(isa(Ell1Vec, 'ellipsoid')) | ~(isa(Ell2Vec, 'ellipsoid'))
    throwerror('wrongInput', '==: both arguments must be ellipsoids.');
  end
  reportStr = 0;
  [k, l] = size(Ell1Vec);
  s      = k * l;
  [m, n] = size(Ell2Vec);
  t      = m * n;

  if ((k ~= m) | (l ~= n)) & (s > 1) & (t > 1)
    throwerror('wrongSizes', '==: sizes of ellipsoidal arrays do not match.');
  end

  isEqual = [];
  if (s > 1) & (t > 1)
    for i = 1:m
      r = [];
      for j = 1:n
        if dimension(Ell1Vec(i, j)) ~= dimension(Ell2Vec(i, j))
          r = [r 0];
          continue;
        end
        reportStr = strcat(reportStr, sprintf('\nEllipsoid 1: (%d, %d), Ellipsoid 2: (%d, %d) \n', i, j, i, j));

        q = Ell1Vec(i, j).center - Ell2Vec(i, j).center;
        Q = sqrtm(Ell1Vec(i, j).shape) - sqrtm(Ell2Vec(i, j).shape);
        if (norm(q) > Ell1Vec(i,j).relTol) | (norm(Q) > Ell2Vec(i,j).relTol)
          r = [r 0];
          if norm(q) > Ell1Vec.relTol
                repCurStr = sprintf('\nthe difference of centers is greater than the specified tolerance: %f\n', norm(q))
                reportStr = strcat(reportStr, repCurStr);
          end;
          if (norm(Q) > Ell1Vec.relTol)
                repCurStr = sprintf('\nthe difference of matrices is greater than the specified tolerance: %f\n', norm(Q))
                reportStr = strcat(reportStr, repCurStr);
          end;

        else
          r = [r 1];
          reportStr = strcat(reportStr, sprintf('\nellipsoids are equal\n'));
        end
      end
      isEqual = [isEqual; r];
    end
  elseif (s > 1)
    for i = 1:k
      r = [];
      for j = 1:l
        if dimension(Ell1Vec(i, j)) ~= dimension(Ell2Vec)
          r = [r 0];
          continue;
        end
        reportStr = strcat(reportStr, sprintf('\nEllipsoid 1: (%d, %d), Ellipsoid 2: (1, 1) \n', i, j));
        q = Ell1Vec(i, j).center - Ell2Vec.center;
        Q = sqrtm(Ell1Vec(i, j).shape) - sqrtm(Ell2Vec.shape);
        if (norm(q) > Ell1Vec(i,j).relTol) | (norm(Q) > Ell2Vec(i,j).relTol)
          r = [r 0];
          if norm(q) > Ell1Vec.relTol
                repCurStr = sprintf('\nthe difference of centers is greater than the specified tolerance: %f\n', norm(q))
                reportStr = strcat(reportStr, repCurStr);
          end;
          if (norm(Q) > Ell1Vec.relTol)
                repCurStr = sprintf('\nthe difference of matrices is greater than the specified tolerance: %f\n', norm(Q))
                reportStr = strcat(reportStr, repCurStr);
          end;

        else
          r = [r 1];
          reportStr = strcat(reportStr, sprintf('\nellipsoids are equal\n'));
        end
      end
      isEqual = [isEqual; r];
    end
  else
    for i = 1:m
      r = [];
      for j = 1:n
        if dimension(Ell1Vec) ~= dimension(Ell2Vec(i, j))
          r = [r 0];
          continue;
        end
        reportStr = strcat(reportStr, sprintf('\nEllipsoid 1: (1, 1), Ellipsoid 2: (%d, %d) \n', i, j));
        q = Ell1Vec.center - Ell2Vec(i, j).center;
        Q = sqrtm(Ell1Vec.shape) - sqrtm(Ell2Vec(i, j).shape);
        %Q = E1.shape - E2(i,j).shape;
        %if (max(q(:)./(1 + max(abs(E1.center(:)), abs(E2(i, j).center(:))))) > E1.relTol) | (max(Q(:)./(1 + max(abs(E1.shape(:)), abs(E2(i, j).shape(:))))) > E1.relTol)
        if (norm(q) > Ell1Vec.relTol) | (norm(Q) > Ell1Vec.relTol)
            r = [r 0];
            if norm(q) > Ell1Vec.relTol
                repCurStr = sprintf('\nthe difference of centers is greater than the specified tolerance: %f\n', norm(q))
                reportStr = strcat(reportStr, repCurStr);
            end;
            if (norm(Q) > Ell1Vec.relTol)
                repCurStr = sprintf('\nthe difference of matrices is greater than the specified tolerance: %f\n', norm(Q))
                reportStr = strcat(reportStr, repCurStr);
            end;
        else
          r = [r 1];
          reportStr = strcat(reportStr, sprintf('\nellipsoids are equal\n'));
        end
      end
      isEqual = [isEqual; r];
    end
  end

  return; 
