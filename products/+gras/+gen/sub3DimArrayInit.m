function resArray = sub3DimArrayInit(lArray,rowsIndVec,colIndVec,valueArray)
    resArray = lArray;
    resArray(rowsIndVec,colIndVec,:) = valueArray;
end

