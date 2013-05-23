function display(myEllMat)
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

[mRows, nCols] = size(myEllMat);
if (mRows > 1) || (nCols > 1)
    fprintf('%dx%d array of ellipsoids.\n\n', mRows, nCols);
else
    fprintf('\n');
    fprintf('Center:\n'); disp(myEllMat.centerVec);
    fprintf('Shape Matrix:\n'); disp(myEllMat.shapeMat);
    if isempty(myEllMat)
        fprintf('Empty ellipsoid.\n\n');
    else
        [spaceDim, ellDim]    = dimension(myEllMat);
        if ellDim < spaceDim
            fprintf('Degenerate (rank %d) ellipsoid in R^%d.\n\n', ...
                ellDim, spaceDim);
        else
            fprintf('Nondegenerate ellipsoid in R^%d.\n\n', spaceDim);
        end
    end
end
