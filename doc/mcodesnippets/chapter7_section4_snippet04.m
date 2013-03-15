crs = [];
for i = 1:size(D, 2)
     if (isdegenerate(I(D(i)))) 
           break;
      end
     rs = reach(s2, I(D(i)), L0, [1 N]);
     crs = [crs rs];
 end
