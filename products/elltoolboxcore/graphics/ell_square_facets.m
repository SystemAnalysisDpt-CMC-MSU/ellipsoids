function facets = ell_square_facets(epoints_num, points_num)
%
% ELL_SQUARE_FACETS - generates square facets to be used
%                     in PATCH function call.
%
%
% Description:
% ------------
%
%    ELL_SQUARE_FACETS(M, N)  Generates square facets for
%              the PATCH call.
%
%
% Output:
% -------
%
%    Array of facets.
%
%
% See also:
% ---------
%
%    PATCH, CONVHULLN.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  td         = 1:1:(points_num);
  I          = transpose(1:1:(epoints_num-1));
  adtime     = transpose(td(1:(end-1)));
  ttime_data = adtime*epoints_num;
  adtime     = (adtime.'-1)*epoints_num;
  adtime     = adtime(ones(1, epoints_num-1), :);
  Ie         = I(:, ones(1, points_num-1)) + adtime;
  Ie         = Ie(:);

  part1_facet_data = [Ie,Ie+1, Ie+1+epoints_num, Ie+epoints_num];
  part2_facet_data = [ttime_data, ...
                      ttime_data+1-epoints_num, ...
                      ttime_data+1, ...
                      ttime_data+epoints_num];
  facets           = zeros((points_num-1)*epoints_num, 4);

  for d = 1:1:4
    facets(:, d) = [part1_facet_data(:, d); part2_facet_data(:, d)];
  end

  return;
