function trArr = trace(ellArr)
%
% TRACE - returns the trace of the ellipsoid.
%
%    trArr = TRACE(ellArr)  Computes the trace of ellipsoids in
%       ellipsoidal array ellArr.
%
% Input:
%   regular:
%       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
%           of ellipsoids.
%
% Output:
%	trArr: double [nDims1,nDims2,...,nDimsN] - array of trace values, 
%       same size as ellArr.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

ellipsoid.checkIsMe(ellArr);
modgen.common.checkvar(ellArr,'~any(isempty(x(:)))',...
    'errorTag','wrongInput:emptyEllipsoid',...
    'errorMessage','input argument contains empty ellipsoid.')
trArr = arrayfun(@(x) trace(x.shape), ellArr);
