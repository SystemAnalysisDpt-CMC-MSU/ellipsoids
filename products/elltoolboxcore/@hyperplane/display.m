function display(myHypMat)
%
% DISPLAY - Displays hyperplane object.
%
% Input:
%   regular:
%       myHypMat: hyperplane [mRows, nCols] - matrix of hyperplanes.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

fprintf('\n');
disp([inputname(1) ' =']);

[mRows, nCols] = size(myHypMat);
if (mRows > 1) | (nCols > 1)
    fprintf('%dx%d array of hyperplanes.\n\n', mRows, nCols);
    return;
end

fprintf('\n');
fprintf('Normal:\n'); disp(myHypMat.normal);
fprintf('Shift:\n'); disp(myHypMat.shift);

nDims = dimension(myHypMat);
if nDims < 1
    fprintf('Empty hyperplane.\n\n');
else
    fprintf('Hyperplane in R^%d.\n\n', nDims);
end
