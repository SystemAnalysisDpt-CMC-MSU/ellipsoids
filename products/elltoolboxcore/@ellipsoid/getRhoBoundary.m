function [bpMat, fMat, supVec,lGridMat] = getRhoBoundary(ellObj,nPoints)
%
% GETRHOBOUNDARY - computes the boundary of an ellipsoid and
% support function values.
%
% Input:
%   regular:
%       ellObj: ellipsoid [1, 1]- ellipsoid of the dimention 2 or 3.
%   optional:
%       nPoints: number of boundary points
%
% Output:
%    bpMat: double[nDim,nPoints+1]/
%        double[nDim, ([nPoints/(vNum+eNum+1)]+1)*(vNum+eNum) + 1]
%        - boundary points of ellipsoid.
%        In the first step: vNum = 12, eNum = 30, fNum = 20.
%        In the next step: fNum = 4*fNum, eNum = 2*eNum + 3*fNum, vNum = vNum
%        + eNum. This process ends when vNum>=nPoints.
%
%    fMat: double[nFaces, nDim]/double[4 * fNum, nDim] - indices of points in
%        each face of bpMat graph.
%
%    supVec: double[nPoints+1, 1]/
%        double[([nPoints/(vNum+eNum+1)]+1)*(vNum+eNum) + 1, 1]
%        - vector of values of the support function in directions (bpMat - cenMat).
%
%    lGridMat: double[nPoints+1, nDim]/
%        double[([nPoints/(vNum+eNum+1)]+1)*(vNum+eNum) + 1, nDim]
%        - array of directions.
%
% $Author: <Sergei Drozhzhin>  <SeregaDrozh@gmail.com> $    $Date: <28 September 2013> $
% $Copyright: Lomonosov Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             System Analysis Department 2013$
%
import modgen.common.throwerror
ellObj.checkIfScalar();
nDim = dimension(ellObj);
if nDim == 2
    if nargin < 2
        nPoints = ellObj.nPlot2dPoints;
    end
    fGetGrid = @(x)gras.geom.tri.spheretriext(nDim,x);
elseif nDim == 3
    if nargin < 2
        nPoints = ellObj.nPlot3dPoints;
    end
    fGetGrid = @(x)gras.geom.tri.spheretriext(nDim,x);
else
    throwerror('wrongDim','ellipsoid must be of dimension 2 or 3');
end
[dirMat, fMat] = fGetGrid(nPoints);

[cenVec qMat] = double(ellObj);
bpMat = dirMat*gras.la.sqrtmpos(qMat, ellObj.getAbsTol());
cenMat = repmat(cenVec.',size(dirMat, 1), 1);
bpMat = bpMat + cenMat;
bpMat = [bpMat; bpMat(1,:)];
cenMat = [cenMat; cenMat(1,:)];
lGridMat = bpMat - cenMat;
supVec = (rho(ellObj, lGridMat.')).';
bpMat = bpMat.';

end
