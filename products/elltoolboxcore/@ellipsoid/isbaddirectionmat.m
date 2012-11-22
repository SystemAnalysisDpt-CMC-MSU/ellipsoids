function isBadDirVec = isbaddirectionmat(q1Mat, q2Mat, dirsMat)
% ISBADDIRECTIONMAT - Checks if it is possible to build ellipsoidal approximation 
% of the geometric difference of two ellipsoids with shape matrices q1Mat and q2Mat
% specified by matrix dirsMat                   
%                    
% Input:
%   regular:
%       q1Mat: double[nDims, nDims] - shape matrix of minuend ellipsoid
%       q2Mat: double[nDims, nDims] - shape matrix of subtrahend ellipsoid
%       dirsMat: double[nDims,nDirs] - columns of dirsMat are direction vectors
%
% Output:
%   isBadDirVec: logical[1,nDirs] - true marks direction vector as bad - ellipsoidal 
%   	approximation cannot be computed for this direction, false means the opposite.
%
%   Note: in both cases, when geometric difference empty and when geometric difference is
%       a single point, function returns same vector isBadDirVec=true(1,nDirs). Therefore, 
%       the case where first ellipsoid is less than second, should be checked advance. 
%
%
% $Author: Rustam Guliev  <glvrst@gmail.com> $	$Date: 2012-16-11$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
%
import modgen.common.throwerror;
  
[nDim, nDirs] = size(dirsMat);

if ( ~all(size(q1Mat)==nDim) ) || (~all(size(q2Mat)==nDim))
	throwerror('wrongInput:dimsMismatch',...
        'ISBADDIRECTIONMAT: dimensions mismatch');
end
if det(q2Mat)==0
	throwerror('wrongInput:singularMat',...
    'ISBADDIRECTIONMAT: argument must be symmetric positive definite matrix');
end

isBadDirVec = true(1,nDirs);
lambdaMin   = min(eig(q1Mat/q2Mat));
%if lambdaMin > (1-eps)
    for iDirCout = 1:nDirs
        lVec = dirsMat(:, iDirCout);
        checkVal = sqrt( (lVec'*q1Mat*lVec)/(lVec'*q2Mat*lVec) );
        if lambdaMin >= checkVal
            isBadDirVec(iDirCout) = false;
        end
    end
%end
