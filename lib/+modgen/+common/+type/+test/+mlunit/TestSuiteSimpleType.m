classdef TestSuiteSimpleType < mlunitext.test_case
    properties
    end
    
    methods
        function self = TestSuiteSimpleType(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = set_up_param(self,varargin)
            
        end
        function test_checkcelloffunc(self)
            checkP({@(x)x,@(x)x});
            checkP(@(x)x);
            checkN({@(x)x,@(x)x}.');
            checkN({});
            checkPE({});
            function checkPE(inpArg)
                expArg=inpArg;
                res=modgen.common.type.simple.checkcelloffunc(inpArg,true);
                mlunitext.assert_equals(true,isequal(res,expArg));
            end
            function checkN(varargin)
                self.runAndCheckError(...
                    'modgen.common.type.simple.checkcelloffunc(varargin{:})',...
                    ':wrongInput');                
            end
            function checkP(inpArg)
                res=modgen.common.type.simple.checkcelloffunc(inpArg);
                mlunitext.assert_equals(true,iscell(res));
            end            
        end
        function test_checkcellofstrorfunc(self)
            fHandle=@modgen.common.type.simple.lib.iscellofstrorfunc;
            checkP({@(x)x,'isstring(x)'});
            checkP({@(x)x,@(x)x});
            checkP({'isstring(x)','isstring(x)'});
            checkP({'isstring(x)','isstring(x)'}.');
            checkP({@(x)x,'isstring(x)'}.');
            checkP({@(x)x,@(x)x}.');
            checkN({@(x)x,@(x)x,1});
            checkN({'isstring(x)','isstring(x)',2});
            checkN({'isstring(x)','isstring(x)'.'});
            function checkP(inpArray)
                mlunitext.assert_equals(true,fHandle(inpArray));
            end
            function checkN(inpArray)
                mlunitext.assert_equals(false,fHandle(inpArray));
            end
            
        end
        function self=test_checkcellofstr(self)
            checkP({'a','b'});
            checkP('a',{'a'});
            checkP('aa',{'aa'});
            checkP({'aa','bb'});
            checkN('aaa'.');
            checkN({'aaa','aa'.'});
            checkN({'aaa','aa'}.');
            checkN({});
            checkPE({},true);
            checkPE({},[true true]);
            checkPE({'a','beta'},[true true]);
            checkN({},false);
            checkN({'a','b'}.',[true true]);
            checkN({'a','b'}.',[false true]);
            %
            function checkPE(inpArg,varargin)
                expArg=inpArg;
                res=modgen.common.type.simple.checkcellofstr(inpArg,varargin{:});
                mlunitext.assert_equals(true,isequal(res,expArg));
            end
            function checkN(varargin)
                self.runAndCheckError(...
                    'modgen.common.type.simple.checkcellofstr(varargin{:})',...
                    ':wrongInput');                
            end
            function checkP(inpArg,expArg)
                if nargin==1
                    expArg=inpArg;
                end
                res=modgen.common.type.simple.checkcellofstr(inpArg);
                mlunitext.assert_equals(true,isequal(res,expArg));
            end
            
        end
        function self=test_checkgenext(self)
            a='sdfadf';
            b='asd';
            %
            checkP('isstring(x1)',1,a,'alpha');
            checkP('isstring(x1)',1,a);
            checkP('numel(x1)==numel(x2)',2,a,a);
            checkP('numel(x1)==numel(x2)',2,a,a,'alpha');
            checkP('numel(x1)==numel(x2)',2,a,a,'alpha','beta');
            
            checkN('numel(x1)==numel(x2)',2,[],a,a,'alpha','beta','gamma');
            checkN('numel(x1)==numel(x2)',2,'Alpha,Beta',a,b,'Alpha','Beta');
            checkN('numel(x1)==numel(x2)',2,'Alpha,b',a,b,'Alpha');
            %
            function checkN(typeSpec,nPlaceHolders,expMsg,a,b,varargin)
                if isempty(expMsg)
                    runArgList={};
                else
                    runArgList={expMsg};
                end
                import modgen.common.type.simple.lib.*;
                try
                    modgen.common.type.simple.checkgenext(...
                    typeSpec,nPlaceHolders,a,b,varargin{:});
                catch meObj
                    self.runAndCheckError(...
                        'rethrow(meObj)',...
                        ':wrongInput',runArgList{:});
                end
                fHandle=typeSpec2Handle(typeSpec,nPlaceHolders);                
                try 
                    modgen.common.type.simple.checkgenext(...
                        fHandle,nPlaceHolders,a,b,varargin{:});
                catch meObj
                    self.runAndCheckError(...
                        'rethrow(meObj)',':wrongInput',runArgList{:});
                end
            end
            %
            function checkP(typeSpec,nPlaceHolders,varargin)
                import modgen.common.throwerror;
                modgen.common.type.simple.checkgenext(typeSpec,...
                    nPlaceHolders,varargin{:});
                fHandle=typeSpec2Handle(typeSpec,nPlaceHolders);
                modgen.common.type.simple.checkgenext(fHandle,...
                    nPlaceHolders,varargin{:});
            end
            %
            function fHandle=typeSpec2Handle(typeSpec,nPlaceHolders)
                import modgen.common.type.simple.lib.*;                
                switch nPlaceHolders
                    case 1,
                        fHandle=eval(['@(x1)(',typeSpec,')']);
                    case 2,
                        fHandle=eval(['@(x1,x2)(',typeSpec,')']);
                    case 3,
                        fHandle=eval(['@(x1,x2,x3)(',typeSpec,')']);
                    otherwise,
                        throwerror('wrongInput',...
                            'unsupported number of arguments');
                end
            end
        end
        function self=test_check(self)
            a='sdfadf';
            modgen.common.type.simple.checkgen(a,'isstring(x)');
            modgen.common.type.simple.checkgen(a,'isstring(x)','aa');
            a=1;
            checkN(a,'isstring(x)');
            checkN(a,'iscelloffunc(x)');
            %
            checkP(a,'isstring(x)||isrow(x)');
            %
            checkP(a,'isstring(x)||isrow(x)||isabrakadabra(x)');
            %
            a=1;
            checkN(a,'isstring(x)&&isvec(x)');
            checkN(a,'isstring(x)&&isabrakadabra(x)');
            %
            a=true;
            checkP(a,'islogical(x)&&isscalar(x)');
            a=struct();
            checkP(a,'isstruct(x)&&isscalar(x)');
            %
            a={'a','b'};
            checkP(a,'iscellofstrvec(x)');
            a={'a','b';'d','e'};
            checkP(a,'iscellofstrvec(x)');
            a={'a','b'};
            checkP(a,'iscellofstring(x)');
            a={'a','b';'d','e'};
            checkP(a,'iscellofstring(x)');  
            a={'a','b';'d','esd'.'};
            checkN(a,'iscellofstring(x)');  
            %
            a={@(x)1,@(x)2};
            checkP(a,'iscelloffunc(x)');
            a={@(x)1,'@(x)2'};
            checkN(a,'iscelloffunc(x)');
            %
            function checkN(x,typeSpec,varargin)
                import modgen.common.type.simple.lib.*;
                self.runAndCheckError(...
                    ['modgen.common.type.simple.checkgen(x,',...
                    'typeSpec,varargin{:})'],...
                    ':wrongInput');
                fHandle=eval(['@(x)(',typeSpec,')']);
                self.runAndCheckError(...
                    ['modgen.common.type.simple.checkgen(x,',...
                    'fHandle,varargin{:})'],...
                    ':wrongInput');
                
            end
            function checkP(x,typeSpec,varargin)
                import modgen.common.type.simple.lib.*;
                modgen.common.type.simple.checkgen(x,typeSpec,varargin{:});
                fHandle=eval(['@(x)(',typeSpec,')']);
                modgen.common.type.simple.checkgen(x,fHandle,varargin{:});
            end
            
        end
    end
end