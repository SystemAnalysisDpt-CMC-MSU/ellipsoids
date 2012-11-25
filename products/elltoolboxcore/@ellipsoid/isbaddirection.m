function isBadDirVec = isbaddirection(minEll, subEll, dirsMat)
%
% ISBADDIRECTION - checks if ellipsoidal approximations of geometric difference
%                  of two ellipsoids can be computed for given directions.
%
%
% Description:
% ------------
%
%    RES = ISBADDIRECTION(E1, E2, L)  Checks if it is possible to build ellipsoidal
%                                     approximation of the geometric difference
%                                     of two ellipsoids E1 - E2 in directions
%                                     specified by matrix L (columns of L are
%                                     direction vectors).
%
%    Type 'help minkdiff_ea' or 'help minkdiff_ia' for more information.
%
%
% Output:
% -------
%
%    isBadDirVec - logical array with length being equal to the number of columns
%                  in matrix L.
%                  true marks direction vector as bad - ellipsoidal approximation cannot
%                  be computed for this direction.
%                  false means the opposite.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, MINKDIFF, MINKDIFF_EA, MINKDIFF_IA.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%    Rustam Guliev <glvrst@gmail.com>


  import modgen.common.throwwarn;
  %import elltool.conf.Properties;

  if ~isbigger(minEll, subEll)
    %if Properties.getIsVerbose() > 0
    %  fprintf('ISBADDIRECTION: geometric difference of these two ellipsoids is empty set.\n');
    %  fprintf('                All directions are bad.\n'); 
    %end
    throwwarn('wrongInput:emptyGeomDiff',...
        'ISBADDIRECTION: geometric difference of these two ellipsoids is empty set.\n');  
  end

  isBadDirVec=ellipsoid.isbaddirectionmat(minEll.shape, subEll.shape, dirsMat);


