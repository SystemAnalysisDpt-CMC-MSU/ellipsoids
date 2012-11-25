function [fstOutEmpt, ellConstr, secOutEmpt, GVec] = ellconstraint(xVec, Q1, Q2, varargin)
%
% ELLCONSTRAINT - describes ellipsoidal constraint.
%                 This function describes ellipsoidal constraint
%                 <lVec, QMat lVec> = 1,
%                 where QMat is positive semidefinite.
%
% Input:
%   regular:
%       xVec: double[ellDimension, 1] - direction vector.
%           Q1, Q2: are ignored.
%
%   optional:
%       QMat: double[ellDimension, ellDimension] - shape matrix of 
%           ellipsoid. Default values - identity matrix.
%
% Output:
%   fstOutEmpt, secOutEmpt: [] - always empty.
%   ellConstr: double[1, 1] - ellipsoidal constraint
%   GVec: double[ellDimension, 1] -
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

fstOutEmpt = [];
secOutEmpt = [];

if nargin > 3
    QMat = varargin{1};
    ellConstr = (xVec' * QMat * xVec) - 1;
    GVec = 2 * QMat * xVec;
else
    ellConstr = (xVec' * xVec) - 1;
    GVec = 2 * xVec;
end
