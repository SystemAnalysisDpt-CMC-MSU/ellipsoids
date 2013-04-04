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
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Aushkap Nikolay <n.aushkap@gmail.com> $  
% $Date: 07-12-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012 $

MAX_DISP_ELEM = 15;

fprintf('\n');
if (isscalar(hypArr))
    disp([inputname(1) ' =']);
else
    fprintf('array of hyperplanes: \n');
end
sizeVec = size(hypArr);
fprintf('size: %s\n', mat2str(sizeVec));

nHyp = numel(hypArr);
nDispElem = min(nHyp, MAX_DISP_ELEM);

nDims = ndims(hypArr);
indList = cell(1, nDims);
indArr = reshape(1:numel(hypArr), sizeVec);
arrayfun(@(x, y) subDisplay(x, y), indArr(1:nDispElem), ...
    hypArr(1:nDispElem));

if (nHyp > MAX_DISP_ELEM)
    fprintf('... <<%s elements more>> ...\n', ...
        mat2str((nHyp - MAX_DISP_ELEM)));
end

    function subDisplay(indCur, inpHyp)
        [indList{:}] = ind2sub(sizeVec, indCur);
        indVec = [indList{:}];
        fprintf('\n');
        fprintf('Element: %s',mat2str(indVec));
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

end

