function isPosSemDef = ismatpossemdef( qMat, absTol)

minEig=min(eig(qMat));

isPosSemDef=false;
if (minEig>=0 || abs(minEig)<absTol)
    isPosSemDef=true;
end


