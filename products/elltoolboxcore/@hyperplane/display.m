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
%
% $Author: Aushkap Nikolay <n.aushkap@gmail.com> $  $Date: 07-12-2012$
% $Copyright: Moscow State University,
%   Faculty of Computational Mathematics and Computer Science,
%   System Analysis Department 2012 $

fprintf('\n');
if (isscalar(hypArr))
    disp([inputname(1) ' =']);
else
    fprintf('array of hyperplanes: \n');
end
    
arrayfun(@(x) subDisplay(x), hypArr);

end

function subDisplay(inpHyp)

fprintf('\n');
fprintf('Normal:\n'); disp(inpHyp.normal);
fprintf('Shift:\n'); disp(inpHyp.shift);

nDims = dimension(inpHyp);
if nDims < 1
    fprintf('Empty hyperplane.\n\n');
else
    fprintf('Hyperplane in R^%d.\n\n', nDims);
end

end
