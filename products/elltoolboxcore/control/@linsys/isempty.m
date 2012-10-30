function isEmptyMat = isempty(linSysMat)
% ISEMPTY checks if linear system is empty.
%
% Input:
%   regular:
%       linSysMat: linsys[mRows,nCols] - a matrix of linear systems.
%
% Output:
%   isEmptyMat: double[mRows,nCols] - a matrix such that it's element at
%       position (i,j) is 1 if corresponding linear system is empty, 
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
if ~(isa(linSysMat, 'linsys'))
    error('ISEMPTY: input argument must be linear system object.');
end
%
[mRows, nCols] = size(linSysMat);
isEmptyMat = zeros(mRows, nCols);
%
for iRow = 1:mRows
    for jCol = 1:nCols
        % double type should be replaced with boolean
        if isempty( linSysMat(iRow, jCol).A ) 
            isEmptyMat(iRow, jCol) = 1;
        else
            isEmptyMat(iRow, jCol) = 0;
        end
    end
end
%
end
