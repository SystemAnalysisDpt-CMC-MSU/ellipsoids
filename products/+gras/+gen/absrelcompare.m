function [isEqual, absDiff, isRelDiffTriggered, relDiff, absMRelDiff, ...
    reportStr] = absrelcompare(leftArr, rightArr, absTol, relTol, fNormOp)
% ABSRELCOMPARE - compares two numerical arrays by user 
% defined norm. For each two corresponding fNormOp input elements from
% the leftArr (argL) and the rightArr (argR) the function calculates:
%
%   1) Absolute difference if:
%        fNormOpFun(argL - argR) <= absTol
%   or
%        fNormOpFun(argL) + fNormOpFun(argR) <= absTol.
%
%   The absolute difference is calculated as:
%        fNormOpFun(argL - argR)
%
%   2) Absolute and relative difference in other cases. The relative difference is
%   calculated as:
%        2*fNormOpFun(argL - argR) / (fNormOpFun(argL) + fNormOpFun(argR))
%
%   The maximum absolute difference for all elements is returned as
%   absDiff. If the relative difference has been calculated for some
%   elements, then the relative difference value for maximum element 
%   returns as relDiff, the maximum absolute difference for this element as 
%   absMRelDiff. The matrix with absolute or relative (where it has been 
%   calculated) returns as diffMat, the elements where relative precisions 
%   as isRelDiffTriggeredMat.
%
%
% Input:
%     regular:
%
%         leftArr, rightArr: double[nElemsDim1,..., nElemsDimk] - input
%                            arrays with the same size.
%
%         absTol: double[1, 1] - the absolute difference calculation
%                 threshold for the algorithm. If relTol is empty, the
%                 absTol is the maximum allowed absolute tolerance.
%
%         relTol: double[1, 1] - the maximum allowed relative tolerance. If
%                 it is empty, then relative precision isn't calculated.        
%
%         fNormOp: function_handle[1, 1] - norm(x) operator handle. The
%                  function must have the format:
%
%                  normMat = fNormOp(inpArr)
%
%                       Input:
%                           inpArr: double[nElemsDim1,..., nElemsDimk] - an
%                                   input array.
%
%                       Output:
%                           normMat: double[..] - output matrix with norm
%                                    for each element. The the type of
%                                    element is specified by user (it can
%                                    be the vector, for example). The only
%                                    condition is:
%
%                                       size(fNormOp(inp1Arr)) == ...
%                                           size(fNormOp(inp2Arr)),
%
%                                    for all inp1Arr and inp2Arr with the
%                                    same size.
%
% Output:
%
%         isEqual: logical[1, 1] - are two input arrays equal with defined
%                  tolerances.
%
%         absDiff: double[1, 1] - the maximum absolute difference (from all
%                  elements).
%
%         isRelDiffTriggered: logical[1, 1] - has the relative comparison
%                             been used.
%
%         relDiff: double[1, 1] - the maximum relative difference (from all
%                  elements for which it was calculated). If the relative
%                  comparison hasn't been used, it is empty.
%
%         absMRelDiff: double[1, 1] - the absolute difference for the
%                      element with maximum relative difference value. If
%                      there are more elemets than one with the same
%                      relative difference value, then the maximum absolute
%                      difference value among them is returned. If the
%                      relative comparison hasn't been used, it is empty.
%
%         reportStr: char[1,..] standart error report or empty string if no
%                    error has occured.
%
% Example:
%     If you want to compare only absolute difference with absTol, you can
%     use:
%
%         [isEqual, absDiff] = absrelcompare(aArr, bArr, absTol, [], @abs)
%
%     If you want to compare only relative difference with relTol, you can
%     use:
%
%         [isEqual, ~, ~, relDiff] = ...
%               absrelcompare(aArr, bArr, Inf, relTol, @abs)
%
%     You also can compare relative difference between two vectors norm:
%
%         [isEqual, ~, ~, relDiff] = ...
%               absrelcompare(aVec, bVec, Inf, relTol, @norm)         
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
    2, leftArr, rightArr, 'ErrorTag', 'wrongInput:wrongArgs', ...
    'ErrorMessage', ['arg1Mat and arg2Mat must be numeric arrays with', ...
    ' the same size']);
checkvar(absTol, 'isnumeric(x)&&isscalar(x)&&(x>=0)', 'errorTag', ...
    'wrongInput:wrongAbsTol', 'ErrorMessage', ['relTol', ...
    ' must be a nonnegative scalar']);
checkvar(relTol, '(isempty(x)||(isscalar(x)&&(x>=0)))&&isnumeric(x)', ...
    'errorTag', 'wrongInput:wrongRelTol', 'ErrorMessage', ['relTol', ...
    ' must be a nonnegative scalar or empty']);
checkvar(fNormOp, 'isfunction(x)', 'errorTag', ...
    'wrongInput:wrongNormOp', 'ErrorMessage', ['fNormOp must be ', ...
    'a function handle']);
%
diffMat = fNormOp(leftArr - rightArr);
absDiff = max(diffMat(:));
if isempty(absDiff)
    absDiff = [];
end
absRDiff = absDiff;
%
relDiff = [];
absMRelDiff = [];
%
isRelDiffTriggeredMat = (diffMat > absTol) & ~isempty(relTol);
isRelDiffTriggered = any(isRelDiffTriggeredMat(:));
if isRelDiffTriggered
    argSumNormVec = fNormOp(leftArr) + fNormOp(rightArr);
    isRelDiffTriggeredMat = isRelDiffTriggeredMat & ...
        (argSumNormVec > absTol);
    isRelDiffTriggered = any(isRelDiffTriggeredMat(:));
    if isRelDiffTriggered
        tempMat = zeros(size(diffMat));
        temp2Mat = tempMat;
        tempMat(isRelDiffTriggeredMat) = ...
            2 .* diffMat(isRelDiffTriggeredMat) ./ ...
            argSumNormVec(isRelDiffTriggeredMat);
        relDiff = max(tempMat(:));
        temp2Mat(tempMat == relDiff) = diffMat(tempMat == relDiff);
        absMRelDiff = max(temp2Mat(:));
        tempMat = zeros(size(diffMat));
        tempMat(~isRelDiffTriggeredMat) = diffMat(~isRelDiffTriggeredMat);
        absRDiff = max(tempMat(:));
    end
end
isEqual = all([absRDiff <= absTol, relDiff <= relTol]);
%
if nargout > 5
    if isEqual
        reportStr = '';
    else
        if isRelDiffTriggered
            reportStr = sprintf(['relative error (%g) is greater than', ...
                ' the specified tolerance (%g); absolute difference', ...
                ' (%g), absolute tolerance (%g)'], relDiff, relTol, ...
                absMRelDiff, absTol);
        else
            reportStr = sprintf(['absolute error (%g) is greater than', ...
                ' the specified tolerance (%g)'], absDiff, absTol);
        end
    end
end