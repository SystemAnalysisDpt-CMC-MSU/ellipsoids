function display(hypArr)
%
% DISPLAY - Displays hyperplane object.
%
% Input:
%   regular:
%       myHypArr: hyperplane [hpDim1, hpDim2, ...] - array
%           of hyperplanes.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

fprintf('\n');
disp([inputname(1) ' =']);

hpSizeVec = size(hypArr);
if ~isequal(hpSizeVec, [1, 1])
    fprintf('hyperplane [');
    fprintf('%d ', hpSizeVec);
    fprintf('\b] - array of hyperplanes.\n\n');
    return;
end

fprintf('\n');
fprintf('Normal:\n'); disp(hypArr.normal);
fprintf('Shift:\n'); disp(hypArr.shift);

nDims = dimension(hypArr);
if nDims < 1
    fprintf('Empty hyperplane.\n\n');
else
    fprintf('Hyperplane in R^%d.\n\n', nDims);
end
