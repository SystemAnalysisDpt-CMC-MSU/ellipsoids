function trArr=trace(ellArr)
%
% TRACE - returns the trace of the GenEllipsoid.
%
%	trArr = TRACE(ellArr)  Computes the trace of GenEllipsoids in
%		ellipsoidal array ellArr.
%
% Input:
%	regular:
%		ellArr: GenEllipsoid [nDims1,nDims2,...,nDimsN] - array
%			of GenEllipsoids.
%
% Output:
%	trArr: double [nDims1,nDims2,...,nDimsN] - array of trace values, 
%		same size as ellArr.
%
%       
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
elltool.core.GenEllipsoid.checkIsMe(ellArr);
trArr=zeros(size(ellArr));
for iElem=1:numel(ellArr)
    trArr(iElem)=trace@elltool.core.AEllipsoid(ellArr(iElem));
    if isnan(trArr(iElem))
        trArr(iElem)=Inf;
    end
end
end