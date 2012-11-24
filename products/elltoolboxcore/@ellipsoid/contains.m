function resMat = contains(firstEllMat, secondEllMat)
% CONTAINS - checks if one ellipsoid contains the other.
%            The condition for E1 to contain E2 is 
%            min(rho(l | E1) - rho(l | E2)) > 0,
%            subject to <l, l> = 1.
%
% Input:
%   regular:
%       firstEllMat: ellipsoid [mRows, nCols] - first matrix of ellipsoids.
%       secondEllMat: ellipsoid [mRows, nCols] - second matrix
%           of ellipsoids.
%
% Output:
%   resMat: double[mRows, nCols],
%       resMat(iRows, jCols) = 1 - firstEllMat(iRows, jCols)
%       contains secondEllMat(iRows, jCols), 0 - otherwise.
%
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

  import elltool.conf.Properties;
  import modgen.common.throwerror;
  
  if ~(isa(firstEllMat, 'ellipsoid')) || ~(isa(secondEllMat, 'ellipsoid'))
    throwerror('wrongInput', ...
        'CONTAINS: input arguments must be ellipsoids.');
  end

  [mRowsFirst, nColsFirst] = size(firstEllMat);
  [mRowsSecond, nColsSecond] = size(secondEllMat);
  nSizeFirst = mRowsFirst * nColsFirst;
  nSizeSecond = mRowsSecond * nColsSecond;
  if (nSizeFirst > 1) && (nSizeSecond > 1) && ...
          ((mRowsFirst ~= mRowsSecond) || (nColsFirst ~= nColsSecond))
    throwerror('wrongInput', ...
        'CONTAINS: sizes of ellipsoidal arrays do not match.');
  end

  dimFirst = dimension(firstEllMat);
  dimSecond = dimension(secondEllMat);
  minDimFirst   = min(min(dimFirst));
  minDimSecond   = min(min(dimSecond));
  maxDimFirst   = max(max(dimFirst));
  maxDimSecond   = max(max(dimSecond));
  if (minDimFirst ~= maxDimFirst) || (minDimSecond ~= maxDimSecond) ...
          || (minDimFirst ~= minDimSecond)
    throwerror('wrongSizes', ...
        'CONTAINS: ellipsoids must be of the same dimension.');
  end

  if Properties.getIsVerbose()
    if (nSizeFirst > 1) || (nSizeSecond > 1)
      fprintf('Checking %d ellipsoid-in-ellipsoid containments...\n',...
          max([nSizeFirst nSizeSecond]));
    else
      fprintf('Checking ellipsoid-in-ellipsoid containment...\n');
    end
  end

  resMat = [];
  if (nSizeFirst > 1) && (nSizeSecond > 1)
    for iRowsFirst = 1:mRowsFirst
      resPart = [];
      for jColsFirst = 1:nColsFirst
        resPart = [resPart l_check_containment(firstEllMat(iRowsFirst, ...
            jColsFirst), secondEllMat(iRowsFirst, jColsFirst))];
      end
      resMat = [resMat; resPart];
    end
  elseif (nSizeFirst > 1)
    for iRowsFirst = 1:mRowsFirst
      resPart = [];
      for jColsFirst = 1:nColsFirst
        resPart = [resPart l_check_containment(firstEllMat(iRowsFirst, ...
            jColsFirst), secondEllMat)];
      end
      resMat = [resMat; resPart];
    end
  else
    for iRowsSecond = 1:mRowsSecond
      resPart = [];
      for jColsSecond = 1:nColsSecond
        resPart = [resPart l_check_containment(firstEllMat, ...
            secondEllMat(iRowsSecond, jColsSecond))];
      end
      resMat = [resMat; resPart];
    end
  end

end




%%%%%%%%

function res = l_check_containment(firstEll, secondEll)
%
% L_CHECK_CONTAINMENT - check if secondEll is inside firstEll.
%
% Input:
%   regular:
%       firstEll: ellipsoid [1, nCols] - first ellipsoid.
%       secondEll: ellipsoid [1, nCols] - second ellipsoid.
%
% Output:
%   res: double[1,1], 1 - secondEll is inside firstEll, 0 - otherwise.
%
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

  import elltool.conf.Properties;
  import modgen.common.throwerror;
  
  [fstEllCentVec, fstEllShMat] = double(firstEll);
  [secEllCentVec, secEllShMat] = double(secondEll);
  if size(fstEllShMat, 2) > rank(fstEllShMat)
      fstEllShMat = ellipsoid.regularize(fstEllShMat,firstEll.absTol);
  end
  if size(secEllShMat, 2) > rank(secEllShMat)
      secEllShMat = ellipsoid.regularize(secEllShMat,secondEll.absTol);
  end
  
  invFstEllShMat = ell_inv(fstEllShMat);
  invSecEllShMat = ell_inv(secEllShMat);
  
  AMat = [invFstEllShMat -invFstEllShMat*fstEllCentVec;...
      (-invFstEllShMat*fstEllCentVec)' ...
      (fstEllCentVec'*invFstEllShMat*fstEllCentVec-1)];
  BMat = [invSecEllShMat -invSecEllShMat*secEllCentVec;...
      (-invSecEllShMat*secEllCentVec)'...
      (secEllCentVec'*invSecEllShMat*secEllCentVec-1)];

  AMat = 0.5*(AMat + AMat');
  BMat = 0.5*(BMat + BMat');
  if Properties.getIsVerbose()
    fprintf('Invoking CVX...\n');
  end
  cvx_begin sdp
    variable cvxxVec(1, 1)
    AMat <= cvxxVec*BMat
    cvxxVec >= 0
  cvx_end

  if strcmp(cvx_status,'Failed')
    throwerror('cvxError','Cvx failed');
  end;
  if strcmp(cvx_status,'Solved') ...
          || strcmp(cvx_status, 'Inaccurate/Solved')
    res = 1;
  else
    res = 0;
  end
end
