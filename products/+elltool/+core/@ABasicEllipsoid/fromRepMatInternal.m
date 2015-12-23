function ellArr=fromRepMatInternal(ellObj,sizeVec)
% FROMREPMAT - returns array of equal ABasicEllipsoids the same
% 		size as stated in sizeVec argument
% 
% ellArr = fromRepMat(sizeVec) - creates an array of size 
%   sizeVec of empty ellipsoids.
% 
% ellArr = fromRepMat(shMat,sizeVec) - creates an array of size 
%   sizeVec of ellipsoids with shape matrix shMat.
% 
% ellArr = fromRepMat(cVec,shMat,sizeVec) - creates an
%   array of size sizeVec of ellipsoids with shape 
%   matrix shMat and center cVec.
% 
% Input:
%   Case1:
%       regular: 
%           sizeVec: double[1,n] - vector of size, have 
%               integer values.
% 
%   Case2:
%       regular:
%           shMat: double[nDim, nDim] - shape matrix of 
%               ellipsoids. 
%           sizeVec: double[1,n] - vector of size, have 
%               integer values.
% 
%   Case3:
%       regular:
%           cVec: double[nDim,1] - center vector of 
%               ellipsoids
%           shMat: double[nDim, nDim] - shape matrix of 
%               ellipsoids. 
%           sizeVec: double[1,n] - vector of size, have 
%               integer values.
% 
% properties:
% 	absTol: double [1,1] - absolute tolerance with default
% 		value 10^(-7)
% 	relTol: double [1,1] - relative tolerance with default
% 		value 10^(-5)
% 	nPlot2dPoints: double [1,1] - number of points for 2D plot
% 		with default value 200
% 	nPlot3dPoints: double [1,1] - number of points for 3D plot
% 		with default value 200.
% Output:
%   ellArr: ellipsoid[] - created ellipsoidal array
%   
% $Author: <Zakharov Eugene>	<justenterrr@gmail.com> $ 
% $Date: <april> $
% $Copyright: Moscow State University,
% Faculty of Computational Mathematics and 
% Computer Science, System Analysis Department <2013> $
%
import modgen.common.checkvar;
if ~isa(sizeVec,'double')
	modgen.common.throwerror('wrongInput','Size array is not double');
end
sizeVec=gras.la.trytreatasreal(sizeVec);
checkvar(sizeVec,@(x)size(x,2)>1,'errorTag','wrongInput',...
    'errorMessage','size vector must have at least two elements')
checkvar(sizeVec,@(x)all(mod(x(:),1)==0)&&all(x(:)>0)...
    &&(size(x,1)==1),'errorTag','wrongInput', ...
    'errorMessage','size vector must contain positive integer values.');
%
nEllipsoids=prod(sizeVec);
ellArr(nEllipsoids)=ellObj.ellFactory();
% 
ell=ellObj;
arrayfun(@(x)makeEllipsoid(x),1:nEllipsoids);
ellArr=reshape(ellArr,sizeVec);
%
function makeEllipsoid(index)
	ellArr(index)=getCopy(ell);
end
end