function rhoDiffVec=supgeomdiff3d(rho1Vec,rho2Vec,lMat)
% SUPGEOMDIFF3D - calculates support function of two 3-dimensional
%                 convex sets defined by their support functions
%
% Input:
%  regular:
%   rho1Vec: double [1,nDirs] - support function values for the
%                               first set
%   rho2Vec: double [1,nDirs] - support function values for the
%                               second set
%   lMat: double[nDims,nDirs] - set of directions for which the support
%                               functions of two sets are defined
%
% Output:
%   rhoDiffVec: double[1,nDirs] - support function values for the geometric
%                                 difference of two sets
%
% $Author: Ilya Lyubich  <lubi4ig@gmail.com> $	$Date: 2013-04-22 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
import modgen.common.throwerror;
import modgen.common.checkmultvar;
ABS_TOL = 1e-5;
checkmultvar(['isrow(x1)&&isrow(x2)&&ismatrix(x3)&&',...
    'size(x1,2)==size(x2,2)&&size(x1,2)==size(x3,2)'],3,...
    rho1Vec,rho2Vec,lMat,'errorTag','wrongInput');
%

nDims=size(lMat,1);
if nDims~=3
    throwerror('wrongInput','only 2-dimensional sets are supported');
end
rhoDiffVec=rho1Vec-rho2Vec;
if any(rhoDiffVec<=0)
    throwerror('wrongInput',...
        'geometric difference is expected to have a non-empty interior');
end
sMat=lMat./repmat(rhoDiffVec,nDims,1);
fSMat=convhulln(sMat.');
distVec = zeros(1,size(lMat,2));
for iDist = 1:size(lMat,2)
    for jTri = 1:size(fSMat,1)
        triMat = sMat(:,fSMat(jTri,:));
        x1Vec = triMat(:,2)-triMat(:,1);
        x2Vec = triMat(:,3)-triMat(:,1);
        norm1Vec  = cross(sMat(:,iDist),x2Vec);
        detTemp  = dot(x1Vec,norm1Vec);
        if (abs(detTemp) > ABS_TOL)
            invDet = 1/detTemp;
            sPoint = -triMat(:,1);
            uDist = invDet*dot(sPoint,norm1Vec);
            if (uDist>=-ABS_TOL)
                norm2Vec = cross(sPoint,x1Vec);
                vDist = invDet*dot(sMat(:,iDist),norm2Vec);
                if (vDist>=-ABS_TOL && uDist+vDist<=1+ABS_TOL)
                    tDist = invDet*dot(x2Vec,norm2Vec);
                    if tDist>0
                        distVec(iDist) =tDist;
                    end
                end
            end
        end
    end
end
rhoDiffVec=rhoDiffVec./distVec;
end
