function resArray=customArray(varargin)
% CUSTOMARRAY creates an array of CubeStructFieldInfo objects
% based on the specified properties
%
% Input:
%   regular:
%      cubeStructRefList: CubeStruct[1,1]/cell[n1,n2,...,n_k] of CubeStruct
%      nameList: cell[n1,n2,...,n_k] of char
%   optional:
%      descrList: cell[n1,n2,...,n_k] of char
%      typeSpecList: cell[n1,n2,...,n_k] of cell[1,nTypeDefDepth_i] of char
%
% Output:
%   resArray: CubeStructFieldInfo[n1,n2,...,n_k]
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
inpArgList=feval([mfilename('class') '.processCustomArrayArgList'],varargin{:});
resArray=feval(mfilename('class'),inpArgList{:});