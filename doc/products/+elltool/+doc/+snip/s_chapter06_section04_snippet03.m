% some of the intersections are empty
intersectEllVec = externalEllMat.hpintersection(grdHypObj);  
% determine nonempty intersections
indNonEmptyVec = find(~isEmpty(intersectEllVec)); 
%
min(indNonEmptyVec)

% ans =
% 
%       19

max(indNonEmptyVec)

% ans =
% 
%       69
