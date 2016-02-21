function results=run_tests(varargin)
import gras.ellapx.lreachuncert.probdyn.test.*;
res1=run_cont_tests(varargin{:});
res2=run_discr_tests(varargin{:});
results=[res1 res2];