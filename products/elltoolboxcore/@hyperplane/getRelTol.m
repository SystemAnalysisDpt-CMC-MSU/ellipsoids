function [relTolArr, relTolVal] = getRelTol(hpArr, varargin)
% GETRELTOL - gives the array of relTol for all elements in hpArr
%
% Input:
%   regular:
%       hpArr: hyperplane[nDim1, nDim2, ...] - multidimension array
%           of hyperplanes
%   optional:
%       fRelTolFun: function_handle[1,1] - function that apply
%           to the relTolArr. The default is @min.
% Output:
%   regular:
%       relTolArr: double [relTol1, relTol2, ...] - return relTol for
%           each element in hpArr
%   optional:
%       relTol: double[1,1] - return result of work fRelTolFun with
%           the relTolArr
%
% Usage:
%   use [~,relTol] = hpArr.getRelTol() if you want get only
%       relTol,
%   use [relTolArr,relTol] = hpArr.getRelTol() if you want get
%       relTolArr and relTol,
%   use relTolArr = hpArr.getRelTol() if you want get only relTolArr
%
% Example:
%   firsthpObj = hyperplane([-1; 1], 1);
%   sechpObj = hyperplane([1 ;2], 2);
%   hpVec = [firsthpObj sechpObj];
%   hpVec.getRelTol()
%
%   ans =
%
%      1.0e-05 *
%
%       1.0000    1.0000
%
%
%$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
%$Date: 2013-06$
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
%

[relTolArr, relTolVal] = hpArr.getProperty('relTol',varargin{:});