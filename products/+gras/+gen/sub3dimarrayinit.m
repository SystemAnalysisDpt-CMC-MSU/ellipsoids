function resArray = sub3dimarrayinit(lArray,rowsIndVec,colIndVec,valueArray)
resArray = lArray;
resArray(rowsIndVec,colIndVec,:) = valueArray;

