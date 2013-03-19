E = ellipsoid([-2; -1], [4 -1; -1 1]);
V = [1 1; 1 -1; -1 1; -1 -1]';
hold on;
plot(E)
plot(V)
distance(E, V)

% ans =
% 
%      2.3428    1.0855    1.3799    -1.0000
