function outEllArr = getMove2Origin(inpEllArr)
%
% GETMOVE2ORIGIN - do the same as MOVE2ORIGIN method: moves ellipsoids in 
%       the given array to the origin, with only difference, that it doesn't
%       modify input array of ellipsoids.
%
% Input:
%   regular:
%       inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of 
%           ellipsoids.
%
% Output:
%   outEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
%       with the same shapes as in inpEllArr centered at the origin.
%
% Example:
%   ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   outEllObj = ellObj.getMove2Origin()
% 
%   outEllObj =
% 
%   Center:
%        0
%        0
% 
%   Shape:
%        4    -1
%       -1     1
% 
%   Nondegenerate ellipsoid in R^2.
%
% $Author: Khristoforov Dmitry <dmitrykh92@gmail.com> $   
% $Date: May-2013$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
outEllArr = inpEllArr.getCopy();
outEllArr.move2origin();
end