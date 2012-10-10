classdef mlunit_test_common < mlunitext.test_case
    properties
    end
    
    methods
        function self = mlunit_test_common(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = set_up_param(self,varargin)
        % 
        end
        %
        function testThrowWarn(~)
            MSG_STR='test message';
            %
            ID_SUFF_STR='wrongInput';
            ID_STR=...
                ['MODGEN:COMMON:TEST:MLUNIT_TEST_COMMON:TESTTHROWWARN:',...
                ID_SUFF_STR];
            %
            lastwarn('');
            modgen.common.throwwarn('wrongInput',MSG_STR);
            [lastMsg,lastId]=lastwarn();
            mlunit.assert_equals(true,isequal(MSG_STR,lastMsg));
            mlunit.assert_equals(true,isequal(ID_STR,lastId));
        end
        function self=testThrowError(self)
            meExpObj=modgen.common.throwerror('wrongInput','test message');
            try
                modgen.common.throwerror('wrongInput','test message');
            catch meObj
                mlunit.assert_equals(true,isequal(meObj.identifier,meExpObj.identifier));
                mlunit.assert_equals(true,isequal(meObj.message,meExpObj.message));
                mlunit.assert_equals(true,isequal(meObj.cause,meExpObj.cause));
            end
        end
        function self=test_parseparams(self)
            [reg,prop]=getparse({'alpha'});
            mlunit.assert_equals(true,isequal(reg,{'alpha'}));
            mlunit.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({'alpha','beta',1});
            mlunit.assert_equals(true,isequal(reg,{'alpha'}));
            mlunit.assert_equals(true,isequal(prop,{'beta',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1});
            mlunit.assert_equals(true,isequal(reg,{'alpha',1,3}));
            mlunit.assert_equals(true,isequal(prop,{'beta',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1},{'alpha'});
            mlunit.assert_equals(true,isequal(reg,{3,'beta',1}));
            mlunit.assert_equals(true,isequal(prop,{'alpha',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1},{});
            mlunit.assert_equals(true,isequal(reg,{'alpha',1,3,'beta',1}));
            mlunit.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1,'gamma',1},'gamma');
            mlunit.assert_equals(true,isequal(reg,{'alpha',1,3,'beta',1}));
            mlunit.assert_equals(true,isequal(prop,{'gamma',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'gamma',1,'beta',1},'gamma');
            mlunit.assert_equals(true,isequal(reg,{'alpha',1,3,'beta',1}));
            mlunit.assert_equals(true,isequal(prop,{'gamma',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1,'gamma',1},'Gamma');
            mlunit.assert_equals(true,isequal(reg,{'alpha',1,3,'beta',1}));
            mlunit.assert_equals(true,isequal(prop,{'gamma',1}));
            %
            [reg,prop]=getparse({'alpha',1},'beta');
            mlunit.assert_equals(true,isequal(reg,{'alpha',1}));
            mlunit.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({'alpha',1},'beta',[0 2]);
            mlunit.assert_equals(true,isequal(reg,{'alpha',1}));
            mlunit.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({1,'alpha'},'alpha');
            mlunit.assert_equals(true,isequal(reg,{1,'alpha'}));
            mlunit.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse(...
                {1,'alpha',3,'beta',3,'gamma'},{'alpha','gamma'});
            mlunit.assert_equals(true,isequal(reg,{1,'beta',3,'gamma'}));
            mlunit.assert_equals(true,isequal(prop,{'alpha',3}));
            function [reg,prop]=getparse(argList,varargin)
                if (nargin>1)
                    propInpNameList=varargin{1};
                    if isnumeric(propInpNameList)&&isempty(propInpNameList)
                        isPropNameSpec=false;
                    else
                        if ischar(propInpNameList)
                            propInpNameList={lower(propInpNameList)};
                        else
                            propInpNameList=lower(propInpNameList);
                        end
                        isPropNameSpec=true;
                    end
                else
                    isPropNameSpec=false;
                end
                %
                [reg,prop]=modgen.common.parseparams(argList,varargin{:});
                %
                if isPropNameSpec&&numel([varargin{:}])>0
                    nPairs=length(propInpNameList);
                    outCell=cell(1,2*nPairs);
                    [reg1,~,outCell{:}]=...
                        modgen.common.parseparext(argList,varargin{:});
                    %
                    [propValList,isSpecVec]=getval(outCell);
                    %
                    propNameList=propInpNameList;
                    %
                    mlunit.assert_equals(true,isequal(reg,reg1));
                    isEqual=isequal(propNameList,...
                        propInpNameList)||isempty(propNameList)&&...
                        isempty(propInpNameList);
                    mlunit.assert_equals(true,isEqual);
                    pNameList=propNameList(isSpecVec);
                    pValList=propValList(isSpecVec);
                    inpArgList=[pNameList;pValList];
                    s1=struct(inpArgList{:});
                    s2=struct(prop{:});
                    isEqual=isequal(s1,s2);
                    mlunit.assert_equals(true,isEqual);
                    %
                    if ~all(isSpecVec)
                        defValList=num2cell(rand(size(propNameList)));
                        [reg2,~,outCell{:}]=...
                            modgen.common.parseparext(argList,...
                            [propNameList;defValList],varargin{2:end});
                        mlunit.assert_equals(true,isequal(reg,reg2));
                        [propValList,isSpecVec]=getval(outCell);
                        isEqual=isequal(propValList(~isSpecVec),...
                            defValList(~isSpecVec));
                        mlunit.assert_equals(true,isEqual);
                        %
                        checkStrList=repmat({'false'},size(defValList));
                        checkStrList(isSpecVec)={'true'};
                        [reg3,~,outCell{:}]=...
                            modgen.common.parseparext(argList,...
                            [propNameList;defValList;...
                            checkStrList],varargin{2:end});
                        [propValList3,isSpecVec3]=getval(outCell);
                        mlunit.assert_equals(true,isequal(reg,reg3));
                        mlunit.assert_equals(true,isequal(propValList3,propValList));
                        mlunit.assert_equals(true,isequal(isSpecVec,isSpecVec3));
                    end
                end
                %
                function [propValList,isSpecVec]=getval(outCell)
                    propValList=outCell(1:nPairs);
                    isSpecVec=[outCell{nPairs+1:nPairs*2}];
                end
            end
        end
        function self=test_parseparams_negative(self)
            inpArgList={'alpha',1,3,'beta',1,'gamma',1};
            %
            [reg1,prop1]=modgen.common.parseparams(inpArgList);
            [reg2,prop2]=modgen.common.parseparams(inpArgList,[]);
            %
            mlunit.assert_equals(true,isequal(reg1,reg2));
            mlunit.assert_equals(true,isequal(prop1,prop2));
            %
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],0);',...
                ':wrongParamList');
            modgen.common.parseparams(inpArgList,[],3);
            modgen.common.parseparams(inpArgList,[],3,[]);
            modgen.common.parseparams(inpArgList,[],3,2);
            modgen.common.parseparams(inpArgList,[],[],2);
            modgen.common.parseparams(inpArgList,[],[3,3]);
            modgen.common.parseparams(inpArgList,[],[3,3],[]);
            modgen.common.parseparams(inpArgList,[],[3,6],2);
            modgen.common.parseparams(inpArgList,[],[0,3],2);
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],3,3);',...
                ':wrongParamList');
            %
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[0,3],2.5);',...
                ':wrongInput');
            %
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[],3);',...
                ':wrongParamList');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],3.5,3);',...
                ':wrongInput');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[-3 3],2);',...
                ':wrongInput');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[3.5 3.4],3);',...
                ':wrongInput');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[3.5 3.4],3);',...
                ':wrongInput');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[4 4],2);',...
                ':wrongParamList');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[4 6],2);',...
                ':wrongParamList');
            self.runAndCheckError(...
                'modgen.common.parseparams(inpArgList,[],[0 2],2);',...
                ':wrongParamList');
        end

        function self=test_auxchecksize(self)
            mlunit.assert_equals(true,auxchecksize(rand(2,3),[2,3,1]));
            mlunit.assert_equals(true,auxchecksize(rand(2,3),[2,3]));
            mlunit.assert_equals(false,auxchecksize(rand(2,4),[2,3]));
            mlunit.assert_equals(false,auxchecksize(rand(2,4,5),[2,4]));
            mlunit.assert_equals(true,auxchecksize([],[]));
            mlunit.assert_equals(false,auxchecksize(1,[]));
        end
        function self=test_getcallernameext(self)
            testClassA=GetCallerNameExtTestClassA;
            [methodName className]=getCallerInfo(testClassA);
            mlunit.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassA')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            testClassA=simpleMethod(testClassA);
            [methodName className]=getCallerInfo(testClassA);
            mlunit.assert_equals(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            testClassA=subFunctionMethod(testClassA);
            [methodName className]=getCallerInfo(testClassA);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            testClassA=subFunctionMethod2(testClassA);
            [methodName className]=getCallerInfo(testClassA);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            testClassA=subFunctionMethod3(testClassA);
            [methodName className]=getCallerInfo(testClassA);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            %
            testClassB=GetCallerNameExtTestClassB;
            [methodName className]=getCallerInfo(testClassB);
            mlunit.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassB')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            simpleMethod(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunit.assert_equals(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            subFunctionMethod(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            subFunctionMethod2(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            subFunctionMethod3(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            %
            testClassB=getcallernameexttest.GetCallerNameExtTestClassB;
            [methodName className]=getCallerInfo(testClassB);
            mlunit.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassB')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            simpleMethod(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunit.assert_equals(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            subFunctionMethod(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            subFunctionMethod2(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            subFunctionMethod3(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            %
            testClassC=GetCallerNameExtTestClassC;
            [methodName className]=getCallerInfo(testClassC);
            mlunit.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassB')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            testClassC=GetCallerNameExtTestClassC(false);
            [methodName className]=getCallerInfo(testClassC);
            mlunit.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassC')&&...
                isequal(className,'GetCallerNameExtTestClassC'));
            simpleMethod(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunit.assert_equals(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'GetCallerNameExtTestClassC'));
            subFunctionMethod(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassC'));
            subFunctionMethod2(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            subFunctionMethod3(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'GetCallerNameExtTestClassC'));
            %
            testClassC=getcallernameexttest.GetCallerNameExtTestClassC;
            [methodName className]=getCallerInfo(testClassC);
            mlunit.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassB')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            testClassC=getcallernameexttest.GetCallerNameExtTestClassC(false);
            [methodName className]=getCallerInfo(testClassC);
            mlunit.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassC')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassC'));
            simpleMethod(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunit.assert_equals(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassC'));
            subFunctionMethod(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassC'));
            subFunctionMethod2(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            subFunctionMethod3(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunit.assert_equals(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassC'));
            %
            methodName='';className='';
            s_getcallernameext_test;
            mlunit.assert_equals(true,...
                isequal(methodName,'s_getcallernameext_test')&&...
                isequal(className,''));
            %
            methodName='';className='';
            getcallernameexttest.s_getcallernameext_test;
            mlunit.assert_equals(true,...
                isequal(methodName,'getcallernameexttest.s_getcallernameext_test')&&...
                isequal(className,''));
            %
            [methodName className]=getcallernameext_simplefunction();
            mlunit.assert_equals(true,...
                isequal(methodName,'getcallernameext_simplefunction')&&...
                isequal(className,''));
            [methodName className]=getcallernameext_subfunction();
            mlunit.assert_equals(true,...
                isequal(methodName,'getcallernameext_subfunction/subfunction')&&...
                isequal(className,''));
            [methodName className]=getcallernameext_subfunction2();
            mlunit.assert_equals(true,...
                isequal(methodName,'getcallernameext_subfunction2/subfunction')&&...
                isequal(className,''));
            [methodName className]=getcallernameext_subfunction3();
            mlunit.assert_equals(true,...
                isequal(methodName,'getcallernameext_subfunction3/subfunction/subfunction2')&&...
                isequal(className,''));
            %
            [methodName className]=getcallernameexttest.getcallernameext_simplefunction();
            mlunit.assert_equals(true,...
                isequal(methodName,'getcallernameexttest.getcallernameext_simplefunction')&&...
                isequal(className,''));
            [methodName className]=getcallernameexttest.getcallernameext_subfunction();
            mlunit.assert_equals(true,...
                isequal(methodName,'getcallernameexttest.getcallernameext_subfunction/subfunction')&&...
                isequal(className,''));
            [methodName className]=getcallernameexttest.getcallernameext_subfunction2();
            mlunit.assert_equals(true,...
                isequal(methodName,'getcallernameexttest.getcallernameext_subfunction2/subfunction')&&...
                isequal(className,''));
            [methodName className]=getcallernameexttest.getcallernameext_subfunction3();
            mlunit.assert_equals(true,...
                isequal(methodName,'getcallernameexttest.getcallernameext_subfunction3/subfunction/subfunction2')&&...
                isequal(className,''));
        end

    end
end
