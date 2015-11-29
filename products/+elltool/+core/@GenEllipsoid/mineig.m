function minEigArr=mineig(inpEllArr)
%
% MINEIG - return the minimal eigenvalue of the GenEllipsoid.
%
% Input:
%	regular:
%		inpEllArr: GenEllipsoid [nDims1,nDims2,...,nDimsN] - array of 
%			GenEllipsoids.
%
% Output:
%	minEigArr: double[nDims1,nDims2,...,nDimsN] - array of minimal 
%		eigenvalues of GenEllipsoids in the input array inpEllMat.
% 
% Example:
%	ellObj = elltool.core.GenEllipsoid([-2; 4], [4 -1; -1 5]);
%	minEig = mineig(ellObj)
% 
%	minEig =
% 
%		3.3820 
% 
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%

import elltool.conf.Properties;
import elltool.core.GenEllipsoid;
GenEllipsoid.checkIsMe(inpEllArr);
modgen.common.checkvar(inpEllArr,'~any(x(:).isEmpty())',...
    'errorTag','wrongInput:emptyGenEllipsoid','errorMessage',...
    'input argument contains empty GenEllipsoid');
minEigArr = arrayfun(@(ell) min(diag(ell.diagMat)),inpEllArr);