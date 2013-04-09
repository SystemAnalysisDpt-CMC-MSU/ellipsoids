function [absTolArr, absTolVal] = getAbsTol(hplaneArr, fAbsTolFun)
% GETABSTOL - gives the array of absTol for all elements in hplaneArr
%
% Input:
%   regular:
%       ellArr: hyperplane[nDim1, nDim2, ...] - multidimension array
%           of hyperplane
%   optional 
%       fAbsTolFun: function_handle[1,1] - function that apply 
%           to the absTolArr. The default is @min.
% 
% Output:
%   regular:
%       absTolArr: double [absTol1, absTol2, ...] - return absTol for 
%           each element in hplaneArr
%   optional:
%       absTol: double[1, 1] - return result of work fAbsTolFun with 
%           the absTolArr
%
% Usage:
%   use [~,absTol] = hplaneArr.getAbsTol() if you want get only
%       absTol,
%   use [absTolArr,absTol] = hplaneArr.getAbsTol() if you want get 
%       absTolArr and absTol,
%   use absTolArr = hplaneArr.getAbsTol() if you want get only absTolArr
% 
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $ 
% $Author: Grachev Artem  <grachev.art@gmail.com> $
%   $Date: March-2013$
% $Copyright: Moscow State University,
%            Faculty of Computational Arrhematics and Computer Science,
%            System Analysis Department 2013 $
%

if nargin == 1
    fAbsTolFun = @min;
end

absTolArr = arrayfun(@(x)x.absTol,hplaneArr);

if nargout == 2    
    absTolVal = fAbsTolFun(absTolArr);
end
    