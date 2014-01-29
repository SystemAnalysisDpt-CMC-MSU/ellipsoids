function display(ellArr)
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
MAX_DISP_ELEM = 15;
DEFAULT_NAME = 'ellArr';

fprintf('\n');
variableName = inputname(1);
if (isempty(variableName))
    variableName = DEFAULT_NAME;
end
[SDataArray, SFieldNames, SFieldDescription] = ...
    ellArr.toStruct(false);
sizeVec = size(ellArr);
Properties = struct('actualClass', 'ellipsoid', 'size', sizeVec);
fprintf('-------ellipsoid object-------\n');
fprintf('Properties:\n');
strucdisp(Properties);
fprintf('\n');
fprintf('Fields (name, type, description):\n');
fprintf(['    ', SFieldNames.shapeMat, '    double    ',...
    SFieldDescription.shapeMat, '\n']);
fprintf(['    ', SFieldNames.centerVec, '    double    ',...
    SFieldDescription.centerVec, '\n']);
fprintf('\nData: \n');

if (numel(SDataArray) == 0)
    fprintf('[Empty array]\n');
else
    strucdisp(SDataArray, 'maxArrayLength', MAX_DISP_ELEM, ...
        'defaultName', variableName);
end
end

