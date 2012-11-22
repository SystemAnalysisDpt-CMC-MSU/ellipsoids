function [resD, resGVec] = contobjfun(xVec, firstEll, secondEll, varargin)
%
% CONTOBJFUN - objective function for containment checking of two ellipsoids 
%               (secondEll in firstEll).
%
% Input:
%   regular:
%       firstEll, secondEll: ellipsoid [1, 1] - ellipsoids of the same dimentions ellDimension.
%       xVec: double[ellDimension, 1] - Direction vector.
%
% Output:
%    resD: double[1, 1] - Subtraction between 
%       of ellipsoides support functions.
%    resGVec: double[ellDimension, 1] - Subtraction between 
%       of ellipsoides support vectors.
%
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

  fstEllCentVec = firstEll.center;
  fstEllShMat = firstEll.shape;
  secEllCentVec = secondEll.center;
  secEllShMat = secondEll.shape;

  resD = xVec'*fstEllCentVec + sqrt(xVec'*fstEllShMat*xVec) - ...
      xVec'*secEllCentVec - sqrt(xVec'*secEllShMat*xVec);
  resGVec = fstEllCentVec + ((fstEllShMat*xVec)/sqrt(xVec'*fstEllShMat*xVec))...
      - secEllCentVec - ((secEllShMat*xVec)/sqrt(xVec'*secEllShMat*xVec));

end
