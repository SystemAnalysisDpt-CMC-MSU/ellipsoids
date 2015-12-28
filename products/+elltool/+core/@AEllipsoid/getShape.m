function outEllArr=getShape(ellArr,modMat)
%
% GETSHAPE -  does the same as SHAPE method: modifies the shape matrix 
%	of the AEllipsoid without changing its center, with only difference,  
%	that it doesn't modify input array of AEllipsoids, i.e. creates new.
%
% Input:
%	regular
%		ellArr: AEllipsoid [nDims1,nDims2,...,nDimsN] - array
%			of AEllipsoids.
%		modMat: double[nDim, nDim]/[1,1] - square matrix or scalar
%
% Output:
%	outEllArr: AEllipsoid [nDims1,nDims2,...,nDimsN] - array of modified
%		AEllipsoids.
%
% Example:
%	ellObj = GenEllipsoid([-2; -1], [4 -1; -1 1]);
%	tempMat = [0 1; -1 0];
%	outEllObj = ellObj.getShape(tempMat)
% 
% outEllObj = 
%
%		|    
%		|-- centerVec : [-2 -1]
%		|               -----
%		|------- QMat : |1|1|
%		|               |1|4|
%		|               -----
%		|               -----
%		|---- QInfMat : |0|0|
%		|               |0|0|
%		|               -----
%
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
checkIsMeVirtual(ellArr);
outEllArr=ellArr.getCopy();
outEllArr.shape(modMat);
end