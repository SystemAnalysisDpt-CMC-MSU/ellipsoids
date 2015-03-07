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
SFieldNiceNames = struct('diagMat', 'D', 'eigvMat', 'V', 'centerVec', 'q');
SFieldDescr = struct('diagMat', 'Diagonal matrix',...
    'eigvMat', 'Square matrix',...
    'centerVec', 'Ellipsoid center vector.');

if (isPropIncluded)
    SFieldNiceNames.absTol = 'absTol';
    SFieldNiceNames.relTol = 'relTol';
    SFieldNiceNames.nPlot2dPoints = 'nPlot2dPoints';
    SFieldNiceNames.nPlot3dPoints = 'nPlot3dPoints';
    SFieldNiceNames.diagMat = 'diagMat';
    SFieldNiceNames.eigvMat = 'eigvMat';
    
    SFieldDescr.absTol = 'Absolute tolerance.';
    SFieldDescr.relTol = 'Relative tolerance.';
    SFieldDescr.nPlot2dPoints = 'Degree of ellipsoid border smoothness in 2D plotting.';
    SFieldDescr.nPlot3dPoints = 'Degree of ellipsoid border smoothness in 3D plotting.';
    SFieldDescr.diagMat = 'Diagonal matrix or vector, may contain infinite or zero elements.';
    SFieldDescr.eigvMat = 'Square matrix.';
end

end

function SEll = ell2Struct(ellObj, isPropIncluded)
SEll = struct('diagMat', ellObj.diagMat, 'eigvMat', ellObj.eigvMat, 'centerVec', ellObj.centerVec);
if (isPropIncluded)
    SEll.absTol = ellObj.absTol;
    SEll.relTol = ellObj.relTol;
    SEll.nPlot2dPoints = ellObj.nPlot2dPoints;
    SEll.nPlot3dPoints = ellObj.nPlot3dPoints;
    SEll.diagMat = ellObj.diagMat;
    SEll.eigvMat = ellObj.eigvMat;
end
end