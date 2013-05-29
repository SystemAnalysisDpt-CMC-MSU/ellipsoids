function rhoDiffVec=supgeomdiff2d(rho1Vec,rho2Vec,lMat)
% SUPGEOMDIFF2D calculates support function of two 2-dimensional
% convex sets defined by their support functions
%
% Input:
%   rho1Vec: double [1,nDirs] - support function values for the
%       first set
%   rho2Vec: double [1,nDirs] - support function values for the
%       second set
%   lMat: double[nDims,nDirs] - set of directions for which the support
%       functions of two sets are defined
% 
% Output:
%   rhoDiffVec: double[1,nDirs] - support function values for the geometric
%       difference of two sets
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2013-01-22 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
import modgen.common.throwerror;
import modgen.common.checkmultvar;

checkmultvar(['isrow(x1)&&isrow(x2)&&ismatrix(x3)&&',...
    'size(x1,2)==size(x2,2)&&size(x1,2)==size(x3,2)'],3,...
    rho1Vec,rho2Vec,lMat,'errorTag','wrongInput');
%
nDirs=size(lMat,2);
nDims=size(lMat,1);
if nDims~=2
    throwerror('wrongInput','only 2-dimensional sets are supported');
end
%
rhoDiffVec=rho1Vec-rho2Vec;
if any(rhoDiffVec<=0)
    throwerror('wrongInput',...
        'geometric difference is expected to have a non-empty interior');
end
%
sMat=lMat./repmat(rhoDiffVec,nDims,1);
indMat=convhulln(sMat.');
% plot(sMat(1,indMat),sMat(2,indMat));
indFaceLengthVec=indMat(:,2)-indMat(:,1);
isNegVec=indFaceLengthVec<0;
indFaceLengthVec(isNegVec)=nDirs+indFaceLengthVec(isNegVec);
indFaceVec=find(indFaceLengthVec>1);
nFaces=length(indFaceVec);
sNormVec=ones(1,nDirs);
for iFace=1:nFaces
    indFace=indFaceVec(iFace);
    indLeft=indMat(indFace,1);
    indRight=indMat(indFace,2);
    %
    bVec=sMat(:,indLeft);
    aFirstVec=bVec-sMat(:,indRight);
    %    
    nChangeDirs=indFaceLengthVec(indFace)-1;
    indDir=indLeft;
    for iDir=1:nChangeDirs
        indDir=indDir+1;
        if indDir>nDirs
            indDir=1;
        end
        %
        aMat=[aFirstVec,sMat(:,indDir)];
        xVec=aMat\bVec;
        sVal=xVec(2);
        if sVal<0
            throwerror('wrongState','s cannot be negative');
        end
        sNormVec(indDir)=sVal;
    end
end
rhoDiffVec=rhoDiffVec./sNormVec;
end
