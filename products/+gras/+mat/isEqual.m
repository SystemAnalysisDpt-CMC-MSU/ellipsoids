function [isEqualArr, reportStr] = isEqual(FirstArr, SecArr)

import modgen.common.throwerror;
import modgen.struct.structcomparevec;
import gras.la.sqrtmpos;


nFirstElems = numel(FirstArr);
nSecElems = numel(SecArr);

firstSizeVec = size(FirstArr);
secSizeVec = size(SecArr);
isnFirstScalar=nFirstElems > 1;
isnSecScalar=nSecElems > 1;

SEll1Array=FirstArr.toStruct();
SEll2Array=SecArr.toStruct();

if isnFirstScalar&&isnSecScalar
    
    if ~isequal(firstSizeVec, secSizeVec)
        throwerror('wrongSizes',...
            'sizes of ellipsoidal arrays do not... match');
    end;
    compare();
    isEqualArr = reshape(isEqualArr, firstSizeVec);
elseif isnFirstScalar
    
    SEll2Array=repmat(SEll2Array, firstSizeVec);
    compare();   
    isEqualArr = reshape(isEqualArr, firstSizeVec);
else
    
    SEll1Array=repmat(SEll1Array, secSizeVec);
    compare();
    isEqualArr = reshape(isEqualArr, secSizeVec);
end

    function compare()
        [isEqualArr,reportStr]=modgen.struct.structcomparevec(SEll1Array,...
            SEll2Array,relTol);
    end

end