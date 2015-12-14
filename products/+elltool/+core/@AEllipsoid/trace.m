function trArr = trace(ellArr)
%
% TRACE - returns the trace of the AEllipsoid.
%
%    trArr = TRACE(ellArr)  Computes the trace of AEllipsoids in
%       ellipsoidal array ellArr.
%
% Input:
%   regular:
%       ellArr: AEllipsoid [nDims1,nDims2,...,nDimsN] - array
%           of AEllipsoids.
%
% Output:
%	trArr: double [nDims1,nDims2,...,nDimsN] - array of trace values, 
%       same size as ellArr.
%
% Example:
%   firstEllObj = ellipsoid([4 -1; -1 1]);
%   secEllObj = ell_unitball(2);
%   ellVec = [firstEllObj secEllObj];
%   trVec = ellVec.trace()
% 
%   trVec =
% 
%       5     2
%       
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
checkIsMeVirtual(ellArr);
modgen.common.checkvar(ellArr,'~any(x(:).isEmpty())',...
    'errorTag','wrongInput:emptyEllipsoid',...
    'errorMessage','input argument contains empty ellipsoid.')
trArr = arrayfun(@(x) trace(x.getShapeMat), ellArr);