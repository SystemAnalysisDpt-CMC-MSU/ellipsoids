% some of the intersections are empty
intersectEllArr = externallEllArr.hpintersection(grdHyp);  
D = find(~isempty(I));  % determine nonempty intersections
min(D)

% ans =
% 
%       19

max(D)

% ans =
% 
%       69
