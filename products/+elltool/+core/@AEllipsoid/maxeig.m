function maxEigArr = maxeig(inpEllArr)
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
%       5.6180
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
maxEigArr = arrayfun(@getSingleMaxEig,inpEllArr);
%
function maxEig=getSingleMaxEig(ellObj)
    shapeMat=ellObj.getShapeMat();
    if max(shapeMat(:))==Inf
        maxEig=Inf;
    elseif isnan(max(shapeMat(:)))
        maxEig=NaN;
    else
        maxEig=max(eig(shapeMat));
    end
end
end