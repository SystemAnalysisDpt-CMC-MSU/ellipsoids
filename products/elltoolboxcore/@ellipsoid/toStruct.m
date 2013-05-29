function [SDataArr, SFieldNiceNames, SFieldDescr] = ...
                             toStruct(ellArr, isPropIncluded)
% toStruct -- converts ellipsoid array into structural array.
%
% Input:
%   regular:
%       ellArr: ellipsoid [nDim1, nDim2, ...] - array
%           of ellipsoids.
% Output:
%   SDataArr: struct[nDims1,...,nDimsk] - structure array same size, as
%       ellArr, contain all data.
%   SFieldNiceNames: struct[1,1] - structure with the same fields as SDataArr. Field values
%       contain the nice names.
%   SFieldDescr: struct[1,1] - structure with same fields as SDataArr, 
%       values contain field descriptions.
%         
%       q: double[1, nEllDim] - the center of ellipsoid
%       Q: double[nEllDim, nEllDim] - the shape matrix of ellipsoid  
%
% Example:
%   ellObj = ellipsoid([1 1]', eye(2));
%   ellObj.toStruct()
% 
%   ans = 
% 
%   Q: [2x2 double]
%   q: [1 1]
% 
% $Author: Alexander Karev <Alexander.Karev.30@gmail.com>
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2013 $
    if (nargin < 2)
        isPropIncluded = false;
    end
    SDataArr = arrayfun(@(ellObj)ell2Struct(ellObj, isPropIncluded), ellArr);
    if (isPropIncluded) 
        SFieldNiceNames = struct('Q', 'shapeMat', 'a', 'centerVec',...
                      'absTol', 'absTol', 'relTol', 'relTol', ...
                      'nPlot2dPoints', 'nPlot2dPoints', ...
                      'nPlot3dPoints', 'nPlot3dPoints');
        SFieldDescr = struct('Q', 'Ellipsoid shape matrix.',...
                             'a', 'Ellipsoid center vector.',...
                             'absTol', 'Absolute tolerance.',...
                             'relTol', 'Relative tolerance.',...
                             'nPlot2dPoints', 'Degree of ellipsoid border smoothness in 2D plotting.',...
                             'nPlot3dPoints', 'Degree of ellipsoid border smoothness in 3D plotting.');
                             
    else
        SFieldNiceNames = struct('Q', 'Q', 'a', 'a');
        SFieldDescr = struct('Q', 'Ellipsoid shape matrix.',...
                             'a', 'Ellipsoid center vector.');
    end
end

function SEll = ell2Struct(ellObj, isPropIncluded)
    if (isPropIncluded)
        SEll = struct('Q', ellObj.shapeMat, 'a', ellObj.centerVec.',...
                      'absTol', ellObj.absTol, 'relTol', ellObj.relTol, ...
                      'nPlot2dPoints', ellObj.nPlot2dPoints, ...
                      'nPlot3dPoints', ellObj.nPlot3dPoints);
    else
        SEll = struct('Q', ellObj.shapeMat, 'a', ellObj.centerVec.');
    end
end