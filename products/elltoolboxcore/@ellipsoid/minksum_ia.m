function intApprEllVec = minksum_ia(inpEllMat, dirMat)
%
% MINKSUM_IA - computation of internal approximating ellipsoids
%              of the geometric sum of ellipsoids along given directions.
%
%   intApprEllVec = MINKSUM_IA(inpEllMat, dirMat) - Computes
%       tight internal approximating ellipsoids for the geometric
%       sum of the ellipsoids in the array inpEllMat along directions
%       specified by columns of dirMat. If ellipsoids in
%       inpEllMat are n-dimensional, matrix dirMat must have
%       dimension (n x k) where k can be arbitrarily chosen.
%       In this case, the output of the function will contain k
%       ellipsoids computed for k directions specified in dirMat.
%
%   Let inpEllMat consists from: E(q1, Q1), E(q2, Q2), ..., E(qm, Qm) - 
%   ellipsoids in R^n, and dirMat(:, iCol) = l - some vector in R^n.
%   Then tight internal approximating ellipsoid E(q, Q) for the
%   geometric sum E(q1, Q1) + E(q2, Q2) + ... + E(qm, Qm) along
%   direction l, is such that
%       rho(l | E(q, Q)) = rho(l | (E(q1, Q1) + ... + E(qm, Qm)))
%   and is defined as follows:
%       q = q1 + q2 + ... + qm,
%       Q = (S1 Q1^(1/2) + ... + Sm Qm^(1/2))' *
%           * (S1 Q1^(1/2) + ... + Sm Qm^(1/2)),
%   where S1 = I (identity), and S2, ..., Sm are orthogonal
%   matrices such that vectors
%   (S1 Q1^(1/2) l), ..., (Sm Qm^(1/2) l) are parallel.
%
% Input:
%   regular:
%       inpEllMat: ellipsoid [mRows, nColsInpEllMatrix] - matrix
%           of ellipsoids of the same dimentions.
%       dirMat: double[nDim, nCols] - matrix whose columns specify the
%           directions for which the approximations should be computed.
%
% Output:
%   intApprEllVec: ellipsoid [1, nCols] - array of internal
%       approximating ellipsoids.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import modgen.common.throwerror;


if ~(isa(inpEllMat, 'ellipsoid'))
    throwerror('wrongInput', ...
        'MINKSUM_IA: first argument must be array of ellipsoids.');
end

nDimsInpEllMat = dimension(inpEllMat);
minDim = min(min(nDimsInpEllMat));
maxDim = max(max(nDimsInpEllMat));
if minDim ~= maxDim
    fstStr = 'MINKSUM_IA: ellipsoids in the array must be ';
    secStr = 'of the same dimension.';
    throwerror('wrongSizes', [fstStr secStr]);
end

[nDims, nCols] = size(dirMat);
if (nDims ~= maxDim)
    fstStr = 'MINKSUM_IA: second argument must ';
    secStr = 'be vector(s) in R^%d.';
    msg = sprintf([fstStr secStr], maxDim);
    throwerror(msg);
end

[mRows, nColsInpEllMatrix] = size(inpEllMat);
if (mRows == 1) && (nColsInpEllMatrix == 1)
    intApprEllVec = inpEllMat;
    return;
end

intApprEllVec = [];
absTolMat = getAbsTol(inpEllMat);
for iCol = 1:nCols
    dirVec = dirMat(:, iCol);
    for iRow = 1:mRows
        for jColsInpEllMatrix = 1:nColsInpEllMatrix
            shMat = inpEllMat(iRow, jColsInpEllMatrix).shape;
            if size(shMat, 1) > rank(shMat)
                if Properties.getIsVerbose()
                    fprintf('MINKSUM_IA: Warning!');
                    fprintf(' Degenerate ellipsoid.\n');
                    fprintf('            Regularizing...\n')
                end
                shMat = ellipsoid.regularize(shMat, ...
                    absTolMat(iRow,jColsInpEllMatrix));
            end
            shMat = sqrtm(shMat);
            if (iRow == 1) && (jColsInpEllMatrix == 1)
                centVec = inpEllMat(iRow, jColsInpEllMatrix).center;
                subVec = shMat * dirVec;
                subShMat = shMat;
            else
                centVec = centVec + inpEllMat(iRow, ...
                    jColsInpEllMatrix).center;
                rotMat = ell_valign(subVec, shMat*dirVec);
                subShMat = subShMat + rotMat*shMat;
            end
        end
    end
    intApprEllVec = [intApprEllVec ...
        ellipsoid(centVec, subShMat'*subShMat)];
end
