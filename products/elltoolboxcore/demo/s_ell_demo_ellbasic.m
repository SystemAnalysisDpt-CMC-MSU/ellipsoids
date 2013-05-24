%%
%To visualize ellipsoids of high dimensions, projections are used:',
%
%>> E1 = ellipsoid([1; 0; -1], [4 0 -2; 0 6 0; -2 0 1.5]);',
%>> E2 = ellipsoid([2 0 0; 0 9 3; 0 3 2]);',
%>> E3 = 2*ell_unitball(3) + [1; 1; 0];',
%>> B1 = [1 0 0; 0 1 0]''; P1 = projection([E1 E2 E3], B1);',
%>> B2 = [1 0 0; 0 0 1]''; P2 = projection([E1 E2 E3], B2);',
%>> B3 = [0 1 0; 0 0 1]''; P3 = projection([E1 E2 E3], B3);',
%>> subplot(2, 2, 1); plot([E1 E2 E3]); grid on;',
%>> subplot(2, 2, 2); plot(P1); grid on;',
%>> subplot(2, 2, 3); plot(P2); grid on;',
%>> subplot(2, 2, 4); plot(P3); grid on;',
%plots 3-dimensional ellipsoids (a), and their three projections (b), (c), (d), each specified by its orthonormal basis.'
%
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
%Internal structure of the ellipsoid can be accessed through several functions:',
%
%>> [q, Q] = parameters(E)',
%
%q =',
%
%   1.5000',
%   1.0000',
%
%
%Q =',
%
%    2    -1',
%   -1     1',
%
%>> dimension([E E1 ellipsoid(1)]',
%
%ans =',
%
%     2     3     1',
%
%>> D = ellipsoid([1 3; 3 9]);',
%>> isdegenerate([D E])',
%
%ans =',
%
%     1     0',
%
%>> plot(D, E, ''b''); grid on;',
%
%plots nondegenerate ellipsoid E (blue) and degenerate ellipsoid D (red).'
subplot(2, 2, 1); cla; axis off;