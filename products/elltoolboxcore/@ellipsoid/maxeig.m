function maxEigArr = maxeig(inpEllArr)
%
% MAXEIG - return the maximal eigenvalue of the ellipsoid.
%
% Input:
%   regular:
%       inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - 
%         array of ellipsoids.
%
% Output:
%   maxEigArr: double[nDims1,nDims2,...,nDimsN] - array of 
%       maximal eigenvalues of ellipsoids in the input 
%       matrix inpEllMat.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Cybernetics,
%             System Analysis Department 2012 $
%

import elltool.conf.Properties;

ellipsoid.checkIsMe(inpEllArr);
modgen.common.checkvar(inpEllArr,'~any(isempty(x(:)))',...
    'errorTag','wrongInput:emptyEllipsoid','errorMessage',...
    'input argument contains empty ellipsoid');

maxEigArr = arrayfun(@(x) max(eig(x.shape)),inpEllArr);