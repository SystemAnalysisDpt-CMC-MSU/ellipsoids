classdef ParCalculatorTestCase < mlunitext.test_case
   methods
       function self=ParCalculatorTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
       end
       function self=testPC(self)
           resDir=gras.test.TmpDataManager.getDirByCallerKey();
           pCalc=elltool.pcalc.ParCalculator();
           pCalcTestCase=elltool.pcalc.test.mlunit.ParCalculatorTestCase();
           pCalc.eval(@pCalcTestCase.funcForTest,{resDir,resDir},{'file1.mat' 'file2.mat'})
           checker=modgen.system.ExistanceChecker();
           if (~((checker.isFile([resDir '\' 'file1.mat']))&&(checker.isFile([resDir '\' 'file2.mat']))))
              error([upper(mfilename)], 'problem with parallel processes, something wrong in ParCalculator');
           end
        end    
   end
   
   methods(Static)
           
        function funcForTest (path,fileName)
            fid = fopen([path '\' fileName], 'w');
            fclose(fid);
          end
   
    end;    
 
end
   