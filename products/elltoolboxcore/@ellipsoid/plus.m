function outEllArr = plus(varargin)
%
% PLUS - overloaded operator '+'
%
%   outEllArr = PLUS(inpEllArr, inpVec) implements E(q, Q) + b
%       for each ellipsoid E(q, Q) in inpEllArr.
%   outEllArr = PLUS(inpVec, inpEllArr) implements b + E(q, Q)
%       for each ellipsoid E(q, Q) in inpEllArr.
%
%	Operation E + b (or b+E) where E = inpEll is an ellipsoid in R^n,
%   and b=inpVec - vector in R^n. If E(q, Q) is an ellipsoid
%   with center q and shape matrix Q, then
%   E(q, Q) + b = b + E(q,Q) = E(q + b, Q).
%
% Input:
%   regular:
%       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
%           of the same dimentions nDims.
%       bVec: double[nDims, 1] - vector.
%
% Output:
%   outEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids 
%       with same shapes as ellVec, but with centers shifted by vectors 
%       in inpVec.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

import modgen.common.throwerror;
import modgen.common.checkvar;
import modgen.common.checkmultvar;
errMsg =...
    'this operation is only permitted between ellipsoid and vector in R^n.';
checkvar(nargin,'x==2','errorTag','wrongInput',...
    'errorMessage',errMsg)
if isa(varargin{1}, 'ellipsoid')&&isa(varargin{2}, 'double')
    inpEllVec = varargin{1};
    inpVec = varargin{2};
elseif isa(varargin{2}, 'ellipsoid')&&isa(varargin{1}, 'double')
    inpEllVec = varargin{2};
    inpVec = varargin{1};
else
    throwerror('wrongInput',errMsg);
end

dimsVec = dimension(inpEllVec);
checkmultvar('iscolumn(x1)&&all(x2(:)==length(x1))',2,inpVec,dimsVec,...
    'errorMessage','dimensions mismatch');

sizeCVec = num2cell(size(inpEllVec));
outEllArr(sizeCVec{:})=ellipsoid;
arrayfun(@(x) fSinglePlus(x),1:numel(inpEllVec));
    function fSinglePlus(index)
        outEllArr(index).center =inpEllVec(index).center + inpVec;
        outEllArr(index).shape = inpEllVec(index).shape;
    end
end
