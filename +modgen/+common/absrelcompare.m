function [isEqual, absDiff, isRelDiffTriggered, relDiff, absMRelDiff, ...
    reportStr] = absrelcompare(leftArr, rightArr, absTol, relTol, fNormOp)
% ABSRELCOMPARE - compares two numerical arrays by user defined norm. For 
% each two corresponding fNormOp input elements from the leftArr (argL) and
% the rightArr (argR) the function calculates:
%
%   1) Absolute difference if:
%        fNormOp(argL - argR) <= absTol
%   or
%        fNormOp(argL) + fNormOp(argR) <= absTol.
%
%   The absolute difference is calculated as:
%        fNormOp(argL - argR)
%
%   2) Absolute and relative difference in other cases. The relative 
%   difference is calculated as:
%
%        2 * fNormOp(argL - argR) / (fNormOp(argL) + fNormOp(argR))
%
%   The maximum absolute difference for all elements is returned as
%   absDiff. If the relative difference has been calculated for some
%   elements, then the relative difference value for maximum element 
%   returns as relDiff, the maximum absolute difference for this element as 
%   absMRelDiff.
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
%                  normArr = fNormOp(inpArr)
%
%                       Input:
%                           inpArr: double[nElemsDim1,..., nElemsDimk] - an
%                                   input array.
%
%                       Output:
%                           normArr: double[..] - an output array with norm
%                                    for each element. The type of
%                                    element is specified by user (it can
%                                    be the vector, for example), so the 
%                                    numerical array normArr can have any 
%                                    size. The only condition is:
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
import modgen.common.throwerror;
%
FORMAT_SPEC='%.17g';
%
if ~(isequal(size(leftArr),size(rightArr))&&...
        isnumeric(leftArr)&&isnumeric(rightArr))
    throwerror('wrongInput:wrongArgs',['leftArr and rightArr must be ',...
        'numeric arrays with the same size']);
end
if ~(isnumeric(absTol)&&isscalar(absTol)&&(absTol>=0))
    throwerror('wrongInput:wrongAbsTol',['absTol', ...
        ' must be a nonnegative scalar']);
end
if ~(isempty(relTol)||(isscalar(relTol)&&(relTol>=0)))&&isnumeric(relTol)
    throwerror('wrongInput:wrongRelTol',['relTol', ...
        ' must be a nonnegative scalar']);
end
if ~modgen.common.type.simple.lib.isfunction(fNormOp)
    throwerror('wrongInput:wrongNormOp',['fNormOp must be ', ...
        'a function handle']);
end
%
diffArr = fNormOp(leftArr - rightArr);
absDiff = max(diffArr(:));
if isempty(absDiff)
    absDiff = [];
end
absRDiff = absDiff;
%
relDiff = [];
absMRelDiff = [];
%
isRelDiffTriggeredArr = (diffArr > absTol) & ~isempty(relTol);
isRelDiffTriggered = any(isRelDiffTriggeredArr(:));
if isRelDiffTriggered
    argSumNormArr = fNormOp(leftArr) + fNormOp(rightArr);
    isRelDiffTriggeredArr = isRelDiffTriggeredArr & ...
        (argSumNormArr > absTol);
    isRelDiffTriggered = any(isRelDiffTriggeredArr(:));
    if isRelDiffTriggered
        tempArr = zeros(size(diffArr));
        temp2Arr = tempArr;
        tempArr(isRelDiffTriggeredArr) = ...
            2 .* diffArr(isRelDiffTriggeredArr) ./ ...
            argSumNormArr(isRelDiffTriggeredArr);
        relDiff = max(tempArr(:));
        temp2Arr(tempArr == relDiff) = diffArr(tempArr == relDiff);
        absMRelDiff = max(temp2Arr(:));
        tempArr = zeros(size(diffArr));
        tempArr(~isRelDiffTriggeredArr) = diffArr(~isRelDiffTriggeredArr);
        absRDiff = max(tempArr(:));
    end
end
isEqual = all([absRDiff <= absTol, relDiff <= relTol]);
%
if nargout > 5
    if isEqual
        reportStr = '';
    else
        if isRelDiffTriggered
            reportStr = sprintf(strrep(['relative difference (FORMAT_SPEC) is greater', ...
                ' than the specified tolerance (FORMAT_SPEC); absolute', ...
                ' difference (FORMAT_SPEC), absolute tolerance (FORMAT_SPEC)'],...
                'FORMAT_SPEC',FORMAT_SPEC), relDiff, ...
                relTol, absMRelDiff, absTol);
        else
            reportStr = sprintf(strrep(['absolute difference (FORMAT_SPEC) is greater', ...
                ' than the specified tolerance (FORMAT_SPEC)'],...
                'FORMAT_SPEC',FORMAT_SPEC),...
                absDiff, absTol);
        end
    end
end