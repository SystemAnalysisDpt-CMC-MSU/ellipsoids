function [compMat, isRelComparison] = absreldiff(arg1Arr, arg2Arr, ...
    absTol, normOpFun)
% ABSRELDIFF - returns the difference of two arrays by user defined norm.
% The function will return:
%
%   1) Absulute difference if:
%        normOpFun(arg1Arr - arg2Arr) < absTol
%   or
%        normOpFun(arg1Arr) + normOpFun(arg2Arr) < absTol.
%
%   2) Relative difference in other cases. The relative difference will be
%   calculated as:
%        2 * norm(arg1 - arg2) / (norm(arg1) + norm(arg2))
%
%
% Input:
%     regular:
%
%         arg1Arr, arg2Arr: double[nElemsDim1,..., nElemsDimk] - input
%                           arrays with the same size
%
%         absTol: double[1, 1] - maximum allowed absolute difference
%
%         normOpFun: function_handle[1, 1] - norm(x) operator handle
%
% Output:
%     regular:
%
%         compMat: double[...] - computed difference; the size will be the
%                  same as normOpFun(arg1Arr)
%
%     optional:
%
%         isRelComparison: logical[...] - is the calculated difference 
%                          value the relative one; the size will be the
%                          same as normOpFun(arg1Arr)
%
%
% $Authors: Yuri Admiralsky  <swige.ide@gmail.com> $	$Date: 2013-06$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $

import modgen.common.checkvar;
import modgen.common.checkmultvar;
%
checkmultvar('isequal(size(x1),size(x2))&&isnumeric(x1)&&isnumeric(x2)',...
    2, arg1Arr, arg2Arr, 'ErrorTag', 'wrongInput:wrongArgs', ...
    'ErrorMessage', ['arg1Mat and arg2Mat must be numeric arrays with', ...
    ' the same size']);
checkvar(absTol, 'isnumeric(x)&&isscalar(x)&&(x>=0)', 'errorTag', ...
    'wrongInput:wrongAbsTol', 'ErrorMessage', ['absTol must be a', ...
    ' nonnegative scalar']);
checkvar(normOpFun, 'isfunction(x)', 'errorTag', ...
    'wrongInput:wrongnormOpFun', 'ErrorMessage', ['normOpFun must be ', ...
    'a function handle']);
%
compMat = normOpFun(arg1Arr - arg2Arr);
isRelComparison = compMat > absTol;
if any(isRelComparison(:))
    argSumNormVec = normOpFun(arg1Arr) + normOpFun(arg2Arr);
    isRelComparison = isRelComparison & (argSumNormVec > absTol);
    if any(isRelComparison(:))
        compMat(isRelComparison) = 2 .* compMat(isRelComparison) ./ ...
            argSumNormVec(isRelComparison);
    end
end

