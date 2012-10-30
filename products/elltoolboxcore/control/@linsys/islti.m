function isLtiMat = islti(linSysMat)
% ISLTI checks if linear system is time-invariant.
%
% Input:
%   regular:
%       linSysMat: linsys[mRows,nCols] - a matrix of linear systems.
%
% Output:
%   isLtiMat: double[mRows,nCols] - a matrix such that it's element at
%       position (i,j) is 1 if corresponding linear system is time-invariant, 
%       and 0 otherwise.
%
% $Author: Alex Kurzhanskiy  <akurzhan@eecs.berkeley.edu> $    $Date: 2004-2008 $
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Ivan Menshikov  <ivan.v.menshikov@gmail.com> $    $Date: 2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
global ellOptions;
%
if ~isstruct(ellOptions)
    evalin('base', 'ellipsoids_init;');
end
%
if ~(isa(lsys, 'linsys'))
    error('ISLTI: input argument must be linear system object.');
end
%
[mRows, nCols] = size(linSysMat);
isLtiMat = zeros(mRows, nCols);
%
for iRow = 1:mRows
    for jCol = 1:nCols
        % double type should be replaced with boolean
        if linSysMat(iRow, jCol).lti > 0
            isLtiMat(iRow, jCol) = 1;
        else
            isLtiMat(iRow, jCol) = 0;
        end
    end
end
%
end
