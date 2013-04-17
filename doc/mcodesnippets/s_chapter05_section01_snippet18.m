isbaddirection(E1, E4, L)  % find out which of the directions in L are bad

% ans =
% 
%      1     0     0     1     0


EA = minkdiff_ea(E1, E4, L) % two of five directions specified by L are bad,
                            % so, only three ellipsoidal approximations 
                            % can be produced for this L:

% EA =
% 1x3 array of ellipsoids.

IA = minkdiff_ia(E1, E4, L)

% IA =
% 1x3 array of ellipsoids.
