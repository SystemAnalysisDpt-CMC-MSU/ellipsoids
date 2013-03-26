I = EA.hpintersection(GRD);  % some of the intersections are empty
D = find(~isempty(I));  % determine nonempty intersections
min(D)

% ans =
% 
%       19

max(D)

% ans =
% 
%       69
