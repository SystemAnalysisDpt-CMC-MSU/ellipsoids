function [myEllCentVec, myEllshMat] = double(myEll)
%
% DOUBLE - returns parameters of the ellipsoid.
%
% Input:
%   regular:
%       myEll: ellipsoid [1, 1] - single ellipsoid of dimention ellDimension.
%
% Output:
%    myEllCenterVec: double[ellDimension, 1] - center of the ellipsoid myEll.
%    myEllshapeMat: double[ellDimension, ellDimension] - shape matrix of the ellipsoid myEll.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

  import modgen.common.throwerror;

  [mRows, nCols] = size(myEll);
  if (mRows > 1) || (nCols > 1)
    throwerror('wrongInput', 'DOUBLE: the argument of this function must be single ellipsoid.');
  end
  
  if nargout < 2
    myEllCentVec = myEll.shape;
  else
    myEllCentVec = myEll.center;
    myEllshMat = myEll.shape;
  end

end
