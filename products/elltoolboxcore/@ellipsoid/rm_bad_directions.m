function clrDirsMat = rm_bad_directions(q1Mat, q2Mat, dirsMat)
%
% RM_BAD_DIRECTIONS - remove bad directions from the given list.
%                     Bad directions are those which should not be used
%                     for the support function of geometric difference
%                     of two ellipsoids.
%

isGoodDirVec=~isbaddirectionmat(q1Mat,q2Mat,dirsMat);
clrDirsMat=[];
if any(isGoodDirVec)
    clrDirsMat=dirsMat(:,isGoodDirVec);
end
