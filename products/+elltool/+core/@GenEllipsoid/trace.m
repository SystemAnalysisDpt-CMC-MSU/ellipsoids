function trArr = trace(ellArr)
%
% TRACE - returns the trace of the GenEllipsoid.
%
%	trArr = TRACE(ellArr)  Computes the trace of GenEllipsoids in
%		ellipsoidal array ellArr.
%
% Input:
%	regular:
%		ellArr: GenEllipsoid [nDims1,nDims2,...,nDimsN] - array
%			of GenEllipsoids.
%
% Output:
%	trArr: double [nDims1,nDims2,...,nDimsN] - array of trace values, 
%		same size as ellArr.
%
% Example:
%	ellObj = GenEllipsoid([5;2],eye(2),[1 3; 4 5]);
%	trVec = ellObj.trace()
% 
%	ans =
% 
%		51
%
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
import elltool.core.GenEllipsoid;
GenEllipsoid.checkIsMe(ellArr);
modgen.common.checkvar(ellArr,'~any(x(:).isEmpty())',...
    'errorTag','wrongInput:emptyEllipsoid',...
    'errorMessage','input argument contains empty ellipsoid.')
trArr=arrayfun(@(x)trace(x.getShapeMat()),ellArr);
