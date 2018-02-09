% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef TestSuite < mlunitext.test_case
    methods
        function self = TestSuite(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function testTouch(~)
            import com.mathworks.mlservices.MatlabDesktopServices;
            modgen.selfmnt.MCodeQualityUtils.mlintScanAll();
            MatlabDesktopServices.getDesktop.closeGroup('Web Browser');
        end
    end
end