function relTolArr = getRelTol(ellArr)
% GETRELTOL - gives array the same size as ellArr with values of relTol
%             properties for each ellipsoid in ellArr
%
% Input:
%   regular:
%       ellArr: ellipsoid[nDim1, nDim2,...] - multidimension array
%           of ellipsoids
%
% Output:
%   relTolArr: double[nDim1, nDim2,...] - multidimension array of relTol
%       properties for ellipsoids in ellArr
%
% $Author: Zakharov Eugene <justenterrr@gmail.com> $
%   $Date: 17-november-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Arrhematics and Computer Science,
%            System Analysis Department 2012 $
%
relTolArr = getProperty(ellArr,'relTol');
