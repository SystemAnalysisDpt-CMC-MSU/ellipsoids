function rhoDiffVec=supgeomdiff3d(rho1Vec,rho2Vec,lMat,fMat)
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
nDirs=size(lMat,2);
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
        end
        if mu > 0
%             cla
%             trimesh(fMat,sMat(1,:),sMat(2,:),sMat(3,:),'EdgeColor',[1,0,0],'FaceAlpha',0)
%             trimesh(fSMat,sMat(1,:),sMat(2,:),sMat(3,:),'EdgeColor',[1,0,0],'FaceAlpha',0) 
%             hold on
%             plot3([triMat(1,1),triMat(1,2),triMat(1,3),triMat(1,1)],[triMat(2,1),triMat(2,2),triMat(2,3),triMat(2,1)],[triMat(3,1),triMat(3,2),triMat(3,3),triMat(3,1)],'*')
%           
            point = mu*lMat(:,indL);
            p1 = (triMat(:,1)-point)/norm(triMat(:,1)-point);
            p2 = (triMat(:,2)-point)/norm(triMat(:,2)-point);
            p3 = (triMat(:,3)-point)/norm(triMat(:,3)-point);
            if (abs(acosd(p1'*p2)+acosd(p2'*p3)+acosd(p3'*p1)-360) < absTol)...
                    ||(min(abs(triMat(:,1)-point)<absTol*ones(3,1)))...
                    ||(min(abs(triMat(:,2)-point)<absTol*ones(3,1)))...
                    ||(min(abs(triMat(:,3)-point)<absTol*ones(3,1)))
                    
                dist(indL) = mu/norm(sMat(:,indL));
                if abs(dist(indL)-1)>1e-3
                    dist(indL)
                end
            end
%             i = inpolygon(x1'*(mu*lMat(:,indS)-tri(:,1)),x2'*(mu*lMat(:,indS)-tri(:,1)),[0,0,1]',[0,1,0]');
%             if i>0
%                 hold on
%                 mu*x1'*lMat(:,indS)
%                 mu*x2'*lMat(:,indS)
%                 plot3([tri(1,1),tri(1,2),tri(1,3),tri(1,1)],[tri(2,1),tri(2,2),tri(2,3),tri(2,1)],[tri(3,1),tri(3,2),tri(3,3),tri(3,1)],'*')
%                     
%                     plot3(mu*lMat(1,indS),mu*lMat(2,indS),mu*lMat(3,indS),'*r')
% %                     trisurf(fSMat,sMat(1,:),sMat(2,:),sMat(3,:),'FaceAlpha',0)
%                 hold off
%             end
        end
        
    end
    indL
end
rhoDiffVec=rhoDiffVec./dist;
end
