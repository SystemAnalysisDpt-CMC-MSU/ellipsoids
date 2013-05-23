classdef AuxChecker<handle
    methods
        function checkResultReport(~,result,nTests,nExpErrors,nExpFailures)
            [nErrors,nFailures]=result.getErrorFailCount();
            assert(nErrors==nExpErrors);
            assert(nFailures==nExpFailures);
            if nargin<3
                nTests=1;
            end
            if (nErrors==0)&&(nFailures==0)
                expMsg=sprintf(...
                    '<< PASSED >> || TESTS: %d',nTests);
                
            else
                expMsg=sprintf(...
                    '<< FAILED >> || TESTS: %d,  FAILURES: %d,  ERRORS: %d',...
                    nTests,nFailures,nErrors);
            end
            assert(~isempty(strfind(result.getReport(),expMsg)));
        end
    end
end

