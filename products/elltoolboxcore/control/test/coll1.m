
 t = 0.886;
 ct = rs.cut(t);
 bct = brs.cut(t);
 EF = ct.get_ea();
 EB = bct.get_ea();
 gc1 = ct.get_goodcurves(); gc1 = gc1{1};
 dst = distance(EB, gc1);
 id = find(dst == max(dst));
 gc2 = bct.get_goodcurves(); gc2 = gc2{id};
 fc = ct.get_center();
 bc = bct.get_center();
 gc2 = -(gc2 - bc) + bc;
 ct.plotByEa(); hold on;
 bct.plotByEa('g'); hold on;
 ell_plot(gc1,'r*');
 ell_plot(gc2,'k*');
