function rMat = spherepart(nPoints)
% SPHEREPART builds a partition of unit sphere into a specified number of
% points
%
% Input:
%   regular:
%       nPoints: double[1,1] - number of points to partition the sphere
%
% Output:
%   rMat: double[nPoints,3] - coordinates on the unit sphere
%
% $Author: Ivan Menshikov <ivan.v.menshikov@gmail.com>$ $Date: 2013-05-11$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Computer Science,
%             System Analysis Department 2011 $
%
import modgen.common.type.simple.checkgen
%
checkgen(nPoints, 'isscalar(x) && fix(x) == x && x > 0');
%
% spheretri(d) returns n = 2*(1+5*(2^(2*d))) points,
% but one half of them is just a reflection of the other,
% so in order to get m unique directions we need at least 2*m points
%
if nPoints < 21
    depth = 1;
else
    depth = ceil(log2((nPoints-1)/5)/2);
end
%
pMat = gras.geom.tri.spheretri(depth);
pMat = uniquedirections(pMat, 1e-8);
%
xDistVec = spheredistance(pMat, [1 0 0]);
yDistVec = spheredistance(pMat, [0 1 0]);
zDistVec = spheredistance(pMat, [0 0 1]);
%
rMat = zeros(nPoints, 3);
for iPoint = 1:nPoints
    switch mod(iPoint, 3)
        case 1
            [~,iMin] = min(xDistVec);
            xDistVec(iMin) = 2*pi;
        case 2
            [~,iMin] = min(yDistVec);
            yDistVec(iMin) = 2*pi;
        case 0
            [~,iMin] = min(zDistVec);
            zDistVec(iMin) = 2*pi;
    end
    rMat(iPoint,:) = pMat(iMin,:);
end
%
% given a matrix aMat with rows representing unique points in space,
% the function keeps only rows that define unique directions
% (since directions rVec and -rVec are considered equal, the function
% keeps the one that lies above (or on) x+y+z=0 plane).
%
    function cMat = uniquedirections(aMat, tol)
        nRows = size(aMat,1);
        indRemoveVec = false(nRows,1);
        %
        for iRow = 1:nRows-1
            diffMat = bsxfun(@plus, aMat(iRow+1:end,:), aMat(iRow,:));
            diffNormVec = realsqrt(sum(diffMat.*diffMat,2));
            jRow = iRow + find(diffNormVec < tol, 1, 'first');
            if ~isempty(jRow)
                if sum(aMat(iRow,:)) < 0
                    indRemoveVec(jRow) = true;
                else
                    indRemoveVec(iRow) = true;
                end
            end
        end
        %
        cMat = aMat(indRemoveVec,:);
    end
%
% given a matrix aMat with unit rows, and a unit vector bVec,
% the function computes spherical distance between rows of matrix aMat
% and vector bVec
%
    function distVec = spheredistance(aMat, bVec)
        dotProdVec = sum(bsxfun(@times,aMat,bVec), 2);
        distVec = acos(dotProdVec);
    end
end