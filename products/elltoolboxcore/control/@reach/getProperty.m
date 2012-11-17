function propValArr = getProperty(rsArray,propName)
%GETPROPERTY gives array the same size as rsArray with values of propName properties
%for each reach set in rsArr. Private method, used in every public
%property getter.
%
% Input:
%   regular:
%       rsArray:reach[nDims1, nDims2,...] - multidimension array of reach sets
%
% Output:
%   propValArr:double[nDims1, nDims2,...]- multidimension array of propName properties for
%                                   reach sets in rsArray
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Arrhematics and Computer Science,
%            System Analysis Department 2012 $
%
    import modgen.common.throwerror;
    propNameList = {'absTol','relTol','nPlot2dPoints','nPlot3dPoints','nTimeGridPoints'};
    if ~any(strcmp(propName,propNameList))
            throwerror('wrongInput',[propName,':no such property']);
    end
    propValArr=arrayfun(@(x)x.(propName),rsArray);
end