crs = [];
for i = 1:size(D, 2)
     rs = elltool.reach.ReachDiscrete(s2, I(D(i)), L0, [D(i)-1 N]);
     crs = [crs rs];
 end
