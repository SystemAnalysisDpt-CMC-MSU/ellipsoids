function display(myEllArr)
%
% DISPLAY - Displays the details of the ellipsoid object.
%
% Input:
%   regular:
%       myEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.
%           
% Example:
%   ellObj = ellipsoid([-2; -1], [2 -1; -1 1]);
%   display(ellObj)
% 
%   ellObj =
% 
%   Center:
%       -2
%       -1
% 
%   Shape Matrix:
%        2    -1
%       -1     1
% 
%   Nondegenerate ellipsoid in R^2.
% 
% 
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright: The Regents of the University of California 
%             2004-2008 $

fprintf('\n');
disp([inputname(1) ' =']);

sizeVec = size(myEllArr);
if numel(myEllArr) > 1
    fprintf('%d', sizeVec(1));
    for iDimension = 2 : length(sizeVec)
        fprintf('x%d', sizeVec(iDimension)); 
    end
    fprintf(' array of ellipsoids.\n\n');
else
    SEll = myEllArr.toStruct();
    fprintf('\n');
    fprintf('Center:\n'); disp(SEll.q.');
    fprintf('Shape Matrix:\n'); disp(SEll.Q);
    if isempty(myEllArr)
        fprintf('Empty ellipsoid.\n\n');
    else
        [spaceDim, ellDim]    = dimension(myEllArr);
        if ellDim < spaceDim
            fprintf('Degenerate (rank %d) ellipsoid in R^%d.\n\n', ...
                ellDim, spaceDim);
        else
            fprintf('Nondegenerate ellipsoid in R^%d.\n\n', spaceDim);
        end
    end
end
