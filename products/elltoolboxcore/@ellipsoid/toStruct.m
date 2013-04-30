function SEllArr = toStruct(ellArr)
    SEllArr = arrayfun(@formCompStruct, ellArr);
end

function SComp = formCompStruct(ellObj)
    SComp = struct('Q',gras.la.sqrtmpos(ellObj.shape, ellObj.absTol),'q',ellObj.center.');
end