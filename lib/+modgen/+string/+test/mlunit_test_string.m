classdef mlunit_test_string < mlunitext.test_case
    properties 
    end
    
    methods
        function self = mlunit_test_string(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self,varargin)

        end
        %
        function test_shortcapstr(~)
            check('one2oneContr','o2oC');
            check('plainIV','pIV');
            check('one2oneContr_plainIV','o2oC_pIV');
            %
            function check(inpStr,expStr)
                import modgen.string.shortcapstr;
                resStr=shortcapstr(inpStr);
                mlunit.assert_equals(resStr,expStr);
                
            end
        end
        function self=test_splitpart(self)
            inpStr='aaa..bbb..';
            try
                modgen.string.splitpart(inpStr,'..',3);
                mlunit.assert_equals(true,false);
            catch meObj
                mlunit.assert_equals(~isempty(strfind(meObj.identifier,':wrongInput')),true);
            end
            mlunit.assert_equals(modgen.string.splitpart(inpStr,'..',2),'bbb');
            mlunit.assert_equals(modgen.string.splitpart(inpStr,'..','first'),'aaa');
            inpStr='aaa';
            mlunit.assert_equals(modgen.string.splitpart(inpStr,'..','first'),'aaa');
            mlunit.assert_equals(modgen.string.splitpart(inpStr,'..','last'),'aaa');
        end
        function self=test_catwithsep(self)
            outStr=modgen.string.catwithsep({'aaa','bbb'},'__');
            mlunit.assert_equals(outStr,'aaa__bbb');
        end
        function self=test_catcellstrwithsep(self)
            outCVec=modgen.string.catcellstrwithsep(...
                {'aa','bb';'aaa','bbb';'a','b'},'-');
            mlunit.assert_equals(true,...
                isequal(outCVec,{'aa-bb';'aaa-bbb';'a-b'}));
        end
        function test_sepcellstrbysep(~)
            inpCMat={'aa','bb';'aaa','bbb';'a','b'};
            sepStr='-';
            check();
            sepStr='  ';
            check();
            sepStr='-+';
            check();
            %
            function check()
            outCVec=modgen.string.catcellstrwithsep(...
                inpCMat,sepStr);
            %
            resCMat=modgen.string.sepcellstrbysep(outCVec,sepStr);
            mlunit.assert_equals(true,isequal(resCMat,inpCMat));
            end
        end
    end
end