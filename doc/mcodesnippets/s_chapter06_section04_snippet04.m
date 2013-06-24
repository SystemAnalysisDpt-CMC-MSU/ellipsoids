crsObjVec = [];
for i = 1:size(D, 2)
     rsObj = elltool.reach.ReachDiscrete(secSys, intersectEllVec(D(i)), ...
             dirsMat, [D(i)-1 nSteps]);
     crsObjVec = [crsObjVec rsObj];
end