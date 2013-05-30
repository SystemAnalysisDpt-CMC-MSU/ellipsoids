function [diagQVec, resQMat]=findConstruction(firstEllMat,firstBasMat,...
    secBasMat,firstIndVec,secIndVec,secDiagVec)
% FINDCONSTRUCTION - construct matrices from two matrices from orthogonal
%                    subspaces
% Input:
%   regular:
%       firstEllMat: double: [nSDim,nSDim] - matrix from a subspace
%       firstBasMat: double: [nDim,r1Col] - basis of one subspace
%       secBasMat: double: [nDim,r2Col] - basis of other subspace
%       firstIndVec: double: [1,r1Col] - indices of vectors in resulting
%           matrices from first subspace
%       secIndVec: double: [1,r2Col] - indices of vectors in resulting
%           matrices from first subspace
%       secDiagVec: double: [1,r2Col] - elements for diagonal matrix in
%           second subspace
% Output:
%   diagQVec: double: [nDim,1] - constructed vector
%   resQMat: double: [nDim,nDim] - constructed matrix
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
[eigPMat diaPMat]=eig(firstEllMat);
nDimSpace=size(firstBasMat,1);
resQMat=zeros(nDimSpace);
basMat=firstBasMat*eigPMat;
resQMat(:,firstIndVec)=basMat;
resQMat(:,secIndVec)=secBasMat;
diagQVec=zeros(nDimSpace,1);
diagQVec(firstIndVec)=diag(diaPMat);
diagQVec(secIndVec)=secDiagVec;