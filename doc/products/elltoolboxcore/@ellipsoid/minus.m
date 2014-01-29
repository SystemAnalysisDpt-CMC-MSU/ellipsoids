function outEllArr = minus(varargin)
%
% MINUS - overloaded operator '-'
%
%   outEllArr = MINUS(inpEllArr, inpVec) implements E(q, Q) - b
%       for each ellipsoid E(q, Q) in inpEllArr.
%   outEllArr = MINUS(inpVec, inpEllArr) implements b - E(q, Q)
%       for each ellipsoid E(q, Q) in inpEllArr.
%
%   Operation E - b where E = inpEll is an ellipsoid in R^n,
%   and b = inpVec - vector in R^n. If E(q, Q) is an ellipsoid
%   with center q and shape matrix Q, then
%   E(q, Q) - b = E(q - b, Q).
%
% Input:
%   regular:
%       inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of 
%           ellipsoids of the same dimentions nDims.
%       inpVec: double[nDims, 1] - vector.
%
% Output:
%	outEllVec: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids 
%       with same shapes as inpEllVec, but with centers shifted by vectors 
%       in -inpVec.
%
% Example:
%   ellVec  = [ellipsoid([-2; -1], [4 -1; -1 1]) ell_unitball(2)];
%   outEllVec = ellVec - [1; 1];
%   outEllVec(1)
% 
%   ans =
% 
%   Center:
%       -3
%       -2
% 
%   Shape:
%        4    -1
%       -1     1
% 
%   Nondegenerate ellipsoid in R^2.
% 
%   outEllVec(2)
% 
%   ans =
% 
%   Center:
%       -1
%       -1
% 
%   Shape:
%        1     0
%        0     1
% 
%   Nondegenerate ellipsoid in R^2.
%       
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of Californi a 
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

import modgen.common.throwerror;
import modgen.common.checkvar;

errMsg =...
    'this operation is only permitted between ellipsoid and vector in R^n.';
checkvar(nargin,'x==2','errorTag','wrongInput',...
    'errorMessage',errMsg)
if isa(varargin{1}, 'ellipsoid')&&isa(varargin{2}, 'double')
    inpEllArr = varargin{1};
    inpVec = varargin{2};
elseif isa(varargin{2}, 'ellipsoid')&&isa(varargin{1}, 'double')
    inpEllArr = varargin{2};
    inpVec = varargin{1};
else
    throwerror('wrongInput',errMsg);
end
outEllArr = plus(inpEllArr, -inpVec);