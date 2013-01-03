function volArr = volume(ellArr)
%
% VOLUME - returns the volume of the ellipsoid.
%
%	volArr = VOLUME(ellArr)  Computes the volume of ellipsoids in
%       ellipsoidal array ellArr.
%
%	The volume of ellipsoid E(q, Q) with center q and shape matrix Q 
%	is given by V = S sqrt(det(Q)) where S is the volume of unit ball.
%
% Input:
%   regular:
%       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
%           of ellipsoids.
%
% Output:
%	volArr: double [nDims1,nDims2,...,nDimsN] - array of
%   	volume values, same size as ellArr.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%s

ellipsoid.checkIsMe(ellArr); 

modgen.common.checkvar(ellArr,'~any(isempty(x(:)))',...
    'errorTag','wrongInput:emptyEllipsoid',...
    'errorMessage','input argument is empty.');
volArr = arrayfun(@(x) fSingleVolume(x), ellArr);

end

function vol = fSingleVolume(singEll)
if isdegenerate(singEll)
    vol = 0;
else
    qMat = singEll.shape;
    nDim = size(qMat, 1);
    
    if mod(nDim,2)
        k = (nDim-1)*0.5;
        s = ((2^(2*k + 1))*(pi^k)*factorial(k))/factorial(2*k + 1);
    else
        k = nDim *0.5;
        s = (pi^k)/factorial(k);
    end
    vol = s*sqrt(det(qMat));
end
end
