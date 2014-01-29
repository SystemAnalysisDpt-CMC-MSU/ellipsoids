function [orthBasMat rankVal]=findBasRank(qMat,absTol)
% FINDBASrankVal - find basis of space that is linear hull of
%                  input vector and find rankVal of that linear hull
% Input:
%   regular:
%       qMat: double: [nDim,nCol] - matrix whose columns form some subspace
%           in R^nDim
%       absTol: double: [1,1] - absolute tolerance
% Output:
%   orthBasMat: double: [nDim,nDim] - orthogonal matrix whose
%       columns form a basis in R^nDim
%   rankVal: double: [1,1] - rank of the convex hull of input vectors
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
[orthBasMat rBasMat]=qr(qMat);
if size(rBasMat,2)==1
    isNeg=rBasMat(1)<0;
    orthBasMat(:,isNeg)=-orthBasMat(:,isNeg);
else
    isNegVec=diag(rBasMat)<0;
    orthBasMat(:,isNegVec)=-orthBasMat(:,isNegVec);
end
tolerance = absTol*norm(qMat,'fro');
rankVal = sum(abs(diag(rBasMat)) > tolerance);
rankVal = rankVal(1); %for case where rBasZMat is vector.