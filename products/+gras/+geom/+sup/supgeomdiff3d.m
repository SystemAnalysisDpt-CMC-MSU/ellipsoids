function rhoDiffVec=supgeomdiff3d(rho1Vec,rho2Vec,lMat)
% SUPGEOMDIFF3D - calculates support function of two 3-dimensional
%                 convex sets defined by their support functions
%
% Input:
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
absTol = 1e-5;
checkmultvar(['isrow(x1)&&isrow(x2)&&ismatrix(x3)&&',...
    'size(x1,2)==size(x2,2)&&size(x1,2)==size(x3,2)'],3,...
    rho1Vec,rho2Vec,lMat,'errorTag','wrongInput');
%

nDims=size(lMat,1);
if nDims~=3
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
fSMat=convhulln(sMat.');
%  trimesh(fSMat,sMat(1,:),sMat(2,:),sMat(3,:),'EdgeColor',[1,0,0],'FaceAlpha',0) 
dist = zeros(1,size(lMat,2)); 
for indL = 1:size(lMat,2)
%     lMat(:,indL)
    for indTri = 1:size(fSMat,1)
        triMat = sMat(:,fSMat(indTri,:));
        x1Vec = triMat(:,2)-triMat(:,1);
        x2Vec = triMat(:,3)-triMat(:,1);
        normVec = cross(x1Vec,x2Vec);
        if abs(normVec'*lMat(:,indL)) > absTol           
            mu = triMat(:,1)'*normVec./(normVec'*lMat(:,indL));
        else
            mu = 0;
        end
        if mu > 0
            pointVec = mu*lMat(:,indL);
            p1Vec = (triMat(:,1)-pointVec)/norm(triMat(:,1)-pointVec);
            p2Vec = (triMat(:,2)-pointVec)/norm(triMat(:,2)-pointVec);
            p3Vec = (triMat(:,3)-pointVec)/norm(triMat(:,3)-pointVec);
            if (abs(acosd(p1Vec'*p2Vec)+acosd(p2Vec'*p3Vec)+acosd(p3Vec'*p1Vec)-360) < absTol)...
                    ||(min(abs(triMat(:,1)-pointVec)<absTol*ones(3,1)))...
                    ||(min(abs(triMat(:,2)-pointVec)<absTol*ones(3,1)))...
                    ||(min(abs(triMat(:,3)-pointVec)<absTol*ones(3,1)))
                    
                dist(indL) = mu/norm(sMat(:,indL));
            end
        end  
    end
end
rhoDiffVec=rhoDiffVec./dist;
end
