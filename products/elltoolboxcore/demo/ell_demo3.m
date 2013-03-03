function ell_demo3()
%
% Reachability Demo.
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
Properties.setNTimeGridPoints(100);
%
echodemo('s_ell_demo_reach');
Properties.setIsVerbose(verbose);
Properties.setNPlot2dPoints(plot2d_grid);