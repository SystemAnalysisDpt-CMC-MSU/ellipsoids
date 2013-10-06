function [bpGridMat, fGridMat, supVec, lGridMat] = getRhoBoundaryByFactor(ellObj,factorVec)
%
%GETRHOBOUNDARYBYFACTOR - computes grid of 2d or 3d ellipsoid and vertices
%                     for each face in the grid and support function values.
%
% Input:
%   regular:
%       ellObj: ellipsoid[1,1] - ellipsoid object
%   optional:
%       factorVec: double[1,2]\double[1,1] - number of points is calculated
%           by:
%           factorVec(1)*nPlot2dPoints - in 2d case
%           factorVec(2)*nPlot3dPoints - in 3d case.
%           If factorVec is scalar then for calculating the number of
%           in the grid it is multiplied by nPlot2dPoints
%           or nPlot3dPoints depending on the dimension of the ellObj
%
% Output:
%    bpGridMat: double[nVertices, nDims] - vertices of the grid.
%    fGridMat: double[nFaces, nDims] - indices of vertices in each face 
%        in the grid (2d/3d cases).
%    supVec: double[nVertices, 1] - vector of values of the support function.
%    lGridMat: double[nVertices, nDims] - array of directions.
%
% $Author: <Sergei Drozhzhin>  <SeregaDrozh@gmail.com> $    $Date: <28 September 2013> $
% $Copyright: Lomonosov Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
%
import modgen.common.throwerror
ellObj.checkIfScalar();
nDim=dimension(ellObj);

if nargin < 2
    factor = 1;
else
    factor = factorVec(nDim - 1);
end
if nDim == 2
    nPlotPoints = ellObj.nPlot2dPoints;
    if ~(factor == 1)
        nPlotPoints = floor(nPlotPoints*factor);
    end
elseif nDim == 3
    nPlotPoints = ellObj.nPlot3dPoints;
    if ~(factor == 1)
        nPlotPoints = floor(nPlotPoints*factor);
    end
else
    throwerror('wrongDim','ellipsoid must be of dimension 2 or 3');
end
[bpGridMat, fGridMat, supVec, lGridMat] =...
    getRhoBoundary(ellObj, nPlotPoints);
end


