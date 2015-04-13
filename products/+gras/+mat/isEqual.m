function [isEqualArr, reportStr] = isEqual(FirstObj, SecObj)

import modgen.common.throwerror;
import modgen.struct.structcomparevec;
import gras.la.sqrtmpos;

nFirstElems = numel(FirstObj);
nSecElems = numel(SecObj);

firstSizeVec = size(FirstObj);
secSizeVec = size(SecObj);
isnFirstScalar = nFirstElems > 1;
isnSecScalar = nSecElems > 1;

SEll1Array = FirstObj.toStructInternal(); % add param 'true' for absTol and relTol
SEll2Array = SecObj.toStructInternal(); % add param 'true' for absTol and relTol

if isnFirstScalar&&isnSecScalar
    
    if ~isequal(firstSizeVec, secSizeVec)
        throwerror('errorinSizes',...
            'sizes do not match');
    end;
    compare();
elseif isnFirstScalar
    
    SEll2Array = repmat(SEll2Array, firstSizeVec);
    compare();   
else
    
    SEll1Array = repmat(SEll1Array, secSizeVec);
    compare();
end

    function compare()
        [isEqualArr,reportStr] = modgen.struct.structcomparevec(SEll1Array,...
            SEll2Array);
    end

end