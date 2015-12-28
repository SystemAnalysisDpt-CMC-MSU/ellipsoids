function volArr=volume(ellArr)
%
%	VOLUME - returns the volume of the each AEllipsoid in array.
%
%	volArr=VOLUME(ellArr) Computes the volume of AEllipsoids
%
%
% Input:
%	regular:
%		ellObj: AEllipsoid[nDims1,nDims2,...,nDimsN] - array
%			of AEllipsoids.
%
% Output:
%	volArr: double[nDims1,nDims2,...,nDimsN] - array of
%		volume values, same size as ellObj.
%
% Example:
%	firstEllObj=ellipsoid([4 -1; -1 1]);
%	secEllObj=ell_unitball(2);
%	ellVec=[firstEllObj secEllObj]
%	volVec=ellVec.volume()
%
%	volVec =
%
%		5.4414     3.1416
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California
%			2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2012 $
%
checkIsMeVirtual(ellArr);
modgen.common.checkvar(ellArr,'~any(x(:).isEmpty())',...
    'errorTag','wrongInput:emptyEllipsoid',...
    'errorMessage','input argument is empty.');
volArr=arrayfun(@(x) fSingleVolume(x), ellArr);
    function volVal=fSingleVolume(ellObj)
        if isdegenerate(ellObj)
            volVal=0;
        else
            qMat=ellObj.getShapeMat();
            nDim=ellObj.dimension();
            if mod(nDim,2)
                k=(nDim-1)*0.5;
                s=((2^(2*k + 1))*(pi^k)*factorial(k))/factorial(2*k + 1);
            else
                k=nDim *0.5;
                s=(pi^k)/factorial(k);
            end
            volVal=s*realsqrt(det(qMat));
        end
    end
end