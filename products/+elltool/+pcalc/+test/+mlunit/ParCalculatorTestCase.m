classdef ParCalculatorTestCase < mlunitext.test_case
   methods
       function self=ParCalculatorTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
       end
       function self=testPC(self)
           A=cell(1,2);
           A={2,3};
           [c]=elltool.pcalc.ParCalculator.eval(@elltool.pcalc.test.mlunit.ParCalculatorTestCase.funcForTest,A,A,A)
        end    
   end
   
   methods(Static)
        function [ c ] = funcForTest(k, a, b )
             c=k+a+b;
        end
 
   end
end    