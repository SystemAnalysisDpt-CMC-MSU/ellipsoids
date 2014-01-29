%% 
% This demo presents functions for ellipsoid manipulaton:
% 
%   - Creation of ellipsoid objects;
%   - Basic operations;
%   - Intersections, geometric sums and differences;
%   - Visualization;
%   - Accessing internal information of ellipsoid object;
%   - Ellipsoids and hyperplanes.
cla; axis([-4 4 -2 2]);
axis([-4 4 -2 2]); grid off; axis off;
text(-3, 0.5, 'ELLIPSOIDAL CALCULUS', 'FontSize', 16);
%% 
% Ellipsoid E in R^n is defined by its center, vector q in R^n,
% and symmetric positive semi-definite matrix Q in R^(nxn):
% 
%      E(q, Q) = { x in R^n | <(x - q), Q^(-1)(x - q)> }.
% 
% 
% The support function of ellipsoid E(q, Q):
% 
%      rho(l | E(q, Q)) = <q, l> + sqrt(<l, Ql>).

%% 
% We create two ellipsoids, the second one is centered at the origin:
% 
% >> E = ellipsoid([2; -1], [2 -1; -1 1]);
% >> E0 = ellipsoid([1 0; 0 4]);
% >> plot(E0, E, 'b'); grid on;
% 
% Created ellipsoids are plotted on your screen.
E = ellipsoid([2; -1], [2 -1; -1 1]);
E0 = ellipsoid([1 0; 0 4]);
plot(E0, E, 'b'); grid on;
%% 
% Ellipsoids can be concatenated into arrays:
% 
% >> E1 = 2*ell_unitball(2) + [2; 2];
% >> EA = [E0 E1; E ellipsoid([-1.5; 1], 3*eye(2))];
% 
% Most functions dealing with ellipsoids can be used for ellipsoidal arrays as well as for single ellipsoids.
% 
% >> plot(EA); grid on;
% 
% plots ellipsoids in the array EA.
E1 = 2*ell_unitball(2) + [2; 2];
EA = [E0 E1; E ellipsoid([-1.5; 1], 3*eye(2))];
plot(EA); grid on;
%% 
% Subindexing should be used to access individual ellipsoids stored in the array EA:
% 
% >> Z = EA(:, 1);
% >> plot(Z, 'r', EA(2, 2), 'b'); grid on;
% 
% plots ellipsoids in the first column of the array EA (red), and one ellipsoid in position (2, 2) of this array (blue).
plot(EA(:, 1), 'r', EA(2, 2), 'b'); grid on;
%% 
% Affine transformation can be applied to ellipsoids:
% 
% >> A = [0.5 -1; 0 1];
% >> b = [3; 0];
% >> W = A * Z + b;
% >> plot(Z, 'b', W, 'r'); grid on;
% 
% plots ellipsoids in the array Z (blue), and these ellipsoids after affine transformation (red).
A = [0.5 -1; 0 1]; b = [3; 0];
W = A*EA(:, 1) + b; plot(EA(:, 1), 'b', W, 'r'); grid on;
%% 
% It is possible to modify only shape matrix of the ellipsoid leaving its center as is:
% 
% >> E = shape(EA(2, 2), A);
% >> plot(E, EA(2, 2), 'b'); grid on;
% 
% plots original ellipsoid (blue) and the one with modified shape matrix (red).
plot(getShape(EA(2, 2), A), EA(2, 2), 'b'); grid on;
%% 
% Inverted ellipsoid is obtained by inverting the shape matrix of the original ellipsoid. In case the original ellipsoid is centered at the origin, the inverted ellipsoid is its polar ellipsoid.
% 
% >> Ei = inv(E);
% >> plot(Ei, E, 'b'); grid on;
% 
% plots original (blue) and the inverted (red) ellipsoids.
plot(E, inv(E), 'b'); grid on;
%% 
% The polar set for an ellipsoid that contains the origin in its interior is also an ellipsoid:
% 
% >> E = ellipsoid([-1; 1], [4 -2; -2 2]);
% >> P = polar(E);
% >> plot(P, E, 'b'); grid on;
% 
% plots original (blue) and the polar (red) ellipsoids.
% 
% Notice that the polar set to the ellipsoid P is the original ellipsoid E:
% 
% >> polar(P) == E
% 
% ans =
% 
%      1
W = ellipsoid([-1; 1], [4 -2; -2 2]); plot(polar(W), W, 'b'); grid on;
%% 
% Overloaded operators '>' and '<':
% 
% >> E1 = ellipsoid([15; 0], [49 -12; -12 10]);
% >> E2 = ellipsoid([9; 3], [9 2; 2 4]);
% >> (E1 > E2) & (E2 < E1)
% 
% ans =
% 
%      1
% 
% >> plot(E1, 'b', E2, 'g', move2origin([E1 E2]), 'r'); grid on;
% 
% Ellipsoid E1 (blue) is "bigger" than ellipsoid E2 (green) if when both are moved to the origin (red), E2 is contained inside E1.
% 
% 
% Overloaded operator '==' checks if two ellipsoids are equal:
% 
% >> E1 == E1
% 
% ans =
% 
%      1
E1 = ellipsoid([15; 0], [49 -12; -12 10]);
E2 = ellipsoid([9; 3], [9 2; 2 4]);
plot(E1, 'b', E2, 'g', move2origin([E1 E2]), 'r'); grid on;
%% 
% It can be checked if given ellipsoid intersects the intersection of ellipsoids in the given array:
% 
% >> E = ellipsoid([1.5; 1], [2 -1; -1 1]);
% >> plot(E, EA, 'b'); grid on;
% >> intersect(EA, E, 'i')
% 
% ans =
% 
%      -1
% 
% Result -1 means that the intersection of ellipsoids in the array EA (blue) is empty. Thus, ellipsoid E (red) cannot intersect the intersection of ellipsoids in EA.
E = ellipsoid([1.5; 1], [2 -1; -1 1]);
plot(E, EA, 'b'); grid on;
%% 
% Check if ellipsoid E intersects the intersection of two ellipsoids forming the first column of the array EA:
% 
% >> plot(E, EA(:, 1), 'b'); grid on;
% >> intersect(EA(:, 1), E, 'i')
% 
% ans =
% 
%      0
% 
% 0 means negative result, which is confirmed by the plot.
plot(E, EA(:, 1), 'b'); grid on;
%% 
% Check if ellipsoid E intersects the intersection of two ellipsoids forming the first row of the array EA:
% 
% >> plot(E, EA(1, :), 'b'); grid on;
% >> intersect(EA(1, :), E, 'i')
% 
% ans =
% 
%      1
% 
% 1 means positive result, which is confirmed by the plot.
% 
% See also help for ELLIPSOID/DISTANCE function.
plot(E, EA(1, :), 'b'); grid on;
%% 
% If two ellipsoids (red) intersect, minimal volume external (blue) and maximal by inclusion internal (green) ellipsoidal approximations of the intersection can be computed:
% 
% >> E1 = ellipsoid([2; 2], [4 -3; -3 9]);
% >> E2 = ellipsoid([1; 1], [4 2; 2 5]);
% >> Ie = intersection_ea(E1, E2);
% >> Ii = intersection_ia(E1, E2);
% >> plot([E1 E2], 'r', Ie, 'b', Ii, 'g'); grid on;
E1 = ellipsoid([2; 2], [4 -3; -3 9]);
E2 = ellipsoid([1; 1], [4 2; 2 5]);
Ie = intersection_ea(E1, E2);
Ii = intersection_ia(E1, E2);
plot([E1 E2], 'r', Ie, 'b', Ii, 'g'); grid on;
%% 
% For given set of points in R^n the minimum volume ellipsoid that contains these points can be computed:
% 
% >> V = rand(2, 7);  % 7 random points in R^2
% >> E = ell_enclose(V);
% >> ell_plot(V, 'b*'); hold on;
% >> plot(E, 'r'); grid on
RV = rand(2, 7); ell_plot(RV, 'b*'); grid on; hold on;
plot(ell_enclose(RV), 'r'); hold off;
%% 
% For two or more ellipsoids in R^n the minimum volume ellipsoid that contains the union of these ellipsoids can be computed:
% 
% >> EU = ellunion_ea(EA);
% >> plot(EA, 'b', EU, 'r'); grid on;
EU = ellunion_ea(EA); plot(EA, 'b', EU, 'r'); grid on;
%% 
% For two or more ellipsoids in R, R^2 and R^3, their geometric (Minkowski) sum can be plotted:
% 
% 
% >> minksum(EA, 'showAll',true); grid on;
% 
% plots geometric sum (red) of the ellipsoids in array EA (black).
minksum(EA, 'showAll',true); grid on;
%% 
% For two or more ellipsoids of arbitrary dimension, their geometric sum can be approximated by tight external and tight internal ellipsoids. Tight ellipsoids are computed for given directions.
% 
% >> L  = [1 0; 1 1; 0 1; -1 1]';
% >> EE = minksum_ea(EA, L); IE = minksum_ia(EA, L);
% >> plot(EE, 'b', IE, 'g'); grid on; hold on; 
% >> minksum(EA);
% 
% plots geometric sum (red) of the ellipsoids in array EA, its external (blue) and internal (green) ellipsoidal approximations for directions specified by matrix L.
L  = [1 0; 1 1; 0 1; -1 1]';
EE = minksum_ea(EA, L); IE = minksum_ia(EA, L);
plot(EE, 'b', IE, 'g'); grid on; hold on; minksum(EA); hold off;
%% 
% For two single ellipsoids E1 and E2 in R, R^2 and R^3, such that E1 > E2, their geometric (Minkowski) difference can be plotted:
% 
% >> E1 = ellipsoid([15; 0], [49 -12; -12 10]);
% >> E2 = ellipsoid([9; 3], [9 2; 2 4]);
% >> minkdiff(E1, E2, 'shawAll',true); grid on;
% 
% plots geometric difference (red) of the ellipsoids E1 and E2 (black).
E1 = ellipsoid([15; 0], [49 -12; -12 10]);
E2 = ellipsoid([9; 3], [9 2; 2 4]);
minkdiff(E1, E2,'showAll',true); grid on;
%% 
% For two ellipsoids of arbitrary dimension, E1 and E2, such that E1 > E2, their geometric difference can be approximated by tight external and tight internal ellipsoids. Tight ellipsoids are computed for given directions. Not all directions are allowed. Those directions, for which tight ellipsoidal approximations cannot be computed, are called "bad directions".
% 
% >> L  = [1 0; 1 2; 1 3; 1 4; 0 1]';
% >> isbaddirection(E1, E2, L)
% 
% ans =
% 
%      1     0     0     0     1
% 
% >> EE = minkdiff_ea(E1, E2, L);
% >> IE = minkdiff_ia(E1, E2, L);
% >> plot(EE, 'b', IE, 'g'); grid on; hold on;
% >> minkdiff(E1, E2);
% 
% plots geometric difference (red) of ellipsoids E1 and E2, tight external (blue) and tight internal (green) ellipsoidal approximations for those directions in L that are not bad.
L  = [1 0; 1 2; 1 3; 1 4; 0 1]';
EE = minkdiff_ea(E1, E2, L); IE = minkdiff_ia(E1, E2, L);
plot(EE, 'b', IE, 'g'); grid on; hold on; minkdiff(E1, E2); hold off;
%% 
% For ellipsoids E1, E2 and E3 in R, R^2 or R^3, such that E1 > E3, the set E1 - E3 + E2 can be plotted.
% 
% >> E3 = ell_unitball(2);
% >> minkmp(E1, E3, E2, 'showAll',true);
% 
% plots the set E1 - E3 + E2 (red), ellipsoids E1 (green), E2 (blue) and E3 (black).
E3=ell_unitball(2); minkmp(E1, E3, E2, 'showAll',true); grid on
%% 
% For ellipsoids E1, E2 and E3 of arbitrary dimension, such that E1 > E3, tight external and internal ellipsoidal approximations of the set E1 - E3 + E2 for given directions can be computed.
% 
% >> EE = minkmp_ea(E1, E3, E2, L);  % external
% >> IE = minkmp_ia(E1, E3, E2, L);  % internal
% >> plot(EE, 'b', IE, 'g'); grid on; hold on;
% >> minkmp(E1, E3, E2);
% 
% plots the actual set E1 - E3 + E2, tight external (blue) and tight internal (green) ellipsoidal approximations for those directions in L that are not bad.
EE = minkmp_ea(E1, E3, E2, L);
IE = minkmp_ia(E1, E3, E2, L);
minkmp(E1, E3, E2); grid on; hold on; plot(EE, 'b', IE, 'g'); hold off
%% 
% For ellipsoids E1, E2 and E3 in R, R^2 or R^3, the set E1 + E2 - E3 can be plotted if nonempty.
% 
% >> minkpm([E1 E2], E3, 'showAll',true);
% 
% plots the set E1 + E2 - E3 (red), ellipsoids E1, E2 (blue) and ellipsoid E3 (black).
minkpm([E1 E2], E3,'showAll',true); grid on
%% 
% For ellipsoids E1, E2 and E3 of arbitrary dimension, tight external and internal ellipsoidal approximations of the set E1 + E2 - E3 (if this set is nonempty) for given directions can be computed.
% 
% >> EE = minkpm_ea([E1 E2], E3, L);  % external
% >> IE = minkpm_ia([E1 E2], E3, L);  % internal
% >> plot(EE, 'b', IE, 'g'); grid on; hold on;
% >> minkpm([E1 E2], E3);
% 
% plots the actual set E1 + E2 - E3, tight external (blue) and tight internal (green) ellipsoidal approximations for those directions in L that are not bad.
EE = minkpm_ea([E1 E2], E3, L);
IE = minkpm_ia([E1 E2], E3, L);
minkpm([E1 E2], E3); grid on; hold on; plot(EE, 'b', IE, 'g'); hold off
%% 
% To visualize ellipsoids of high dimensions, projections are used:
% 
% >> E1 = ellipsoid([1; 0; -1], [4 0 -2; 0 6 0; -2 0 1.5]);
% >> E2 = ellipsoid([2 0 0; 0 9 3; 0 3 2]);
% >> E3 = 2*ell_unitball(3) + [1; 1; 0];
% >> B1 = [1 0 0; 0 1 0]'; P1 = projection([E1 E2 E3], B1);
% >> B2 = [1 0 0; 0 0 1]'; P2 = projection([E1 E2 E3], B2);
% >> B3 = [0 1 0; 0 0 1]'; P3 = projection([E1 E2 E3], B3);
% >> subplot(2, 2, 1); plot([E1 E2 E3]); grid on;
% >> subplot(2, 2, 2); plot(P1); grid on;
% >> subplot(2, 2, 3); plot(P2); grid on;
% >> subplot(2, 2, 4); plot(P3); grid on;
% 
% plots 3-dimensional ellipsoids (a), and their three projections (b), (c), (d), each specified by its orthonormal basis.
E1 = ellipsoid([1; 0; -1], [4 0 -2; 0 6 0; -2 0 1.5]);
E2 = ellipsoid([2 0 0; 0 9 3; 0 3 2]);
E3 = 2*ell_unitball(3) + [1; 1; 0];
B1 = [1 0 0; 0 1 0]'; B2 = [1 0 0; 0 0 1]'; B3 = [0 1 0; 0 0 1]';
subplot(2, 2, 1); plot(E1, E2, E3); title('(a) Ellipsoids in 3D');
xlabel('x_1'); ylabel('x_2'); zlabel('x_3'); grid on;
subplot(2, 2, 2); plot(getProjection([E1 E2 E3], B1));
grid on;
title('(b) Projection on basis B1'); xlabel('x_1'); ylabel('x_2');
subplot(2, 2, 3); plot(getProjection([E1 E2 E3], B2));
grid on;
title('(c) Projection on basis B2'); xlabel('x_1'); ylabel('x_3');
subplot(2, 2, 4); plot(projection([E1 E2 E3], B3));
grid on;
title('(d) Projection on basis B3'); xlabel('x_2'); ylabel('x_3');
%% 
% Internal structure of the ellipsoid can be accessed through several functions:
% 
% >> [q, Q] = parameters(E)
% 
% q =
% 
%    1.5000
%    1.0000
% 
% 
% Q =
% 
%     2    -1
%    -1     1
% 
% >> dimension([E E1 ellipsoid(1)]
% 
% ans =
% 
%      2     3     1
% 
% >> D = ellipsoid([1 3; 3 9]);
% >> isdegenerate([D E])
% 
% ans =
% 
%      1     0
% 
% >> plot(D, E, 'b'); grid on;
% 
% plots nondegenerate ellipsoid E (blue) and degenerate ellipsoid D (red).
subplot(1, 1, 1); D = ellipsoid([1 3; 3 9]); plot(D, E, 'b'); grid on;
%% 
% Hyperplane in R^n is defined by the normal vector v and scalar c:
% 
%       H = { x in R^n | <v, x> = c }.
% 
% >> H = hyperplane([-5; -3], -9);
% 
% It is also possible to declare an array of hypertplanes at once:
% 
% >> HA = hyperplane([0 1; 1 0]', [2.5 2]);
% 
% Most functions dealing with hyperplanes can be used for hyperplane arrays as well as for single hyperplanes.
% 
% >> plot(H, HA, 'b','lineWidth',2,'size',7); grid on;
% 
% plots three hyperplanes - one single hyperplane H (red) and two hyperplanes from the array HA (blue).
H  = hyperplane([-5; -3], -9);
HA = hyperplane([0 1; 1 0]', [2.5 2]);
plot(H, HA, 'b', 'lineWidth',2,'size',7); grid on;
%% 
% It can be checked if given hyperplane intersects an ellipsoid or intersection of ellipsoids:
% 
% >> intersect(EA(1, 1), H)
% 
% ans =
% 
%      0
% 
% >> E = E - [0.5; 0];
% >> intersect(E, H)
% 
% ans =
% 
%      1
% 
% If a hyperplane intersects an ellipsoid, then the intersection is a degenerate ellipsoid:
% 
% >> I = hpintersection(E, H);
% >> isdegenerate(I)
% 
% ans =
% 
%      1
% 
% >> plot(H, 'k', 'lineWidth',1,'size',5); hold on; grid on;
% >> plot(E, EA(1, 1), 'g', I, 'b');
% 
% plots hyperplane H (black), ellipsoid EA(1, 1) (green) whose intersection with H is empty, ellipsoid E (red) that has nonempty intersection with H, and this intersection I (blue).
plot(H, 'k', 'lineWidth',1,'size',5); hold on; grid on;
E = E - [0.5; 0]; plot(E, EA(1, 1), 'g', hpintersection(E, H), 'b'); hold off;
%% 
% If hyperplane H is defined by its normal v and the scalar c, then the corresponding halfpace is
% 
%        { x in R^n | <v, x> <= c }.
% 
% Minimal volume external and maximal by inclusion internal ellipsoidal approximations of intersection of an ellipsoid with halfspace defined by hyperplane (if this intersection is nonempty) can be computed:
% 
% >> Ee = intersection_ea(E, H);
% >> Ei = intersection_ia(E, H);
% >> plot(H, 'k', 'lineWidth',1,'size',5); hold on; grid on;
% >> plot(E, Ee, 'b', Ei, 'g');
% 
% plots hyperplane H (black), ellipsoid E (red), external Ee (blue) and internal Ei (green) ellipsoidal approximations of intersection of E with halfspace defined by H.
Ee = intersection_ea(E, H); Ei = intersection_ia(E, H);
plot(H, 'k',  'lineWidth',1,'size',5); hold on; plot(E, Ee, 'b', Ei, 'g'); grid on; hold off;
%% 
% To approximate the intersection of ellipsoid E with the other halfspace defined by the same hyperplane H, it is enough to switch sign of H:
% 
% >> H  = -H;
% >> Ei = intersection_ia(E, H);
% >> Ee = intersection_ea(E, H);
% 
% External ellipsoid Ee in this case coincides with original ellipsoid E:
% 
% >> Ee == E
% 
% ans =
% 
%      1
% 
% >> plot(H, 'k',  'lineWidth',1,'size',5); grid on; hold on;
% >> plot(E, Ei, 'g');
% 
% plots hyperplane H (black), original ellipsoid E (red), which is the same as Ee, and internal approximating ellipsoid Ei (green).
plot(H, 'k',  'lineWidth',1,'size',5); hold on; grid on;
plot(E, intersection_ia(E, -H), 'g'); hold off;
%% 
% For more information about functionality of ellipsoid and hyperplane libraries of this toolbox, type
% 
% >> help ellipsoid/contents
% 
% and
% 
% >> help hyperplane/contents
% 
% You will obtain the list of functions that operate with ellipsoids and hyperplanes. For details, use help on each function individually.
cla; axis([-4 4 -2 2]);
axis([-4 4 -2 2]); grid off; axis off;
text(-1, 0.5, 'THE END', 'FontSize', 16);
