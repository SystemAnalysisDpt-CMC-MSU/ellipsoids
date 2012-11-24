function [resD, resGVec] = distpobjfun(xVec, myEll, yVec, varargin)
%
% DISTPOBJFUN - objective function for calculation of distance between
%               an ellipsoid and a point.
%
% Input:
%   regular:
%       myEll: E1ellipsoid [1, 1] - single ellipsoid of dimention nDims.
%       yVec: double[nDims, 1] - single point.
%       xVec: double[nDims, 1] - Direction vector.
%
% Output:
%   resD: double[1, 1] -
%   resGVec: double[nDims, 1] -
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

myEllCentVec = myEll.center;
myEllShMat = myEll.shape;

resD = xVec'*myEllCentVec + sqrt(xVec'*myEllShMat*xVec) - xVec'*yVec;
resGVec = myEllCentVec - yVec + ...
    ((myEllShMat*xVec)/sqrt(xVec'*myEllShMat*xVec));
