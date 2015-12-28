function isPositiveArr=isdegenerate(myEllArr)
%
% ISDEGENERATE - checks if the GenEllipsoid is degenerate.
%
% Input:
%	regular:
%		myEllArr: GenEllipsoid[nDims1,nDims2,...,nDimsN] - array of
%			GenEllipsoids.
%
% Output:
%	isPositiveArr: logical[nDims1,nDims2,...,nDimsN],
%		isPositiveArr(iCount) = true if GenEllipsoid myEllMat(iCount)
%		is degenerate, false - otherwise.
%
% Example:
%	ellObj = ellipsoid([1; 1], eye(2));
%	isdegenerate(ellObj)
%
%	ans =
%
%		0
%
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com>
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
elltool.core.GenEllipsoid.checkIsMe(myEllArr);
modgen.common.checkvar(myEllArr,'~any(x(:).isEmpty())',...
    'errorTag','wrongInput:emptyEllipsoid',...
    'errorMessage','input argument contains empty GenEllipsoid.');
isPositiveArr=true(size(myEllArr));
if ~isempty(myEllArr)
    for iElem=1:numel(myEllArr)
        qInfMat=myEllArr(iElem).getQInfMat();
        isDegenerate=all(qInfMat(:)==0)&&...
            isdegenerate@elltool.core.AEllipsoid(myEllArr(iElem));
        isPositiveArr(iElem)=isDegenerate;
    end
end
end