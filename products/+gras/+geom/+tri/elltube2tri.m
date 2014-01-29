function facets = elltube2tri(epoints_num, points_num)
%
% ELL_TRIAG_FACETS - generates triangular facets to be used 
%                    in PATCH function call.
%
%
% Description:
% ------------
%
%    ELL_TRIAG_FACETS(M, N)  Generates triangular facets 
%           for the PATCH call.
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

  part1_facet_data_1 = [Ie, Ie+1, Ie+1+epoints_num];
  part1_facet_data_2 = [Ie+1+epoints_num, Ie+epoints_num, Ie];
  part2_facet_data_1 = [ttime_data, ttime_data+1-epoints_num, ttime_data+1];
  part2_facet_data_2 = [ttime_data+1, ttime_data+epoints_num, ttime_data];
  facets             = zeros((points_num-1)*epoints_num*2,3);

  for d = 1:1:3
    facets(:, d) = [part1_facet_data_1(:, d); ...
                    part1_facet_data_2(:, d); ...
                    part2_facet_data_1(:, d); ...
                    part2_facet_data_2(:, d)];
  end

  return;
