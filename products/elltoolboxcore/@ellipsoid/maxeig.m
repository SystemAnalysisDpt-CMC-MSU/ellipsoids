function maxEigArr = maxeig(inpEllArr)
%
% MAXEIG - return the maximal eigenvalue of the ellipsoid.
%
% Input:
%   regular:
%       inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of 
%            ellipsoids.
%
% Output:
%   maxEigArr: double[nDims1,nDims2,...,nDimsN] - array of maximal 
%       eigenvalues of ellipsoids in the input matrix inpEllMat.
% 
% Example:
%   ellObj = ellipsoid([-2; 4], [4 -1; -1 5]);
%   maxEig = maxeig(ellObj)
% 
%   maxEig =
% 
%       5.6180
% 
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

import elltool.conf.Properties;

ellipsoid.checkIsMe(inpEllArr);
modgen.common.checkvar(inpEllArr,'~any(x(:).isEmpty())',...
    'errorTag','wrongInput:emptyEllipsoid','errorMessage',...
    'input argument contains empty ellipsoid');

maxEigArr = arrayfun(@(x) max(eig(x.shapeMat)),inpEllArr);