function res = getAbsTol(ellMat)
[nRows, nCols] = size(ellMat);
res = zeros(nRows,nCols);
for iRows = 1:nRows
    for jCols = 1:nCols
        res(iRows,jCols) = ellMat(iRows,jCols).absTol;
    end
end