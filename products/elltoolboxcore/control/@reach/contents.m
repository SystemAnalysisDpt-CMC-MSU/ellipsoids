% Reach set library of the Ellipsoidal Toolbox.
%
% 
% Constructor and data accessing functions:
% -----------------------------------------
%  reach          - Constructor of the reach set object, performs the 
%                   computation of the specified reach set approximations.
%  dimension      - Returns the dimension of the reach set, which can be
%                   different from the state space dimension of the system
%                   if the reach set is a projection.
%  get_system     - Returns the linear system object, for which the reach set
%                   was computed.
%  get_directions - Returns the values of the direction vectors corresponding
%                   to the values of the time grid.
%  get_center     - Returns points of the reach set center trajectory
%                   corresponding to the values of the time grid.
%  get_ea         - Returns external approximating ellipsoids corresponding
%                   to the values of the time grid.
%  get_ia         - Returns internal approximating ellipsoids corresponding
%                   to the values of the time grid.
%  get_goodcurves - Returns points of the 'good curves' corresponding
%                   to the values of the time grid.
%                   This function does not work with projections.
%  intersect      - Checks if external or internal reach set approximation
%                   intersects with given ellipsoid, hyperplane or polytope.
%  iscut          - Checks if given reach set object is a cut of another reach set.
%  isprojection   - Checks if given reach set object is a projection.
%  
%
% Reach set data manipulation and plotting functions:
% ---------------------------------------------------
%  cut        - Extracts a piece of the reach set that corresponds to the
%               specified time value or time interval.
%  projection - Projects the reach set onto a given orthogonal basis.
%  evolve     - Computes further evolution in time for given reach set
%               for the same or different dynamical system.
%  refine     - Adds new approximations, external, internal, or both, for
%               the specified direction parameters to the given reach set.
%               This function does not work with cuts and projections.
%  plot_ea    - Plots external approximation of the reach set.
%  plot_ia    - Plots internal approximation of the reach set.
%
%
% Overloaded functions:
% ---------------------
%  display - Displays the reach set object.
%  subref  - Enables the read-only access to the members of reach set object.
%  
%
% Author:
% -------
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
