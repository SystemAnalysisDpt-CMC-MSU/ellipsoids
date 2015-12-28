function outEllArr=plus(varargin)
%
% PLUS - overloaded operator '+'
%
%	outEllArr=PLUS(inpEllArr,inpVec) implements E+b
%		for each AEllipsoid E in inpEllArr.
%	outEllArr=PLUS(inpVec,inpEllArr) implements b+E
%		for each AEllipsoid E in inpEllArr.
%
%	Operation E+b (or b+E) where E=inpEll is an AEllipsoid in R^n,
%	and b=inpVec - vector in R^n. If E(q) is an AEllipsoid
%	with center q,then
%	E(q)+b=b+E(q)=E(q+b).
%
% Input:
%	regular:
%		ellArr: AEllipsoid [nDims1,nDims2,...,nDimsN] - array of 
%			AEllipsoids of the same dimentions nDims.
%		bVec: double[nDims,1] - vector.
%
% Output:
%	outEllArr: AEllipsoid [nDims1,nDims2,...,nDimsN] - array of 
%		AEllipsoids with same shapes as ellArr,but with centers shifted 
%		by vectors in bVec.
%
% Example:
%	ellObj1=elltool.core.GenEllipsoid([5;2],eye(2),[1 3; 4 5]);
%	ellObj2=elltool.core.GenEllipsoid([-1;-1],[5 3; 3 10]);
%	ellVec=[ellObj1,ellObj2];
%	outEllVec=ellVec+[1; 1]
% 
%	outEllVec =
% 
%	Structure(1,1)
%	|
%	|----- q : [6 3]
%	|          -------
%	|----- Q : |10|19|
%	|          |19|41|
%	|          -------
%	|          -----
%	|-- QInf : |0|0|
%	|          |0|0|
%	|          -----
%	O
%
%	Structure(2,1)
%	|
%	|----- q : [0 0]
%	|          -------
%	|----- Q : |5 |3 |
%	|          |3 |10|
%	|          -------
%	|          -----
%	|-- QInf : |0|0|
%	|          |0|0|
%	|          -----
%	O
%
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
import modgen.common.throwerror;
import modgen.common.checkvar;
import modgen.common.checkmultvar;
errMsg =...
'this operation is only permitted between AEllipsoid and vector in R^n.';
checkvar(nargin,'x==2','errorTag','wrongInput',...
	'errorMessage',errMsg)
if isa(varargin{2},'double')
    checkIsMeVirtual(varargin{1});
	inpEllArr=varargin{1};
	inpVec=varargin{2};
elseif isa(varargin{1},'double')
    checkIsMeVirtual(varargin{2})
	inpEllArr=varargin{2};
	inpVec=varargin{1};
else
	throwerror('wrongInput',errMsg);
end
sizeCVec=num2cell(size(inpEllArr));
if isempty(inpEllArr)
	outEllArr=feval(class(inpEllArr));
    outEllArr=outEllArr.empty(sizeCVec{:});
else    
	dimArr=dimension(inpEllArr);
	checkmultvar('iscolumn(x1)&&all(x2(:)==length(x1))',2,inpVec,dimArr,...
		'errorTag','wrongInput','errorMessage','dimensions mismatch');
	outEllArr(sizeCVec{:})=feval(class(inpEllArr));
	arrayfun(@(x) fSinglePlus(x),1:numel(inpEllArr));
end        
	function fSinglePlus(index)
		outEllArr(index)=getCopy(inpEllArr(index));
        outEllArr(index).centerVec=outEllArr(index).centerVec+inpVec;
	end
end
