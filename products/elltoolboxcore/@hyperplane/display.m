function display(hpArr)
%
% DISPLAY - Displays hyperplane object.
%
% Input:
%   regular:
%       myHypArr: hyperplane [hpDim1, hpDim2, ...] - array
%           of hyperplanes.
% 
% Example:
%   hypObj = hyperplane([-1; 1]);
%   display(hypObj)
% 
%   hypObj =
%   size: [1 1]
% 
%   Element: [1 1]
%   Normal:
%       -1
%        1
% 
%   Shift:
%        0
% 
%   Hyperplane in R^2.
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
DEFAULT_NAME = 'hpArr';

fprintf('\n');
variableName = inputname(1);
if (isempty(variableName))
    variableName = DEFAULT_NAME;
end
disp([variableName ' =']);

strucdisp(hpArr.toStruct(), 'maxArrayLength', MAX_DISP_ELEM, ...
     'defaultName', variableName);
end


