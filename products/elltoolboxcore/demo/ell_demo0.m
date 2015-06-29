function ell_demo0()
%
% Demo of the ellipsoidal calculus.
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
    s_ell_demo_ellbasic;
else
    echodemo('s_ell_demo_ellbasic');
end
%
Properties.setIsVerbose(verbose);
Properties.setNPlot2dPoints(plot2d_grid);

