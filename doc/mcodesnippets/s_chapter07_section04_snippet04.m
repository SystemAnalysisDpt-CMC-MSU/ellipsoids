crsObj = [];
for i = 1:size(D, 2)
     rsObj = elltool.reach.ReachDiscrete(secSys, intersectEllArr(D(i)), ...
             dirsMat, [D(i)-1 nSteps]);
     crsObj = [crsObj rs];
end