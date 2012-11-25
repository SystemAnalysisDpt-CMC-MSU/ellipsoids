function res = isempty(E)
%
% ISEMPTY - checks if the ellipsoid object is empty.
%
%
% Description:
% ------------
%
%    RES = ISEMPTY(E)  Given ellipsoidal array E, returns array of ones and zeros
%                      specifying which ellipsoids in the array are empty.
%
%
% Output:
% -------
%
%    true - if ellipsoid is empty, false - otherwise.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;


  if ~(isa(E, 'ellipsoid'))
    error('ISEMPTY: input argument must be ellipsoid.');
  end

  res = ~dimension(E);

end
