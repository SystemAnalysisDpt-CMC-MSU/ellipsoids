classdef Suite < mlunitext.test_case
    properties
    end
    
    methods
        function self = Suite(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = set_up_param(self,varargin)
            
        end
        function test_basicTouch(~)
            %% This is windows-specific test
            if ~ispc()
                return;
            end
            check(true);
            check(true,{'titlePrefix','test1'});
            check(true,{'titlePrefix','test2'});
            check(false);
            check(false,{'keepCache',false});
            check(false,{'keepCache',true});
            %
            function check(isProfInfo,inpArgList)
                profile on;
                for k=1:10,cellfun(@(y)cellfun(@(x)x,{1,2,3}),{1,2},'UniformOutput',false);end;
                if nargin<2
                    inpArgList={};
                end
                if isProfInfo
                    inpArgList=[{0,profile('info')},inpArgList];
                end
                hOut=modgen.profiling.profview(inpArgList{:});
                hOut.close();                
                S = profile('status');
                mlunitext.assert_equals(true,isequal('off',S.ProfilerStatus));
            end
        end
        function self=tear_down(self)
            profile off;
        end
    end
end