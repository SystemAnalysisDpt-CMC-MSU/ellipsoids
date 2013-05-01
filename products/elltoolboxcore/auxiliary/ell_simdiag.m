function T = ell_simdiag(A, B, absTol)
%
% ELL_SIMDIAG - computes the transformation matrix that 
%               simultaneously diagonalizes two symmetric
%               matrices.
%
%
% Description:
% ------------
%
%    T = ELL_SIMDIAG(A, B)  Given two symmetric matrices, A
%                  and B, with A being positive definite, 
%                  find nonsingular transformation matrix T 
%                  such that
%                             T A T' = I
%                             T B T' = D
%                  where I is identity matrix, and D is 
%                  diagonal. 
%
%    General info.
%    Two matrices are said to be simultaneously 
%    diagonalizable if they are diagonalized by a same 
%    invertible matrix. 
%    That is, they share full rank of linearly independent 
%    eigenvectors. Two square matrices of the same
%    dimension are simultaneously diagonalizable if and 
%    only if they are diagonalizable and commutative, or  
%    these matrices are symmetric and one of them is 
%    positive definite.
%
%
% Output:
% -------
%
%    T - tranformation matrix.
%
%
% See also:
% ---------
%
%    SVD, GSVD.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%    Rustam Guliev
  import gras.la.ismatsymm;
  import gras.la.ismatposdef;
  import gras.la.sqrtmpos;
  %  
  if ~(isa(A, 'double')) || ~(isa(B, 'double'))
    error('ELL_SIMDIAG: both arguments must be symmetric matrices of the same dimension.');
  end
  if (~ismatsymm(A) || ~ismatposdef(A,absTol))
    error('ELL_SIMDIAG: first argument must be symmetric positive definite matrix.');
  end
  if (~ismatsymm(B))
    error('ELL_SIMDIAG: second argument must be symmetric matrix.');
  end

  m = size(A, 1);
  n = size(B, 1);
  if m ~= n
    error('ELL_SIMDIAG: both matrices must be of the same dimension.');
  end

  [U1, S, ~] = svd(A);
  U        = U1 / (sqrtmpos(S, absTol));
  [U2 , ~, ~] = svd(U'*B*U);
  T        = U2' * U';

end
