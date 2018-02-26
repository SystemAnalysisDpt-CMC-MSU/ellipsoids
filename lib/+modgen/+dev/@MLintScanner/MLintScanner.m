% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef MLintScanner
    methods (Static)
        [fileList,reportList]=scan(dirNameList,...
            pathPatternToExclude)
        [htmlOut,fullFileNameList,reportList]=...
            scanWithHtmlReport(dirList,patternToExclude)
    end
end