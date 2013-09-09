
 t = 0.886;
 ct = cut(rs, t);
 bct = cut(brs, t);
 EF = get_ea(ct);
 EB = get_ea(bct);
 gc1 = get_goodcurves(ct); gc1 = gc1{1};
 dst = distance(EB, gc1);
 id = find(dst == max(dst));
 gc2 = get_goodcurves(bct); gc2 = gc2{id};
 fc = get_center(ct);
 bc = get_center(bct);
 gc2 = -(gc2 - bc) + bc;
 plotByEa(ct); hold on;
 plotByEa(bct,'g'); hold on;
 ell_plot(gc1,'r*');
 ell_plot(gc2,'k*');
