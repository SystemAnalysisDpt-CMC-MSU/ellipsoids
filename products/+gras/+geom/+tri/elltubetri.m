function [vMat,fMat]=elltubetri(QArray,aMat,timeVec,nSPoints)
% ELLTUBETRI builds a triangulation of ellipsoidal tube
%
% Input:
%   regular:
%       QArray: double[2,2,nTimes] - array of ellipsoidal
%           configuration matrices
%       aMat: double[2,nTimes] - array of ellipsoidal centers
%           timeVec: double[1,nDims] - time vector
%       timeVec: double[1,nTimes] - time vector for ellipsoidal tube
%       nSPoints: double[1,1] - number of points used for partitioning
%           [0,2pi] range when building tube triangulation
%
% Output:
%   vMat: double[nVertices,3] - array of vertex coordinates, the first
%   dimension is time.
%   fMat: double[nFaces,3] - face corners specified as row numbers in vMat
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2009-07 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
import gras.geom.circlepart;
import gras.ellapx.common.*;
import gras.gen.SquareMatVector;
import modgen.common.checkmultvar;
%
checkmultvar(['size(x1,1)==2&&size(x1,2)==2&&size(x2,1)==2&&',...
    'size(x1,3)==size(x2,2)&&ndims(x1)<=3&&ismatrix(x2)'],2,QArray,aMat);
%
qSizeVec=[size(QArray),1];
aMat=aMat(:).';
aaMat=aMat(ones(1,nSPoints),:);
QArray_sqrt=SquareMatVector.sqrtmpos(QArray);
QArray_united=QArray_sqrt(:,:);
scoord=circlepart(nSPoints,[0 2*pi]);
ecoord=transpose(scoord*QArray_united+aaMat);
[ax,ay]=cMatTranslate(ecoord);
atimeVec=timeVec(ones(1,nSPoints),:);
atimeVec=atimeVec(:);
vMat=[atimeVec ax ay];
fMat=createTriangleFaces(nSPoints,qSizeVec(3));
end
function fMat=createTriangleFaces(nEllPoints,nTimePoints)
indTimeVec=1:1:(nTimePoints);
indEllPointVec=transpose(1:1:(nEllPoints-1));
%
indTimeLessOneVec=transpose(indTimeVec(1:(end-1)));
indTimeShiftVec=indTimeLessOneVec*nEllPoints;
indTimeLessOneVec=(indTimeLessOneVec.'-1)*nEllPoints;
indTimeLessOneVec=indTimeLessOneVec(ones(1,nEllPoints-1),:);
indEllMat=reshape(indEllPointVec(:,ones(1,nTimePoints-1))+...
    indTimeLessOneVec,[],1);
fPart1Mat=[indEllMat,indEllMat+1,indEllMat+1+nEllPoints];
fPart2Mat=[indEllMat+1+nEllPoints,indEllMat+nEllPoints,indEllMat];
fPart3Mat=[indTimeShiftVec,indTimeShiftVec+1-nEllPoints,indTimeShiftVec+1];
fPart4Mat=[indTimeShiftVec+1,indTimeShiftVec+nEllPoints,indTimeShiftVec];
fMat=zeros((nTimePoints-1)*nEllPoints*2,3);
for iDim=1:1:3
    fMat(:,iDim)=[fPart1Mat(:,iDim);fPart2Mat(:,iDim);...
        fPart3Mat(:,iDim);fPart4Mat(:,iDim)];
end
end
function [x,y]=cMatTranslate(X)
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