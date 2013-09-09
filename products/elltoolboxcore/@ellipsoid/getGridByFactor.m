function [vGridMat, fGridMat] = getGridByFactor(ellObj,factorVec)
%
%   GETGRIDBYFACTOR - computes grid of 2d or 3d sphere and vertices 
%       for each face in the grid 
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
%   regular:
%       vGridat: double[nPoints,nDim] - vertices of the grid
%       fGridMat: double[1,nPoints+1]/double[nFaces,3] - indices of vertices in
%           each face in the grid (2d/3d cases)
%
% $Author:  Vitaly Baranov  <vetbar42@gmail.com> $    $Date: <04-2013> $
% $Author: Ilya Lyubich  <lubi4ig@gmail.com> $    $Date: <03-2013> $
% $Copyright: Lomonosov Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
%
import modgen.common.throwerror
nDim=dimension(ellObj);

if nDim<2 || nDim>3
    throwerror('wrongDim','ellipsoid must be of dimension 2 or 3');
end

if nargin<2
    factor=1;
else
    factor=factorVec(nDim-1);
end
if nDim==2
    nPlotPoints=ellObj.nPlot2dPoints;
    if ~(factor==1)
        nPlotPoints=floor(nPlotPoints*factor);
    end
else
    nPlotPoints=ellObj.nPlot3dPoints;
    if ~(factor==1)
        nPlotPoints=floor(nPlotPoints*factor);
    end
end
[vGridMat, fGridMat] =  gras.geom.tri. spheretriext(nDim,nPlotPoints);
vGridMat(vGridMat == 0) = eps;