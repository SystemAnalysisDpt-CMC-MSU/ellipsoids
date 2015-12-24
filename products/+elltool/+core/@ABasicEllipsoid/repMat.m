function ellArr=repMat(ellObj,sizeVec)
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
ellArr(nEllipsoids)=feval(class(ellObj));
% 
ell=ellObj;
arrayfun(@(x)makeEllipsoid(x),1:nEllipsoids);
ellArr=reshape(ellArr,sizeVec);
%
function makeEllipsoid(index)
	ellArr(index)=getCopy(ell);
end
end