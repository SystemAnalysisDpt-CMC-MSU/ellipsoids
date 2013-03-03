function lsys = get_system(rs)
%
% GET_SYSTEM - returns the linear system for which the reach set is computed.
%
%
% Description:
% ------------
%
%  LSYS = GET_SYSTEM(RS)  Returns linear system, for which the reach set is
%                         computed.
%
%
% Output:
% -------
%
%  LSYS - linear system object.
%
%
% See also:
% ---------
%
%    REACH/REACH.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;

  if ~(isa(rs, 'reach'))
    error('GET_SYSTEM: input argument must be an reach set object.');
  end

  lsys = rs(1, 1).system;
  
  return;
