function [vMat,fMat]=build_etube2_pmodel(QArray,aMat,timeVec,nSPoints)
% BUILD_ETUBE2_PMODEL builds a triangulation of ellipsoidal tube
%
% Input:
%   regular:
%       QArray: double[nDims,nDims,nTimes] - array of ellipsoidal
%           configuration matrices
%       aMat: double[nDims,nTimes] - array of ellipsoidal centers
%           timeVec: double[1,nDims] - time vector
%       timeVec: double[1,nTimes] - time vector for ellipsoidal tube
%       nSPoints: double[1,1] - number of points used for partitioning
%           [0,2pi] range when building tube triangulation
%
% Output:
%   vMat: double[nVertices,3] - array of vertex coordinates
%   fMat: double[nFaces,3] - face corners specified as row numbers in vMat
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2009-07 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $

import gras.geom.circlepart;
import gras.ellapx.common.*;
import gras.ellapx.plot.tri.create_triangle_facets;
import gras.gen.SquareMatVector;
xsize=size(QArray);
aMat=aMat(:).';
aaMat=aMat(ones(1,nSPoints),:);
QArray_sqrt=SquareMatVector.sqrtm(QArray);
QArray_united=QArray_sqrt(:,:);
scoord=circlepart(nSPoints,[0 2*pi]);
ecoord=transpose(scoord*QArray_united+aaMat);
[ax,ay]=cmatrix_translate(ecoord);
atimeVec=timeVec(ones(1,nSPoints),:);
atimeVec=atimeVec(:);
vMat=[atimeVec ax ay];
fMat=create_triangle_facets(vMat,nSPoints,xsize(3));
end
function [x,y]=cmatrix_translate(X)
xsize=size(X);
TX=X.';
xnum=transpose(1:1:xsize(2));
xnum=xnum(:,ones(1,xsize(1)/2)); 
dxnum=xsize(2)+xsize(2);
xmulmax=dxnum*(xsize(1)/2-1);
xmul=0:dxnum:xmulmax;
xmul=xmul(ones(1,xsize(2)),:);
xres=xmul+xnum;
x=TX(xres(:));
y=TX(xres(:)+xsize(2));
end