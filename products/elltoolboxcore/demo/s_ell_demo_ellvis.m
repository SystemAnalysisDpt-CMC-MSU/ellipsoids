%% 
% 
% This demo presents plotting functions for ellipsoids, their geometric sums and differences, and hyperplanes.
cla; axis([-4 4 -2 2]);
axis([-4 4 -2 2]); grid off; axis off;
text(-2, 0.5, 'VISUALIZATION', 'FontSize', 16);
%% 
% We start with creating four different ellipsoids, two of which form an array:
% 
% >> E1 = ellipsoid([1; -1], [9 -3; -3 4]);
% >> E2 = 2*ell_unitball(2) + [-1; 3];
% >> E3 = 3*(inv(E1) - [2; -1]);
% >> E4 = ellipsoid([4 1; 1 9]);
% >> EA = [E3 E4];
% 
% Now we plot these four ellipsoids:
% 
% >> plot(E1, E2, E3, E4); grid on;
% 
% Another way to plot the same is:
% 
% >> plot(E1, E2, EA);
E1 = ellipsoid([1; -1], [9 -3; -3 4]);
E2 = 2*ell_unitball(2) + [-1; 3];
E3 = 3*(getInv(E1) - [2; -1]); E4 = ellipsoid([4 1; 1 9]);
EA = [E3 E4]; plot(E1, E2, EA);
%% 
% The way to make the lines thicker is to tweak the 'width' option:
% 
% >> plot(E1, E2, EA, 'lineWidth',2);
plot(E1, E2, EA, 'lineWidth',2);
%% 
% It is also possible to specify different line width for different ellipsoids:
% 
% >> plot(E1, E2, EA, 'lineWidth',[2 1 2 3]);
plot(E1, E2, EA,'lineWidth',[2 1 2 3]);
%% 
% Option 'fill' specifies if ellipsoids plotted in 2D should be filled with color:
% 
% >> plot(E1, E2, EA, 'lineWidth',2,'fill',true);
plot(E1, E2, EA,'lineWidth',2,'fill',true);
%% 
% Same as with 'width' option, it is possible to specify, which of the ellipsoids should be filled with color:
% 
% >> plot(E1, E2, EA, 'fill',[true false true false]);
plot(E1, E2, EA,'fill',[true false true false]);
%% 
% Option 'color' specifies the color of ellipsoids:
% 
% >> plot(E1, E2, EA,'fill',true,'color',[1 0 0.5; 0.7 0 0; 0 0.5 0; 0 0.5 0.5]);
plot(E1, E2, EA, 'fill',true,'color',[1 0 0.5; 0.7 0 0; 0 0.5 0; 0 0.5 0.5]);
%% 
% Another, short way to assign colors is to use specifiers:
% 
% >> plot(E1, 'y', E2, 'b', E3, 'g', E4, 'r');
% 
% Allowed specifiers are:
% 
%   'r' - red,
%   'g' - green,
%   'b' - blue,
%   'c' - cyan,
%   'm' - magenta,
%   'y' - yellow,
%   'w' - white,
%   'k' - black.
plot(E1, 'y', E2, 'b', E3, 'g', E4, 'r');
%% 
% Specifiers are convenient to use with arrays - assigning one color to all ellipsoids in the array:
% 
% >> plot(E1, E2, EA, 'b');
plot(E1, E2, EA, 'b');
%% 
% Now we define three ellipsoids in R^3:
% 
% >> E31 = ellipsoid([-1; -1; 2], [25 10 -1; 10 9 5; -1 5 6]);
% >> E32 = 2.5*ell_unitball(3) + [1; 2; -6];
% >> E33 = [2 -1 0; 0 0.8 0; 0 0 1.1] * move2origin(E31);
% 
% and plot them:
% 
% >> plot(E31, E32, E33);
E31 = ellipsoid([-1; -1; 2], [25 10 -1; 10 9 5; -1 5 6]);
E32 = 2.5*ell_unitball(3) + [1; 2; -6];
E33 = [2 -1 0; 0 0.8 0; 0 0 1.1] * getMove2Origin(E31);
plot(E31, E32, E33);
%% 
% Option 'shade', taking values from [0, 1], specifies the transparency level of each ellipsoid:
% 
% >> plot(E31, E32, E33, options);
plot(E31, 'r', E32, 'b', E33, 'g', 'shade',[0.6 0.2 0.3]);
%% 
% Geometric (Minkowski) sum of ellipsoids in R, R^2 and R^3 can be plotted. Here we plot the geometric sum of previously defined 3-dimensional ellipsoids E31, E32 and E33:
% 
% >> subplot(2, 2, 1); minksum([E31 E32 E33], options);
% 
% Option 'show_all' set to 1 indicates that ellipsoids, whose geometric sum is plotted, should also be displayed.
% Now we plot three projections of this sum onto 2-dimensional subspaces:
% 
% >> B1 = [1 0 0; 0 1 0]'; P1 = projection([E31 E32 E33], B1);
% >> subplot(2, 2, 1); minksum([E31 E32 E33],'showAll',true);
% >> B2 = [1 0 0; 0 0 1]'; P2 = projection([E31 E32 E33], B2);
% >> subplot(2, 2, 3); minksum(P2, options);
% >> B3 = [0 1 0; 0 0 1]'; P3 = projection([E31 E32 E33], B3);
% >> subplot(2, 2, 4); minksum(P3, options);
B1 = [1 0 0; 0 1 0]'; P1 = getProjection([E31 E32 E33], B1);
B2 = [1 0 0; 0 0 1]'; P2 = getProjection([E31 E32 E33], B2);
B3 = [0 1 0; 0 0 1]'; P3 = getProjection([E31 E32 E33], B3);
subplot(2, 2, 1); minksum([E31 E32 E33], 'showAll',true);
title('(a) Geometric Sum'); xlabel('x_1'); ylabel('x_2'); zlabel('x_3');
subplot(2, 2, 2); minksum(P1,'showAll',true);
title('(b) Projection on basis B1'); xlabel('x_1'); ylabel('x_2');
subplot(2, 2, 3); minksum(P2, 'showAll',true);
title('(c) Projection on basis B2'); xlabel('x_1'); ylabel('x_3');
subplot(2, 2, 4); minksum(P3, 'showAll',true);
title('(d) Projection on basis B3'); xlabel('x_2'); ylabel('x_3');
%% 
% To change the color of geometric sum, option 'color' should be used. In 2-dimensional case, option 'fill' set to 1 indicates that the plotted set should be filled with color.
% 
% >> minksum(P2, 'fill',true,'color',[0 1 0]);
subplot(1, 1, 1); minksum(P2, 'fill',true,'color',[0 1 0]);
%% 
% Geometric (Minkowski) difference of two ellipsoids, if it is nonempty, is plotted similarly to the geometric sum:
% 
% >> E = ellipsoid([2 -1 0; -1 1 0; 0 0 1.5];
% >> subplot(2, 2, 1); minkdiff(E32, E, options);
% 
% Now, as before for the geometric sum, we plot three 2-dimensional projections:
% 
% >> subplot(2, 2, 2);
% >> minkdiff(projection(E32, B1), projection(E, B1), 'showAll',true,'fill',true)
% >> subplot(2, 2, 3);
% >> minkdiff(projection(E32, B2), projection(E, B2),'showAll',true,'fill',true)
% >> subplot(2, 2, 4);
% >> minkdiff(projection(E32, B3), projection(E, B3), 'showAll',true,'fill',true)
% 
% 'minkdiff' function accepts the same options as 'minksum'.
E = ellipsoid([2 -1 0; -1 1 0; 0 0 1.5]); 
subplot(2, 2, 1); minkdiff(E32, E, 'showAll',true,'fill',true);
title('(a) Geometric Difference'); xlabel('x_1'); ylabel('x_2'); zlabel('x_3');
subplot(2, 2, 2); minkdiff(getProjection(E32, B1), getProjection(E, B1),...
    'showAll',true,'fill',true),
title('(b) Projection on basis B1'); xlabel('x_1'); ylabel('x_2');
subplot(2, 2, 3); minkdiff(getProjection(E32, B2), getProjection(E, B2),...
    'showAll',true,'fill',true),
title('(c) Projection on basis B2'); xlabel('x_1'); ylabel('x_3');
subplot(2, 2, 4); minkdiff(projection(E32, B3), projection(E, B3),...
    'showAll',true,'fill',true),
title('(d) Projection on basis B3'); xlabel('x_2'); ylabel('x_3');
%% 
% Hyperplanes are plotted similarly to ellipsoids with 'plot' function taking almost the same options. Let us define three hyperplanes in R^3:
% 
% >> H1 = hyperplane([-1; 1; -1], -9);
% >> H2 = hyperplane([0; 1; 1], 10);
% >> H3 = hyperplane([1; 0; 2], 0);
% >> HA = [H2 H3];
% 
% and plot them:
% 
% >> plot(H1, HA);
H1 = hyperplane([-1; 1; -1], -9);
H2 = hyperplane([0; 1; 1], 10);
H3 = hyperplane([1; 0; 2]);
HA = [H2 H3];
subplot(1, 1, 1); plot(H1, HA);
%% 
% Sizes of the plotted hyperplanes can be adjusted by modifying the 'size' option:
% 
% >> plot(H1, HA,'size',15);
plot(H1, HA, 'size',15);
%% 
% Sizes can be also asjusted individually for each hyperplane:
% 
% >> plot(H1, HA,  'size',[25; 30; 20]);
% 
% To display a desired piece of hyperplane, tweak 'size' and 'center' options together.
plot(H1, HA, 'size',[25; 30; 20]);
%% 
% In 2-dimensional case, hyperplanes are displayed as straight lines, whose length and width are determined by 'size' and 'width' options correspondingly:
% 
% >> HH = hyperplane([1 1; 1 -1]'); o.width = 2; o.size = 10;
% >> plot(HH(1), HH(2), 'b', 'lineWidth',2,'size',10);
HH = hyperplane([1 1; 1 -1]'); 
plot(HH(1), HH(2), 'b', 'lineWidth',2,'size',10);
%% 
% For more information, type
% 
% >> help ellipsoid/plot
% >> help ellipsoid/minksum
% >> help ellipsoid/minkdiff
% >> help hyperplane/plot
cla; axis([-4 4 -2 2]);
axis([-4 4 -2 2]); grid off; axis off;
text(-1, 0.5, 'THE END', 'FontSize', 16);
