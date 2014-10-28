function resArray=customArray(varargin)
% CUSTOMARRAY creates an array of CubeStructFieldExtendedInfo objects
% based on the specified properties
%
% Input:
%   regular:
%      cubeStructRefList: CubeStruct[1,1]/cell[n1,n2,...,n_k] of CubeStruct
%      nameList: cell[n1,n2,...,n_k] of char
%   optional:
%      descrList: cell[n1,n2,...,n_k] of char
%      typeSpecList: cell[n1,n2,...,n_k] of cell[1,nTypeDefDepth_i] of char
%      sizePatternVecList: cell[n1,n2,...,n_k] of double[1,nDims_i]
%      isSizeAlongAddDimsEqualOneMat: logical[n1,n2,...,n_k]
%      isUniqueValuesMat: logical[n1,n2,...,n_k]
%
% Output:
%   resArray: CubeStructFieldExtendedInfo[n1,n2,...,n_k]
%
%
% $Author: Ilya Roublev  <iroublev@gmail.com> $	$Date: 2014-07-10 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2014 $
%
%
inpArgList=feval([mfilename('class') '.processCustomArrayArgList'],varargin{:});
resArray=feval(mfilename('class'),inpArgList{:});