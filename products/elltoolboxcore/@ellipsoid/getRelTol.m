function [relTolArr, relTolVal] = getRelTol(ellArr, varargin)
% GETRELTOL - gives the array of relTol for all elements in ellArr
%
% Input:
%   regular:
%       ellArr: ellipsoid[nDim1, nDim2, ...] - multidimension array
%           of ellipsoids
%   optional: 
%       fRelTolFun: function_handle[1,1] - function that apply 
%           to the relTolArr. The default is @min.
% Output:
%   regular:
%       relTolArr: double [relTol1, relTol2, ...] - return relTol for 
%           each element in ellArr
%   optional:
%       relTol: double[1,1] - return result of work fRelTolFun with 
%           the relTolArr
%
% Usage:
%   use [~,relTol] = ellArr.getRelTol() if you want get only
%       relTol,
%   use [relTolArr,relTol] = ellArr.getRelTol() if you want get 
%       relTolArr and relTol,
%   use relTolArr = ellArr.getRelTol() if you want get only relTolArr
% 
% Example:
%   firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
%   secEllObj = ellipsoid([1 ;2], eye(2));
%   ellVec = [firstEllObj secEllObj];
%   ellVec.getRelTol()
% 
%   ans =
% 
%      1.0e-05 *
% 
%       1.0000    1.0000
% 
% 
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $ 
%$Author: Grachev Artem  <grachev.art@gmail.com> $
%$Date: March-2013 $
%$Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2013 $  
%

[relTolArr, relTolVal] = ellArr.getProperty('relTol',varargin{:});
