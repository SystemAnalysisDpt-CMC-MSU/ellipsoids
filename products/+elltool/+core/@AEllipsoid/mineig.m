function minEigArr = mineig(inpEllArr)
%
% MAXEIG - return the maximal eigenvalue of the AEllipsoid.
%
% Input:
%   regular:
%       inpEllArr: AEllipsoid [nDims1,nDims2,...,nDimsN] - array of 
%            AEllipsoids.
%
% Output:
%   maxEigArr: double[nDims1,nDims2,...,nDimsN] - array of maximal 
%       eigenvalues of AEllipsoids in the input matrix inpEllMat.
% 
% Example:
%   ellObj = ellipsoid([-2; 4], [4 -1; -1 5]);
%   maxEig = maxeig(ellObj)
% 
%   maxEig =
% 
%       3.3820 
% 
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
import elltool.conf.Properties;
checkIsMeVirtual(inpEllArr);
modgen.common.checkvar(inpEllArr,'~any(x(:).isEmpty())',...
    'errorTag','wrongInput:emptyEllipsoid','errorMessage',...
    'input argument contains empty ellipsoid');
minEigArr = arrayfun(@getSingleMinEig,inpEllArr);
%
function minEig=getSingleMinEig(ellObj)
    shapeMat=ellObj.getShapeMat();
    if min(shapeMat(:))==Inf
        minEig=Inf;
    elseif isnan(min(shapeMat(:)))
        minEig=NaN;
    else
        minEig=min(eig(shapeMat));
    end
end
end