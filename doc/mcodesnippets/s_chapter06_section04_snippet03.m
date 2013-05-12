% some of the intersections are empty
intersectEllVec = externalEllMat.hpintersection(grdHypObj);  
dVec = find(~isempty(intersectEllVec)); % determine nonempty intersections
min(dVec)

% ans =
% 
%       19

max(dVec)

% ans =
% 
%       69
