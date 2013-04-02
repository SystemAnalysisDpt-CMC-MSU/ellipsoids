function [aMat,qArray] = ellArrayParameters(qEllArray)
if (isempty(qEllArray))
    aMat = [];
    qArray = [];
    return;
end
nPoints = length(qEllArray);
nDims = size(parameters(qEllArray(1)), 1);
qArray = zeros(nDims, nDims, nPoints);
aMat = zeros(nDims, nPoints);
arrayfun(@(iPoint)fCalcAMatAndQArray(iPoint), 1:nPoints);
    function fCalcAMatAndQArray(iPoint)
        [aMat(:, iPoint), qArray(:,:,iPoint)] =...
            parameters(qEllArray(iPoint));
    end
end