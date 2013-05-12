crsObjVec = [];
for i = 1:size(dVec, 2)
     rsObj = elltool.reach.ReachDiscrete(secSys, intersectEllVec(dVec(i)),...
             dirsMat, [dVec(i)-1 nSteps]);
     crsObjVec = [crsObjVec rsObj];
end