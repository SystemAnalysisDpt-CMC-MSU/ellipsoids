% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef MCodeQualityUtilTC < mlunitext.test_case
    methods
        function self = MCodeQualityUtilTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function testTouch(~)
            import com.mathworks.mlservices.MatlabDesktopServices;
            [~,fileNameList,reportList]=...
                modgen.selfmnt.MCodeQualityUtils.mlintScanAll();
            %
            diagnosticMsg=...
                modgen.string.catwithsep(fileNameList,sprintf('\n'));
            diagnosticMsg=strrep(diagnosticMsg,'\','\\');
            mlunitext.assert(isempty(fileNameList),diagnosticMsg);
            mlunitext.assert(isempty(reportList),diagnosticMsg);
        end
    end
end