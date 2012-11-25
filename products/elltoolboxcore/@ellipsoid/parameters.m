function [q, Q] = parameters(E)
%
% PARAMETERS - returns parameters of the ellipsoid.
%
%
% Description:
% ------------
%
%    [q, Q] = PARAMETERS(E)  Extracts the values of the center q and
%                            the shape matrix Q from the ellipsoid object E.
%
%
% Output:
% -------
%
%    q - center of the ellipsoid E.
%    Q - shape matrix of the ellipsoid E.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, DIMENSION, ISDEGENERATE.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
    if nargout < 2
        q = double(E);
    else
        [q, Q] = double(E);
    end    
    