function f = ell_fusionlambda(a, q1, Q1, q2, Q2, n)
%
% ELL_FUSIONLAMBDA - function whose root in the interval
%                    (0, 1) determines the minimal volume 
%                    ellipsoid overapproximating the
%                    intersection of two ellipsoids.
%
% This function is called from ELLIPSOID/INTERSECTION_EA
%      by FZERO.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  X = a*Q1 + (1 - a)*Q2;
  Y = inv(X);
  Y = 0.5*(Y + Y');
  k = 1 - a*(1 - a)*(q2 - q1)'*Q2*Y*Q1*(q2 - q1);
  q = Y*(a*Q1*q1 + (1 - a)*Q2*q2);
  
  f = k*det(X)*trace(det(X)*Y*(Q1 - Q2)) - n*((det(X))^2)* ...
      (2*q'*Q1*q1 - 2*q'*Q2*q2 + q'*(Q2 - Q1)*q - q1'*Q1*q1 + q2'*Q2*q2);

end
