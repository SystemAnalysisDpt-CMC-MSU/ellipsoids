% Hyperplane object of the Ellipsoidal Toolbox.
%
% 
% Functions:
% ----------
%  hyperplane - Constructor of hyperplane object.
%  double     - Returns parameters of hyperplane, i.e. normal vector and 
%               shift.
%  parameters - Same function as 'double' (legacy matter).
%  dimension  - Returns dimension of hyperplane.
%  isempty    - Checks if hyperplane is empty.
%  isparallel - Checks if one hyperplane is parallel to the other one.
%  contains   - Check if hyperplane contains given point.
%
%
% Overloaded operators and functions:
% -----------------------------------
%  eq      - Checks if two hyperplanes are equal.
%  ne      - The opposite of 'eq'.
%  uminus  - Switches signs of normal and shift parameters to the opposite.
%  display - Displays the details about given hyperplane object.
%  plot    - Plots hyperplane in 2D and 3D.
%
%
% $Author:
% -------
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

