function propValArr = getProperty(ellArr,propName)
%
% GETPROPERTY - gives array the same size as ellArr with 
%               values of propName properties for each 
%               ellipsoid in ellArr. Private method, used
%               in every public property getter.
%
% Input:
%  regular:
%    ellArr: ellipsoid[nDim1, nDim2,...] - multidimensional
%            array of ellipsoids
%
% Output:
%   propValArr: double[nDim1, nDim2,...] - multidimension
%     array of propName properties for ellipsoids in ellArr
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $
%$Date: 17-november-2012$
%$Copyright: Moscow State University,
%            Faculty of Computational Arrhematics
%            and Computer Science,
%            System Analysis Department 2012 $
%
import modgen.common.throwerror;
propNameList = {'absTol','relTol','nPlot2dPoints','nPlot3dPoints',...
    'nTimeGridPoints'};
if ~any(strcmp(propName,propNameList))
    throwerror('wrongInput',[propName,':no such property']);
end
%
propValArr= arrayfun(@(x)x.(propName),ellArr);
end
