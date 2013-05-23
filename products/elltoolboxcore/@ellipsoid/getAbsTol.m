function [absTolArr, absTolVal] = getAbsTol(ellArr, varargin)
% GETABSTOL - gives the array of absTol for all elements in ellArr
%
% Input:
%   regular:
%       ellArr: ellipsoid[nDim1, nDim2, ...] - multidimension array
%           of ellipsoids
%   optional
%       fAbsTolFun: function_handle[1,1] - function that apply
%           to the absTolArr. The default is @min.
%
% Output:
%   regular:
%       absTolArr: double [absTol1, absTol2, ...] - return absTol for
%           each element in ellArr
%   optional:
%       absTol: double[1,1] - return result of work fAbsTolFun with
%           the absTolArr
%
% Usage:
%   use [~,absTol] = ellArr.getAbsTol() if you want get only
%       absTol,
%   use [absTolArr,absTol] = ellArr.getAbsTol() if you want get
%       absTolArr and absTol,
%   use absTolArr = ellArr.getAbsTol() if you want get only absTolArr
%
% Example:
%   firstEllObj = ellipsoid([-1; 1], [2 0; 0 3]);
%   secEllObj = ellipsoid([1 2], eye(2));
%   ellVec = [firstEllObj secEllObj];
%   absTolVec = ellVec.getAbsTol()
% 
%   absTolVec =
% 
%      1.0e-07 *
% 
%       1.0000    1.0000
% 
% 
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $
%$Author: Grachev Artem  <grachev.art@gmail.com> $
%$Date: March-2013$
%$Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2013 $ 
[absTolArr, absTolVal] = ellArr.getProperty('absTol',varargin{:});
