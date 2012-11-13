function LC = rm_bad_directions(Q1, Q2, L)
%
% RM_BAD_DIRECTIONS - remove bad directions from the given list.
%                     Bad directions are those which should not be used
%                     for the support function of geometric difference
%                     of two ellipsoids.
%

  LC = [];
  T  = ell_simdiag(Q2, Q1);
  a  = min(abs(diag(T*Q1*T')));
  if a < 1
    return;
  end

  n = size(L, 2);
  for i = 1:n
    l = L(:, i);
    if (sqrt(l'*Q1*l)/sqrt(l'*Q2*l)) <= a
      LC = [LC l];
    end
  end

end
