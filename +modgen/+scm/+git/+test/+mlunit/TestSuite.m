classdef TestSuite < mlunitext.test_case
    properties (Access=private)
        locDir
    end
    methods
        function self = TestSuite(varargin)
            self = self@mlunitext.test_case(varargin{:});
            self.locDir=fileparts(which(mfilename('class')));
        end
        %
        function testMain(self)
            if modgen.scm.git.isgit(self.locDir)
                hashStr=modgen.scm.git.gitgethash(self.locDir);
                mlunitext.assert_equals(40,numel(hashStr));                
                check(hashStr);
                urlStr=modgen.scm.git.gitgeturl(self.locDir);
                check(urlStr);
                branchStr=modgen.scm.git.gitgetbranch(self.locDir);
                check(branchStr);
            end
        end
    end
end
function check(strToCheck)
mlunitext.assert(isequal(strToCheck,strtrim(strToCheck)));
end