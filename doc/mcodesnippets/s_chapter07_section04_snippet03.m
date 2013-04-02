% some of the intersections are empty
intersectEllVec = externalEllMat.hpintersection(grdHypObj);  
dVec = find(~isempty(intersectEllVec));  % determine nonempty intersections
min(D)

% ans =
% 
%       19

max(D)

% ans =
% 
%       69
