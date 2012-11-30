function [ellConstr, gVec] = ellconstraint(xVec, shMat)
%
% ELLCONSTRAINT - describes ellipsoidal constraint.
%                 This function describes ellipsoidal constraint
%                 <l, Q l> = 1,
%                 where Q is positive semidefinite.
%
% Input:
%   regular:
%       xVec: double[ellDimension, 1] - direction vector.
%
%   optional:
%       shMat: double[ellDimension, ellDimension] - shape matrix of 
%           ellipsoid. Default values - identity matrix.
%
% Output:
%   ellConstr: double[1, 1] - ellipsoidal constraint
%   gVec: double[ellDimension, 1] -
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

    ellConstr = (xVec' * shMat * xVec) - 1;
    gVec = 2 * shMat * xVec;
