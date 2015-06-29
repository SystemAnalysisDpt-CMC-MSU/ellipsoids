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
if usejava('desktop')
    echodemo('s_ell_demo_reach');
else
    s_ell_demo_reach;
end
Properties.setIsVerbose(verbose);
Properties.setNPlot2dPoints(plot2d_grid);