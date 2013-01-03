function spaceDimMat = dimension(myEllMat)

import elltool.conf.Properties;

[mRows, nCols] = size(myEllMat);
spaceDimMat = zeros(mRows, nCols);
ellDimMat = zeros(mRows, nCols);

for iRows = 1:mRows
    for jCols = 1:nCols
        spaceDimMat(iRows, jCols) = numel(myEllMat(iRows, jCols).getCenter());     
    end
end
