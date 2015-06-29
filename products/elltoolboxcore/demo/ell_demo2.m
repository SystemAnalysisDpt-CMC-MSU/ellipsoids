function ell_demo2()
%
% Demo of the ellipsoid visualization.
%
%
% Author:
% -------
%
% Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
import elltool.conf.Properties;
%
verbose=Properties.getIsVerbose();
plot2d_grid=Properties.getNPlot2dPoints();
Properties.setIsVerbose(false);
Properties.setNPlot2dPoints(300);
%
if usejava('desktop')
    echodemo('s_ell_demo_ellvis');
else
    s_ell_demo_ellvis;
end
Properties.setIsVerbose(verbose);
Properties.setNPlot2dPoints(plot2d_grid);