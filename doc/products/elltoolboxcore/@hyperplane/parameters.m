function [normVec, hypScal] = parameters(myHyp)
%
% PARAMETERS - return parameters of hyperplane - normal vector and shift.
%
%   [normVec, hypScal] = PARAMETERS(myHyp) - returns normal vector
%       and scalar value of the hyperplane.
%
% Input:
%   regular:
%       myHyp: hyperplane [1, 1] - single hyperplane of dimention nDims.
%
% Output:
%   normVec: double[nDims, 1] - normal vector of the hyperplane myHyp.
%   hypScal: double[1, 1] - scalar of the hyperplane myHyp.
% 
% Example:
%   hypObj = hyperplane([-1; 1]);
%   [normVec, hypScal] = parameters(hypObj)
% 
%   normVec =
% 
%       -1
%        1
% 
% 
%   hypScal =
% 
%        0
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Aushkap Nikolay <n.aushkap@gmail.com> $  
% $Date: 30-11-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012 $

[normVec, hypScal] = double(myHyp);
