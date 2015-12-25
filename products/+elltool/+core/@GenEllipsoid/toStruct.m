function [SDataArr,SFieldNiceNames,SFieldDescr,SFieldTransformFunc] = ...
    toStruct(ellArr,isPropIncluded,absTol) %#ok<INUSD>
% toStruct -- converts GenEllipsoid array into structural array.
%
% Input:
%   regular:
%       ellArr: GenEllipsoid [nDim1, nDim2, ...] - array
%           of GenEllipsoids.
%       isPropIncluded: logical[1,1] - if true, then properties also 
%           adds to struct
% Output:
%   SDataArr: struct[nDims1,...,nDimsk] - structure array same size, as
%       ellArr, contain all data.
%   SFieldNiceNames: struct[1,1] - structure with the same fields as 
%       SDataArr. Field values contain the nice names.
%   SFieldDescr: struct[1,1] - structure with same fields as SDataArr,
%       values contain field descriptions.
%
%       q:      double[1, nEllDim] - the center of ellipsoid
%       Q:      double[nEllDim, nEllDim] - the shape matrix of ellipsoid
%       QInf:   double[nEllDim, nEllDim] - the matrix of infinity values of
%           GenEllipsoid
%
% Example:
%   
%   ellObj = elltool.core.GenEllipsoid([5;2], eye(2), [1 3; 4 5]);
%   
%   [Data, NiceNames, Descr] = ellObj.toStruct()
% 
%   Data = 
% 
%          QMat: [2x2 double]
%     centerVec: [2x1 double]
%       QInfMat: [2x2 double]
% 
% 
%   NiceNames = 
% 
%          QMat: 'Q'
%     centerVec: 'q'
%       QInfMat: 'QInf'
% 
% 
%   Descr = 
% 
%          QMat: 'GenEllipsoid "shape" matrix.'
%     centerVec: 'GenEllipsoid center vector.'
%       QInfMat: 'GenEllipsoid matrix of infinity values'
%
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com>
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
% 
if nargin<3
    absTol=ellArr.getAbsTol();
end
if nargin<2
    isPropIncluded=false;
end
%
SDataArr=arrayfun(@(ellObj)ell2Struct(ellObj,isPropIncluded),ellArr);
SFieldNiceNames=struct('QMat','QSqrt','centerVec','q','QInfMat','QInfSqrt');
SFieldTransformFunc=struct('QMat',@(x)fTransform(x,absTol),...
    'centerVec',@(x)x,'QInfMat',@(x)fTransform(x,absTol));
SFieldDescr=struct('QMat','GenEllipsoid "shape" matrix',...
    'centerVec','GenEllipsoid center vector','QInfMat',...
    'GenEllipsoid matrix of infinity values');
if isPropIncluded
    SFieldNiceNames.absTol='absTol';
    SFieldDescr.absTol='Tolerance of GenEllipsoid';
end
if isempty(SDataArr)
    SDataArr=struct('QMat',[],'centerVec',[],'QInfMat',[]);
end
end
%
function SComp=ell2Struct(ellObj,isPropIncluded)
diagMat=ellObj.diagMat;
if isempty(diagMat)
    qMat=[];
    qInfMat=[];
    centerVec=[];
else
    eigvMat=ellObj.eigvMat;
    centerVec=ellObj.centerVec;
    diagMat=ellObj.diagMat;
    diagVec=diag(diagMat);
    isnInfVec=diagVec~=Inf;
    eigvFinMat=eigvMat(:,isnInfVec);
    qMat=eigvFinMat*diag(diagVec(isnInfVec))*eigvFinMat.';
    isInfVec=~isnInfVec;
    eigvInfMat=eigvMat(:,isInfVec);
    qInfMat=eigvInfMat*eigvInfMat.';
end
SComp=struct('QMat',qMat,'centerVec',centerVec,'QInfMat',qInfMat);
if isPropIncluded
    SComp.absTol=ellObj.getAbsTol();
end
end

function resMat=fTransform(inpMat,absTol)
if any(eig(inpMat)<=0)
    resMat=inpMat;
else
    resMat=gras.la.sqrtmpos(inpMat,absTol);
end
end
