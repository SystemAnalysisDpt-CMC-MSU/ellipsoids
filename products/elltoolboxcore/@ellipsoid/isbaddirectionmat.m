function [isBadDirVec,pUniversalVec] = isbaddirectionmat(q1Mat, q2Mat, dirsMat,absTol)
% ISBADDIRECTIONMAT - Checks if it is possible to build ellipsoidal
%                     approximation of the geometric difference of two
%                     ellipsoids with shape matrices q1Mat and q2Mat
%                     specified by matrix dirsMat
%
% Input:
%   regular:
%       q1Mat: double[nDims, nDims] - shape matrix of minuend ellipsoid
%       q2Mat: double[nDims, nDims] - shape matrix of subtrahend ellipsoid
%       dirsMat: double[nDims,nDirs] - columns of dirsMat are
%           direction vectors
%       absTol: double[1,1] - absolute tolerance
%
% Output:
%   isBadDirVec: logical[1,nDirs] - true marks direction vector
%       as bad - ellipsoidal approximation cannot be computed for this
%       direction, false means the opposite.
%
%       Note: in both cases, when geometric difference empty and when
%           geometric difference is a single point, function returns same
%           vector isBadDirVec=true(1,nDirs). Therefore,  the case where
%           first ellipsoid is less than second,
%           should be checked advance.
%
% $Author: Rustam Guliev  <glvrst@gmail.com> $	$Date: 2012-16-11$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
%
import modgen.common.throwwarn;

[nDim, nDirs] = size(dirsMat);

modgen.common.checkmultvar('all(size(x1)==x3)&&all(size(x2)==x3)',...
    3,q1Mat,q2Mat,nDim,...
    'errorTag','wrongInput:dimsMismatch',...
    'errorMessage','dimensions mismatch.');
modgen.common.checkmultvar('gras.la.ismatposdef(x1,x2)',...
    2,q2Mat,absTol,...
    'errorTag','wrongInput:singularMat',...
    'errorMessage','second argument must be positive definite matrix');

lamMin   = min(eig(q1Mat/q2Mat));
dirsCVec = mat2cell(dirsMat,nDim,ones(1,nDirs));
[isBadDirVec,pUniversalVec] = cellfun(@(x) culcPUniversal(x), dirsCVec);


    function [isBadDir,pUniversal] = culcPUniversal(dirVec)
        p1Par=sqrt(dirVec.'*q1Mat*dirVec);
        p2Par=sqrt(dirVec.'*q2Mat*dirVec);
        pPar=p1Par/p2Par;
        isBadDir = lamMin < pPar;
        pUniversal = min(pPar,lamMin);
    end
end
