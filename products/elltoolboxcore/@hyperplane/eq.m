function [isPosArr reportStr] = eq(fstHypArr, secHypArr)
%
% EQ - check if two hyperplanes are the same.
%
% Input:
%  regular:
%   fstHypArr:hyperplane[nDims1,nDims2,...]/hyperplane[1,1]
%            -first array of hyperplanes.
%   secHypArr:hyperplane[nDims1,nDims2,...]/hyperplane[1,1]
%            -second array of hyperplanes.
%
% Output:
%  isPosArr: logical[nDims1, nDims2, ...] - true -
%   if 
%   fstHypArr(iDim1,iDim2,...)==secHypArr(iDim1,iDim2,...),
%   false - otherwise. If size of fstHypArr is [1, 1], then 
%   checks if fstHypArr == secHypArr(iDim1, iDim2, ...)
%   for all iDim1, iDim2, ... , and vice versa.
%   reportStr: char[1,] - comparison report
%
%
% $Author: Vadim Kaushansky  <vkaushanskiy@gmail.com> $ 
% $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
% $Authors:
%   Peter Gagarinov  <pgagarinov@gmail.com> $ 
%   $Date: Dec-2012$
%   Aushkap Nikolay <n.aushkap@gmail.com> $ 
%   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012 $

import modgen.common.throwerror;
import modgen.struct.structcomparevec;
import elltool.conf.Properties;
%
hyperplane.checkIsMe(fstHypArr);
hyperplane.checkIsMe(secHypArr);
%
nFirstElems = numel(fstHypArr);
nSecElems = numel(secHypArr);

firstSizeVec = size(fstHypArr);
secSizeVec = size(secHypArr);
isnFirstScalar=nFirstElems > 1;
isnSecScalar=nSecElems > 1;
[~, relTol] = getAbsTol(fstHypArr);
%
SEll1Array=arrayfun(@formCompStruct,fstHypArr);
SEll2Array=arrayfun(@formCompStruct,secHypArr);
%
if isnFirstScalar&&isnSecScalar
    
    if ~isequal(firstSizeVec, secSizeVec)
        throwerror('wrongSizes',...
            'sizes of ellipsoidal arrays do not... match');
    end;
    compare();
    isPosArr = reshape(isPosArr, firstSizeVec);
elseif isnFirstScalar
    SEll2Array=repmat(SEll2Array, firstSizeVec);
    compare();
    
    isPosArr = reshape(isPosArr, firstSizeVec);
else
    SEll1Array=repmat(SEll1Array, secSizeVec);
    compare();
    isPosArr = reshape(isPosArr, secSizeVec);
end
    function compare()
        [isPosArr,reportStr]=modgen.struct.structcomparevec(SEll1Array,...
            SEll2Array,relTol);
    end
end

function SComp=formCompStruct(hypObj)

[hypNormVec, hypScal] = parameters(hypObj);

normMult = 1/norm(hypNormVec);
hypNormVec  = hypNormVec*normMult;
hypScal  = hypScal*normMult;
if hypScal < 0
    hypScal = -hypScal;
    hypNormVec = -hypNormVec;
end

SComp = struct('normal', hypNormVec, 'shift', hypScal);

end
