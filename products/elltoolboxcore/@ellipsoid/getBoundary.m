function [bpMat, fMat] = getBoundary(ellObj,nPoints)
%
% GETBOUNDARY - computes the boundary of an ellipsoid. 
%
% Input:
%   regular:
%       myEll: ellipsoid [1, 1]- ellipsoid of the dimention 2 or 3.
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
% $Author: Vitaly Baranov <vetbar42@gmail.com>$ $Date: 13-04-2013$
% $Copyright: Lomonosov Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             System Analysis Department 2013$
%
import modgen.common.throwerror
ellObj.checkIfScalar();
nDim=dimension(ellObj);
if nDim==2
    if nargin<2
        nPoints = ellObj.nPlot2dPoints;
    end
    fGetGrid=@(x)gras.geom.tri.spheretriext(nDim,x);
elseif nDim==3
    if nargin<2
        nPoints = ellObj.nPlot3dPoints;
    end
    fGetGrid=@(x)gras.geom.tri.spheretriext(nDim,x);
else
    throwerror('wrongDim','ellipsoid must be of dimension 2 or 3');
end
if nargout>1
    [dirMat, fMat]=fGetGrid(nPoints);
else
    dirMat=fGetGrid(nPoints);
end
%
[cenVec qMat]=double(ellObj);
bpMat=dirMat*gras.la.sqrtmpos(qMat,ellObj.getAbsTol());
cenMat=repmat(cenVec.',size(dirMat,1),1);
bpMat=bpMat+cenMat;