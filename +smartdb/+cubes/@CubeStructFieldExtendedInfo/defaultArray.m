function resArray=defaultArray(cubeStructRefList,sizeVec)
% DEFAULTARRAY creates an array of CubeStructFieldInfo objects
% of a specified size filled with the default values
%
% Input:
%   regular:
%       cubeStructRefList: CubeStruct/cell [n1,n2,...,n_k] of CubeStruct
%
%   optional:
%       sizeVec: numeric[1,nDims] - size vector = [n1,n2,...,n_k]
%
% Output:
%   resObj: CubeStructFieldExtendedInfo[n1,n2,...,n_k] - constructed
%      object of the requested size filled with the default values
%
%
% $Author: Ilya Roublev  <iroublev@gmail.com> $	$Date: 2014-07-10 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2014 $
%
%
if iscell(cubeStructRefList)&&nargin==1
    sizeVec=size(cubeStructRefList);
end
cubeStructRefList=smartdb.cubes.CubeStructFieldInfo.processCubeStructRefList(...
    sizeVec,cubeStructRefList);
nElem=prod(sizeVec);
%
if nElem>0
    resArray=smartdb.cubes.CubeStructFieldExtendedInfo(cubeStructRefList);
else
    resArray=smartdb.cubes.CubeStructFieldExtendedInfo.empty(sizeVec);
end