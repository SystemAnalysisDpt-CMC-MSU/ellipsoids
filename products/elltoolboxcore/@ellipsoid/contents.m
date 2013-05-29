% Ellipsoid library of the Ellipsoidal Toolbox.
%
% 
% Constructor and data accessing functions:
% -----------------------------------------
%  ellipsoid    - Constructor of ellipsoid object.
%  double       - Returns parameters of ellipsoid, i.e. center and shape 
%                 matrix.
%  parameters   - Same function as 'double'(legacy matter).
%  dimension    - Returns dimension of ellipsoid and its rank.
%  isdegenerate - Checks if ellipsoid is degenerate.
%  isempty      - Checks if ellipsoid is empty.
%  maxeig       - Returns the biggest eigenvalue of the ellipsoid.
%  mineig       - Returns the smallest eigenvalue of the ellipsoid.
%  trace        - Returns the trace of the ellipsoid.
%  volume       - Returns the volume of the ellipsoid.
%
%
% Overloaded operators and functions:
% -----------------------------------
%  eq      - Checks if two ellipsoids are equal.
%  ne      - The opposite of 'eq'.
%  gt, ge  - E1 > E2 (E1 >= E2) checks if, given the same center ellipsoid 
%            E1 contains E2.
%  lt, le  - E1 < E2 (E1 <= E2) checks if, given the same center ellipsoid 
%            E2 contains E1.
%  mtimes  - Given matrix A in R^(mxn) and ellipsoid E in R^n, returns 
%            (A * E).
%  plus    - Given vector b in R^n and ellipsoid E in R^n, returns (E + b).
%  minus   - Given vector b in R^n and ellipsoid E in R^n, returns (E - b).
%  uminus  - Changes the sign of the center of ellipsoid.
%  display - Displays the details about given ellipsoid object.
%  inv     - inverts the shape matrix of the ellipsoid.
%  plot    - Plots ellipsoid in 1D, 2D and 3D.
%
%
% Geometry functions:
% -------------------
%  move2origin        - Moves the center of ellipsoid to the origin.
%  shape              - Same as 'mtimes', but modifies only shape matrix of  
%                       the ellipsoid leaving its center as is.
%  rho                - Computes the value of support function and 
%                       corresponding boundary point of the ellipsoid in
%                       the given direction.
%  polar              - Computes the polar ellipsoid to an ellipsoid that 
%                       contains the origin.
%  projection         - Projects the ellipsoid onto a subspace specified 
%                       by  orthogonal basis vectors.
%  minksum            - Computes and plots the geometric (Minkowski) sum of 
%                       given ellipsoids in 1D, 2D and 3D.
%  minksum_ea         - Computes the external ellipsoidal approximation of 
%                       geometric sum of given ellipsoids in given 
%                       direction.
%  minksum_ia         - Computes the internal ellipsoidal approximation of 
%                       geometric sum of given ellipsoids in given 
%                       direction.
%  minkdiff           - Computes and plots the geometric (Minkowski) 
%                       difference of given ellipsoids in 1D, 2D and 3D.
%  minkdiff_ea        - Computes the external ellipsoidal approximation of 
%                       geometric difference of two ellipsoids in given 
%                       direction.
%  minkdiff_ia        - Computes the internal ellipsoidal approximation of 
%                       geometric difference of two ellipsoids in given 
%                       direction
%  minkpm             - Computes and plots the geometric (Minkowski)  
%                       difference of a geometric sum of ellipsoids and a 
%                       single ellipsoid in 1D, 2D and 3D. 
%  minkpm_ea          - Computes the external ellipsoidal approximation of 
%                       the geometric difference of a geometric sum of
%                       ellipsoids and a single ellipsoid in given 
%                       direction.  
%  minkpm_ia          - Computes the internal ellipsoidal approximation of 
%                       the geometric difference of a geometric sum of  
%                       ellipsoids and a single ellipsoid in given 
%                       direction.
%  minkmp             - Computes and plots the geometric (Minkowski) sum of  
%                       a geometric difference of two single ellipsoids and 
%                       a geometric sum of ellipsoids in 1D, 2D and 3D.
%  minkmp_ea          - Computes the external ellipsoidal approximation of 
%                       the geometric sum of a geometric difference of two
%                       single ellipsoids and a geometric sum of ellipsoids  
%                       in given direction.
%  minkmp_ia          -  Computes the internal ellipsoidal approximation of 
%                       the geometric sum of a geometric difference of
%                       two single ellipsoids and a geometric sum of ellipsoids
%                       in given direction.
%  isbaddirection     - Checks if ellipsoidal approximation of geometric difference
%                       of two ellipsoids in the given direction can be computed.
%  doesIntersectionContain           - Checks if the union or intersection of 
%                       ellipsoids or polytopes lies inside the intersection 
%                       of given ellipsoids.
%  isinternal         - Checks if given vector belongs to the union or intersection
%                       of given ellipsoids.
%  distance           - Computes the distance from ellipsoid to given point,
%                       ellipsoid, hyperplane or polytope.
%  intersect          - Checks if the union or intersection of ellipsoids intersects
%                       with given ellipsoid, hyperplane, or polytope.
%  intersection_ea    - Computes the minimal volume ellipsoid containing intersection
%                       of two ellipsoids, ellipsoid and halfspace, or ellipsoid
%                       and polytope.
%  intersection_ia    - Computes the maximal ellipsoid contained inside the
%                       intersection of two ellipsoids, ellipsoid and halfspace
%                       or ellipsoid and polytope.
%  ellintersection_ia - Computes maximum volume ellipsoid that is contained
%                       in the intersection of given ellipsoids (can be more than 2).
%  ellunion_ea        - Computes minimum volume ellipsoid that contains
%                       the union of given ellipsoids.
%  hpintersection     - Computes the intersection of ellipsoid with hyperplane.
%
%
% $Author:
% -------
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
