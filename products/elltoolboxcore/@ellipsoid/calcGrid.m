function [vGridMat, fGridMat] = calcGrid(ellObj,factorVec)
%
% CALCGRID - computes grid of 2d or 3d sphere and vertices for each face 
%            in the grid with number of points taken from ellObj 
%            nPlot2dPoints or nPlot3dPoints parameters
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
%       fGridMat: double[nFacePoints,nFacePoints] - indices of vertices in 
%           each face in the grid
%
% $Author: Ilya Lyubich  <lubi4ig@gmail.com> $    $Date: <03-2013> $
% $Author:  Vitaly Baranov  <vetbar42@gmail.com> $    $Date: <04-2013> $
% $Copyright: Lomonosov Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2013 $
%
nDim=dimension(ellObj);
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
    [vGridMat, fGridMat] = ellObj.ellbndr_2dmat(nPlotPoints);
else
    nPlotPoints=ellObj.nPlot3dPoints;
    if ~(factor==1)
        nPlotPoints=floor(nPlotPoints*factor);
    end
    [vGridMat, fGridMat]=ellObj.ellbndr_3dmat(nPlotPoints);
end
vGridMat(vGridMat == 0) = eps;