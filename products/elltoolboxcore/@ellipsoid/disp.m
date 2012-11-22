function disp(myEllMat)
%
%    DISP - Displays ellipsoid object.
%
% Input:
%   regular:
%       myEllMat: ellipsod [mRows, nCols] - matrix of ellipsoids.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

  fprintf('Ellipsoid with parameters\n');

  [mRows, nCols] = size(myEllMat);
  if (mRows > 1) || (nCols > 1)
    fprintf('%dx%d array of ellipsoids.\n\n', mRows, nCols);
  else
    fprintf('Center:\n'); disp(myEllMat.center);
    fprintf('Shape Matrix:\n'); disp(myEllMat.shape);
    if isempty(myEllMat)
        fprintf('Empty ellipsoid.\n\n');
    end
  end

end
