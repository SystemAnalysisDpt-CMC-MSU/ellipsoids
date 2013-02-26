function isPosDef = ismatposdef( qMat, absTol)

minEig=min(eig(qMat));

isPosDef=false;
if (minEig>absTol)
    isPosDef=true;
end


