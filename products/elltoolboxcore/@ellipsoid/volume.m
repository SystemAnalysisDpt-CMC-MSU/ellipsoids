function volArr = volume(inpEllArr)
%
% VOLUME - returns the volume of the ellipsoid.
%
%
% Description:
% ------------
%
%    V = VOLUME(E)  Computes the volume of ellipsoids in ellipsoidal array E.
%
%    The volume of ellipsoid E(q, Q) with center q and shape matrix Q is given by
%                  V = S sqrt(det(Q))
%    where S is the volume of unit ball.
%
%
% Output:
% -------
%
%    V - array of volume values, same size as E.
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
%    Guliev Rustam <glvrst@gmail.ru>
%

import modgen.common.type.simple.checkgen;
checkgen(inpEllArr,@(x)isa(x,'ellipsoid'),'Input argument');
  
volArr = arrayfun(@(x) fsingleVolume(x),inpEllArr);

end
  
function vol = fsingleVolume(singleEll)
    import modgen.common.throwerror;
    if isempty(singleEll)
    	throwerror('wrongInput:emptyEllipsoid','VOLUME: input argument is empty.');
    end
    qMat = singleEll.shape;
    if isdegenerate(singleEll)
    	s = 0;
    else
        nDim=size(qMat,1);
        if mod(nDim,2)
            k = (nDim-1)/2;
            s = ((2^(2*k + 1))*(pi^k)*factorial(k))/factorial(2*k + 1);
        else
            k = nDim/2;
            s = (pi^k)/factorial(k);
        end
    end
    vol= s*sqrt(det(qMat));
end