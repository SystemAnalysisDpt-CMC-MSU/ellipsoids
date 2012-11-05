function isLtiMat = islti(linSysMat)
% ISLTI checks if linear system is time-invariant.
%
% Input:
%   regular:
%       linSysMat: linsys[mRows,nCols] - a matrix of linear systems.
%
% Output:
%   isLtiMat: logical[mRows,nCols] - a matrix such that it's element at
%       position (i,j) is true if corresponding linear system is time-invariant, 
%       and false otherwise.
%
% $Author: Alex Kurzhanskiy  <akurzhan@eecs.berkeley.edu> $    $Date: 2004-2008 $
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Ivan Menshikov  <ivan.v.menshikov@gmail.com> $    $Date: 2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
import elltool.conf.Properties;
%
if ~(isa(linSysMat, 'linsys'))
    modgen.common.throwerror('wrongType', 'input argument must be linear system object.');
end
%
[mRows, nCols] = size(linSysMat);
isLtiMat = false(mRows, nCols);
%
for iRow = 1:mRows
    for jCol = 1:nCols
        isLtiMat(iRow, jCol) = linSysMat(iRow, jCol).lti;
    end
end
%
end
