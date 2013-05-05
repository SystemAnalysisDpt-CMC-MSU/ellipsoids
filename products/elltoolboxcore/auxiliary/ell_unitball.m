function [B] = ell_unitball(n)
%
% ELL_UNITBALL - creates unit ball object
%
%
% Description:
% ------------
%
%    B = ELL_UNITBALL(N)  Creates an ellipsoid in R^N with 
%           identity shape matrix, centered at the origin.
%
%
% Output:
% -------
%
%    B = { x : <x, x> <= 1 } - unit ball.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  B = ellipsoid(eye(n));

end
