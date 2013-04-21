classdef EllAuxTestCase < mlunitext.test_case
    properties (Access=private)
        ABS_TOL = 1e-7;
     end
     methods
         function self=EllAuxTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
         end
         
         function self = testRegularization(self)
             import modgen.common.checkmultvar;
             
             shMat = [4 4 14; 4 4 14; 14 14 78];
             checkmultvar('gras.la.ismatposdef(x1,x2,1)', 2, shMat,...
                 self.ABS_TOL, 'errorTag','wrongInput','errorMessage',...
                 'shape matrix must be positive semi-definite.');
         end
     end
end