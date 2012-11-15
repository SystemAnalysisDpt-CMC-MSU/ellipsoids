function res = minAbsTol(ellMat)
[nRows, nCols] = size(ellMat);
absTolMat = zeros(nRows,nCols);
for iRows = 1:nRows
    for jCols = 1:nCols
        absTolMat(iRows,jCols) = ellMat(iRows,jCols).absTol;
    end
end
res = min(absTolMat(:));