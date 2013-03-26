absTol = elltool.conf.Properties.getAbsTol();
E1.isbaddirection(E4, L, absTol)  % find out which of the directions in L are bad

% ans =
% 
%      1     0     0     1 


EA = E1.minkdiff_ea(E4, L) % two of five directions specified by L are bad,
                            % so, only three ellipsoidal approximations 
                            % can be produced for this L:

% EA =
% 1x2 array of ellipsoids.

IA = E1.minkdiff_ia(E4, L)

% IA =
% 1x2 array of ellipsoids.