function [resD, resGVec] = distobjfun(xVec, firstEll, secondEll, varargin)
%
% DISTOBJFUN - objective function for calculation of
%              distance between two ellipsoids.
%
% Input:
%   regular:
%       firstEll, secondEll: ellipsoid [1, 1] - ellipsoids
%           of the same dimentions nDims.
%       xVec: double[nDims, 1] - Direction vector.
%
% Output:
%   resD: double[1, 1] -
%   resGVec: double[nDims, 1] -
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

fstEllCentVec = firstEll.center;
fstEllShMat = firstEll.shape;
secEllCentVec = secondEll.center;
secEllShMat = secondEll.shape;

resD = xVec'*secEllCentVec + sqrt(xVec'*fstEllShMat*xVec) + ...
    sqrt(xVec'*secEllShMat*xVec) - xVec'*fstEllCentVec;
resGVec = secEllCentVec - fstEllCentVec + ...
    ((fstEllShMat*xVec)/sqrt(xVec'*fstEllShMat*xVec)) +...
    ((secEllShMat*xVec)/sqrt(xVec'*secEllShMat*xVec));
