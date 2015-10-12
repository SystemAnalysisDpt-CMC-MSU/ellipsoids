classdef mlunit_test_common < mlunitext.test_case
    methods
        function self = mlunit_test_common(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = set_up_param(self,varargin)
        % 
        end
        %
        function testAbsRelCompare(self)
            import modgen.common.absrelcompare;
            % size error
            self.runAndCheckError(...
                'modgen.common.absrelcompare([1 1], [1; 1], 0.1, [], @abs)', ...
                'wrongInput:wrongArgs');
            % absTol error #1
            self.runAndCheckError(...
                'modgen.common.absrelcompare([1 1], [1 1], -0.1, [], @abs)', ...
                'wrongInput:wrongAbsTol');
            % absTol error #2
            self.runAndCheckError([...
                'modgen.common.absrelcompare([1 1], [1 1], [0.1, 0.1], [],', ...
                ' @abs)'], 'wrongInput:wrongAbsTol');
            % absTol error #3
            self.runAndCheckError([...
                'modgen.common.absrelcompare([1 1], [1 1], [], [],', ...
                ' @abs)'], 'wrongInput:wrongAbsTol');
            % relTol error #1
            self.runAndCheckError(...
                'modgen.common.absrelcompare([1 1], [1 1], 0.1, -0.1, @abs)',...
                'wrongInput:wrongRelTol');
            % relTol error #2
            self.runAndCheckError([...
                'modgen.common.absrelcompare([1 1], [1 1], 0.1, [0.1, 0.1],',...
                ' @abs)'], 'wrongInput:wrongRelTol');
            % fNormOp error
            self.runAndCheckError(...
                'modgen.common.absrelcompare([1 1], [1 1], 0.1, [], 100)', ...
                'wrongInput:wrongNormOp');
            % result tests
            SRes = calc([], [], 0.5, [], @abs);
            SExpRes = struct('isEqual', true, 'absDiff', [], 'isRel', ...
                false, 'relDiff', [], 'relMDiff', []);
            check(SExpRes, SRes);
            %
            xVec = [1 2]; yVec = [2 4];
            SRes = calc(xVec, yVec, 2, [], @abs);
            SExpRes.isEqual = true;
            SExpRes.absDiff = 2;
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 1, [], @abs);
            SExpRes.isEqual = false;
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 2, 2/3, @abs);
            SExpRes.isEqual = true;
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 1, 2/3, @abs);
            SExpRes.isRel = true;
            SExpRes.relDiff = 2/3;
            SExpRes.relMDiff = 2;
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 1, 0.5, @abs);
            SExpRes.isEqual = false;
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 0.5, 0.5, @abs);
            check(SExpRes, SRes);
            function SRes = calc(varargin)
                [SRes.isEqual, SRes.absDiff, SRes.isRel, SRes.relDiff, ...
                SRes.relMDiff] = modgen.common.absrelcompare(varargin{:}); 
            end
            function check(leftArray,rightArray)
                mlunitext.assert_equals(true,isequal(leftArray,...
                    rightArray));
            end
        end        
        function self=testCheckMultVar(self)
            import modgen.common.type.simple.lib.*;
            %
            a='sdfadf';
            b='asd';
            %
            checkP(@(x1)ischarstring(x1),1,a,'varNameList',{'alpha'});
            checkP(@(x1)ischarstring(x1)',1,a);
            checkP('numel(x1)==numel(x2)',2,a,a);
            checkP('numel(x1)==numel(x2)',2,a,a,'varNameList',{'alpha'});
            checkP('numel(x1)==numel(x2)',2,a,a,'varNameList',{'alpha','beta'});
            %
            checkNSuperMaster('');
            checkNSuperMaster('MyMessage','errorMessage','MyMessage');
            %
            function checkNSuperMaster(errorMessage,varargin)
            
            checkNMaster('',errorMessage,varargin{:});
            checkNMaster('wrongParam:badType',errorMessage,'errorTag',...
                'wrongParam:badType',varargin{:});
            %
            checkNMaster('wrongParam:badType',errorMessage,'errorTag',...
                'wrongParam:badType',varargin{:});
            end
            %
            function checkNMaster(expTag,expMessage,varargin)
                isEmptyMsg=isempty(expMessage);
                checkN('numel(x1)==numel(x2)',2,expTag,expMessage,a,a,...
                    'varNameList',{'alpha','beta','gamma'},varargin{:});
                if isEmptyMsg
                    expMessage='Alpha,Beta';
                end
                checkN('numel(x1)==numel(x2)',2,expTag,expMessage,a,b,...
                    'varNameList',{'Alpha','Beta'},varargin{:});
                if isEmptyMsg
                    expMessage='Alpha,b';
                end                
                checkN('numel(x1)==numel(x2)',2,expTag,expMessage,a,b,...
                    'varNameList',{'Alpha'},varargin{:});
            end
            
            %
            function checkN(typeSpec,nPlaceHolders,expTag,expMsg,a,b,varargin)
                if isempty(expMsg)
                    runArgList={};
                else
                    runArgList={expMsg};
                end
                if isempty(expTag)
                    expTag=':wrongInput';
                end
                import modgen.common.type.simple.lib.*;
                try
                    modgen.common.checkmultvar(...
                    typeSpec,nPlaceHolders,a,b,varargin{:});
                catch meObj
                    self.runAndCheckError(...
                        'rethrow(meObj)',expTag,runArgList{:});
                end
                fHandle=typeSpec2Handle(typeSpec,nPlaceHolders);                
                try 
                    modgen.common.checkmultvar(...
                        fHandle,nPlaceHolders,a,b,varargin{:});
                catch meObj
                    self.runAndCheckError(...
                        'rethrow(meObj)',expTag,runArgList{:});
                end
            end
            %
            function checkP(typeSpec,nPlaceHolders,varargin)
                import modgen.common.throwerror;
                modgen.common.checkmultvar(typeSpec,...
                    nPlaceHolders,varargin{:});
                fHandle=typeSpec2Handle(typeSpec,nPlaceHolders);
                modgen.common.checkmultvar(fHandle,...
                    nPlaceHolders,varargin{:});
            end
            %
            function fHandle=typeSpec2Handle(typeSpec,nPlaceHolders)
                import modgen.common.type.simple.lib.*;                
                if ischar(typeSpec)
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
                else
                    fHandle=typeSpec;
                end
            end
        end
        function self=testCheckVar(self)
            import modgen.common.type.simple.lib.*;
            a='sdfadf';
            modgen.common.checkvar(a,@ischarstring);
            modgen.common.checkvar(a,@ischarstring,'aa');
            a=1;
            checkN(a,@(x)ischarstring(x));
            checkN(a,@(x)iscelloffunc(x));
            %
            checkP(a,@(x)(ischarstring(x)||isrow(x)));
            %
            checkP(a,@(x)(ischarstring(x)||isrow(x)||isabrakadabra(x)));
            %
            a=1;
            checkN(a,@(x)(ischarstring(x)&&isvec(x)));
            checkN(a,@(x)(ischarstring(x)&&isabrakadabra(x)));
            %
            a=true;
            checkP(a,@(x)(islogical(x)&&isscalar(x)));
            a=struct();
            checkP(a,@(x)(isstruct(x)&&isscalar(x)));
            %
            a={'a','b'};
            checkP(a,@(x)(iscellofstrvec(x)));
            a={'a','b';'d','e'};
            checkP(a,@(x)(iscellofstrvec(x)));
            a={'a','b'};
            checkP(a,@(x)(iscellofstring(x)));
            a={'a','b';'d','e'};
            checkP(a,@(x)iscellofstring(x));
            a={'a','b';'d','esd'.'};
            checkN(a,@(x)iscellofstring(x));
            %
            a={@(x)1,@(x)2};
            checkP(a,@(x)iscelloffunc(x));
            a={@(x)1,'@(x)2'};
            checkN(a,@iscelloffunc);
            %
            checkNE('','myMessage',a,@iscelloffunc,...
                'errorMessage','myMessage');
            checkNE('wrongType:wrongSomething','myMessage',a,...
                @iscelloffunc,...
                'errorMessage','myMessage','errorTag',...
                'wrongType:wrongSomething');
            checkNE('wrongType:wrongSomething','',a,@iscelloffunc,...
                'errorTag','wrongType:wrongSomething');
            %
            function checkN(x,typeSpec,varargin)
                checkNE('','',x,typeSpec,varargin{:});
                
            end
            %
            function checkNE(errorTag,errorMessage,x,typeSpec,varargin)
                import modgen.common.type.simple.lib.*;
                if isempty(errorTag)
                    errorTag=':wrongInput';
                end
                if isempty(errorMessage)
                    addArgList={};
                else
                    addArgList={errorMessage};
                end
                self.runAndCheckError(...
                    ['modgen.common.checkvar(x,',...
                    'typeSpec,varargin{:})'],...
                    errorTag,addArgList{:});
                if ischar(typeSpec)
                    fHandle=eval(['@(x)(',typeSpec,')']);
                else
                    fHandle=typeSpec;
                end
                %
                self.runAndCheckError(...
                    ['modgen.common.checkvar(x,',...
                    'fHandle,varargin{:})'],...
                    errorTag,addArgList{:});
            end
            %
            function checkP(x,typeSpec,varargin)
                import modgen.common.type.simple.lib.*;
                modgen.common.checkvar(x,typeSpec,varargin{:});
                if ischar(typeSpec)
                    fHandle=eval(['@(x)(',typeSpec,')']);
                else
                    fHandle=typeSpec;
                end
                modgen.common.checkvar(x,fHandle,varargin{:});
            end
            
        end
        %
        
        function testThrowWarn(~)
            check('wrongInput','test message');
            check('wrongInput',...
                'test \n message C:\\SomeFolder\\sdf/sdf/sdfsdf');
            function check(identifier,message)
                ID_STR=...
                    ['MODGEN:COMMON:TEST:MLUNIT_TEST_COMMON:TESTTHROWWARN:',...
                    identifier];
                %
                lastwarn('');
                modgen.common.throwwarn('wrongInput',message);
                [lastMsg,lastId]=lastwarn();
                mlunitext.assert_equals(true,isequal(sprintf(message),lastMsg));
                mlunitext.assert_equals(true,isequal(ID_STR,lastId));
            end
        end
        function self=testThrowError(self)
            check('wrongInput','test message');
            check('wrongInput',...
                'test \ message C:\SomeFolder\sdf/sdf/sdfsdf');
            function check(identifier,message)
                meExpObj=modgen.common.throwerror(identifier,message);
                try
                    modgen.common.throwerror(identifier,message);
                catch meObj
                    mlunitext.assert_equals(true,isequal(meObj.identifier,meExpObj.identifier));
                    mlunitext.assert_equals(true,isequal(meObj.message,meExpObj.message));
                    mlunitext.assert_equals(true,isequal(meObj.cause,meExpObj.cause));
                end
            end
        end
        function testGenFileName(~)
            resStr=modgen.common.genfilename('sdfsdfsdf.;:sdfd');
            expStr='sdfsdfsdf.;_sdfd';
            mlunitext.assert_equals(true,isequal(resStr,expStr));
        end
        function testInd2SubMat(~)
            sizeVec=[2,3];
            indVec=1:6;
            %
            nDims=length(sizeVec);
            indSubList=cell(1,nDims);
            indMat=modgen.common.ind2submat(sizeVec,indVec);
            [indSubList{:}]=ind2sub(sizeVec,indVec.');
            indExpMat=[indSubList{:}];
            mlunitext.assert_equals(true,isequal(indMat,indExpMat));
        end
        %
        function self=test_ismembercellstr(self)
            import modgen.common.ismembercellstr;
            aList={'asdfsdf','sdfsfd','sdfsdf','sdf'};
            bList={'sdf','sdfsdf','ssdfsfsdfsd','sdf'};
            [isTVec,indLVec]=ismember(aList,bList,'legacy');
            [isTOVec,indLOVec]=ismembercellstr(aList,bList,true);
            mlunitext.assert_equals(true,isequal(isTVec,isTOVec));
            mlunitext.assert_equals(true,isequal(indLVec,indLOVec));
            %
            [isTOVec,indLOVec]=ismembercellstr(aList,bList);
            mlunitext.assert_equals(true,isequal([false false true true],isTOVec));
            mlunitext.assert_equals(true,isequal([0 0 2 1],indLOVec));
            %
            [isTOVec,indLOVec]=ismembercellstr(aList,'sdfsfd');
            mlunitext.assert_equals(true,isequal([false true false false],isTOVec));
            mlunitext.assert_equals(true,isequal([0 1 0 0],indLOVec));
            %
            [isTOVec,indLOVec]=ismembercellstr('sdfsfd',aList);
            mlunitext.assert_equals(true,isequal(true,isTOVec));
            mlunitext.assert_equals(true,isequal(2,indLOVec));            
            [isTOVec,indLOVec]=ismembercellstr('sdfsfd','sdfsfd');
            mlunitext.assert_equals(true,isTOVec);
            mlunitext.assert_equals(indLOVec,1);
            [isTOVec,indLOVec]=ismembercellstr('sdfsfd','sdfsf');
            mlunitext.assert_equals(false,isTOVec);
            mlunitext.assert_equals(indLOVec,0);
            %
            [isTOVec,indLOVec]=ismembercellstr('alpha',{'a','b','c'});
            mlunitext.assert_equals(false,isTOVec);
            mlunitext.assert_equals(indLOVec,0);
            %
            [isTOVec,indLOVec]=ismembercellstr({'a','b','c'},'alpha');            
            mlunitext.assert_equals(true,isequal(false(1,3),isTOVec));
            mlunitext.assert_equals(true,isequal(zeros(1,3),indLOVec));
            %
        end
        function self=test_isunique(self)
            mlunitext.assert_equals(false,modgen.common.isunique([1 1]));
            mlunitext.assert_equals(true,modgen.common.isunique([1 2]));
        end
        function self=test_cell2sepstr(self)
            check(1000,-1,{'1000'});
            check(1000,4,{'1000'});
            check(1000,3,{'1e+003','1e+03'});
            function check(value,numPrecision,expStr)
                resStr=modgen.cell.cell2sepstr([],num2cell(value),'_',...
                    'numPrecision',numPrecision);
                mlunitext.assert_equals(true,any(strcmp(expStr,resStr)));
            end
        end

        function self = test_cellfunallelem(self)
            inpCell=repmat({rand(7,7,7)<10},4*500,2);
            %
            self.aux_test_cellfunallelem(inpCell,@all);
            self.aux_test_cellfunallelem(inpCell,@any);
            %
            inpCell=repmat({rand(7,7,7)},4*500,2);
            self.aux_test_cellfunallelem(inpCell,@max);
            self.aux_test_cellfunallelem(inpCell,@min);
        end
        function self=aux_test_cellfunallelem(self,inpCell,hFunc)
            import modgen.common.cellfunallelem;
            %tic;
            res=cellfunallelem(hFunc,inpCell);
            %toc;
            resCheck=cellfun(@(x)hFunc(x(:)),inpCell);
            mlunitext.assert_equals(isequal(res,resCheck),true);
            %
            %tic;
            res=cellfunallelem(hFunc,inpCell,'UniformOutput',false);
            %toc;
            resCheck=cellfun(@(x)hFunc(x(:)),inpCell,'UniformOutput',false);
            mlunitext.assert_equals(isequal(res,resCheck),true);
        end
        %
        function self=test_subreffrontdim(self)
            inp=[1 2;3 4];
            res=modgen.common.subreffrontdim(inp,1);
            mlunitext.assert_equals(res,[1 2]);
        end
        %
        function self=test_num2cell(self)
            inpArray=rand(3,20);
            self.aux_test_num2cell(inpArray);
            %
            inpMat=rand(2,3,4);
            resCellEthalon=num2cell(inpMat);
            resCell=modgen.common.num2cell(inpMat);
            mlunitext.assert_equals(true,isequal(resCell,resCellEthalon));            
        end
        %
        function self=test_num2cell_empty(self)
            inpArray=zeros(3,0);
            self.aux_test_num2cell(inpArray);
        end
        %
        function self=aux_test_num2cell(self,inpArray)
            resCellEthalon={inpArray(1,:);inpArray(2,:);inpArray(3,:)};
            resCell=modgen.common.num2cell(inpArray,2);
            mlunitext.assert_equals(true,isequal(resCell,resCellEthalon));
            %
        end

        function self=test_iscelllogical(self)
            isTrue=modgen.common.iscelllogical({true,false});
            mlunitext.assert_equals(true,isTrue);
            isTrue=modgen.common.iscelllogical({});
            mlunitext.assert_equals(false,isTrue);
        end
        function self=aux_test_iscellnumeric(self,isOk,isEmpty)
            sizeVec=[1 1];
            typeList={'single','double','int8','int16','int32','int64'};
            for iType=1:length(typeList)
                obj={modgen.common.createarray(typeList{iType},sizeVec)};
                if isEmpty
                    obj(:)=[];
                end
                
                isTrue=modgen.common.iscellnumeric(obj);
                mlunitext.assert_equals(isOk,isTrue,...
                    ['failed for type ',typeList{iType}]);
            end
        end
        function self=test_iscellnumeric(self)
            self.aux_test_iscellnumeric(true,false);
            self.aux_test_iscellnumeric(false,true);
        end
        %
        function self=test_isvec(self)
            isPositive=modgen.common.iscol(rand(10,1));
            mlunitext.assert_equals(isPositive,true);
            %
            isPositive=modgen.common.iscol(rand(10,2));
            mlunitext.assert_equals(isPositive,false);
            %
            isPositive=modgen.common.iscol(zeros(0,1));
            mlunitext.assert_equals(isPositive,true);
            %
            isPositive=modgen.common.iscol(zeros(1,0));
            mlunitext.assert_equals(isPositive,false);
            %
            isPositive=modgen.common.iscol(zeros(0,0));
            mlunitext.assert_equals(isPositive,false);
            %
            isPositive=modgen.common.isvec(rand(10,1));
            mlunitext.assert_equals(isPositive,true);
            isPositive=modgen.common.isvec(rand(1,10));
            mlunitext.assert_equals(isPositive,true);
            isPositive=modgen.common.isvec(rand(1,1,10));
            mlunitext.assert_equals(isPositive,false);
            %
            mlunitext.assert_equals(modgen.common.isrow(rand(10,1)),false);
            mlunitext.assert_equals(modgen.common.isrow(rand(1,10)),true);
            mlunitext.assert_equals(modgen.common.isrow([]),false);
            %
            mlunitext.assert_equals(modgen.common.isrow(zeros(0,1)),false);
            mlunitext.assert_equals(modgen.common.isrow(zeros(1,0)),true);
            %
            mlunitext.assert_equals(modgen.common.iscol(rand(10,1)),true);
            mlunitext.assert_equals(modgen.common.iscol(rand(1,10)),false);
            mlunitext.assert_equals(modgen.common.iscol([]),false);
            %
            mlunitext.assert_equals(modgen.common.isrow(rand(1,1,2)),false);
        end
        function self=test_error(self)
            inpArgList={'myTag','myMessage %d',1};
            self.runAndCheckError(...
                    'modgen.common.test.aux.testerror(inpArgList{:})',...
                    'MODGEN:COMMON:TEST:AUX:TESTERROR:myTag','myMessage 1');            
        end
        function test_parseparext_touch(self)
            [reg,isRegSpec,putStorageHook,getStorageHook]=...
                modgen.common.parseparext(...
                {},{...
                'putStorageHook','getStorageHook';...
                @(x,y)x,@(x,y)x;...
                @(x)isa(x,'function_handle'),@(x)isa(x,'function_handle')},...
                'regCheckList',...
                {@(x)isa(x,'modgen.struct.changetracking.AStructChangeTracker')});            
        end
        function self=test_parseparext_obligprop(self)
            inpProp={1,'aa',1,'bb',2,'cc',3};
            isObligatoryPropVec=[false false false];
            check();
            isObligatoryPropVec=[false false true];
            self.runAndCheckError(@check,':wrong');
            function check()
            [reg,isRegSpec,prop,isPropSpec]=...
                modgen.common.parseparext(inpProp,{'aa','bb','dd'},...
                'propRetMode','list','isObligatoryPropVec',...
                isObligatoryPropVec);
            end
        end
        function test_parseparams_duplicate(self)
            self.runAndCheckError(@check,...
                'wrongInput:duplicatePropertiesSpec');
            self.runAndCheckError(@check1,...
                'wrongInput:duplicatePropertiesSpec');            
            function check()
            modgen.common.parseparams(...
                {1,2,'prop1',1,'prop2',2,'prop2',3},{'prop1','prop2'},[0 2]);
            end
            function check1()
            modgen.common.parseparams(...
                {1,2,'prop1',1,'prop2',2,'prop2',3});
            end            
        end    
        function test_parseparext_isdefspecvec(self)
            self.runAndCheckError(@check,...
                'wrongInput:defPropSpecVecNotInListMode');
            self.runAndCheckError(@check2,...
                'wrongInput:defPropSpecVecNoDefValues');            
            %
            [regList,isRegSpecVec,propList,isPropSpecVec]=check3();
            disp(1);
            expPropList={'prop1',1,'prop3',2};
            expRegList={1,2};
            isExpRegSpecVec=[true,true];
            isExpPropSpecVec=[false,false,false];
            %
            expCompare();
            %
            [regList,isRegSpecVec,propList,isPropSpecVec]=check4();
            %
            expPropList={'prop1',1,'prop2',1,'prop3',2};
            %
            expCompare();
            function expCompare()
                mlunitext.assert(true,isequal(expRegList,regList));
                mlunitext.assert(true,isequal(expPropList,propList));
                mlunitext.assert(true,isequal(isExpRegSpecVec,isRegSpecVec));
                mlunitext.assert(true,isequal(isExpPropSpecVec,isPropSpecVec));
            end
            function check()
            modgen.common.parseparext(...
                {1,2,'prop1',1},...
                {'prop1','prop2','prop3';...
                [],1,2},'isDefaultPropSpecVec',[false,false,true],'propRetMode','separate');
            end  
            function check2()
            modgen.common.parseparext(...
                {1,2,'prop1',1},...
                {'prop1','prop2','prop3'},'isDefaultPropSpecVec',[false,false,true],'propRetMode','list');
            end
            function [regList,isRegSpec,propList,isPropSpec]=check3()
            [regList,isRegSpec,propList,isPropSpec]=modgen.common.parseparext(...
                {1,2,'prop1',1},...
                {'prop1','prop2','prop3';...
                [],1,2},'isDefaultPropSpecVec',[false,false,true],'propRetMode','list');
            end
            function [regList,isRegSpec,propList,isPropSpec]=check4()
                [regList,isRegSpec,propList,isPropSpec]=modgen.common.parseparext(...
                {1,2,'prop1',1},...
                {'prop1','prop2','prop3';...
                [],1,2},'propRetMode','list');
            end                
        end
        function test_parseparext_duplicate(self)
            self.runAndCheckError(@check,...
                'wrongInput:duplicatePropertiesSpec');
            self.runAndCheckError(@check1,...
                'wrongInput:duplicatePropertiesSpec');            
            function check()
            modgen.common.parseparext(...
                {1,2,'prop1',1,'prop2',2,'prop2',3},{'prop1','prop2'},[0 2]);
            end
            function check1()
            modgen.common.parseparext(...
                {1,2,'prop1',1,'prop2',2,'prop2',3},[],[0 2],...
                'propRetMode','list');
            end
            modgen.common.parseparext({'prop0',1,'prop1',1,'prop2',2},...
                {'prop1','prop2'},[0 2]);
        end
        function self=test_parseparext_simple(self)
            %
            inpReg={1};
            inpFirstProp={'aa',1};
            inpSecProp={'bb',2,'cc',3};
            inpProp=[inpFirstProp,inpSecProp];
            self.runAndCheckError(...
                    'modgen.common.parseparext(inpReg,[],''propRetMode'',''separate'')',...
                    ':wrong');
            %
            [reg,isRegSpec,prop,isPropSpec]=...
                modgen.common.parseparext([inpReg,inpProp],[],...
                'propRetMode','list');
            mlunitext.assert_equals(3,length(isPropSpec));
            mlunitext.assert_equals(true,all(isPropSpec));
            mlunitext.assert_equals(true,isRegSpec);            
            mlunitext.assert_equals(true,isequal(reg,inpReg));%
            mlunitext.assert_equals(true,isequal(prop,inpProp));%
            %
            [reg,isRegSpec,prop,isPropSpec]=...
                modgen.common.parseparext([inpReg,inpProp],{'bb','cc'},...
                'propRetMode','list');
            mlunitext.assert_equals([true,true,true],isRegSpec);            
            mlunitext.assert_equals(true,isequal(reg,[inpReg,inpFirstProp]));%
            mlunitext.assert_equals(true,isequal(prop,inpSecProp));%  
            mlunitext.assert_equals(true,all(isPropSpec));
            mlunitext.assert_equals(2,length(isPropSpec));
            %
            [reg,isRegSpec,prop,isPropSpec]=...
                modgen.common.parseparext({},{'bb','cc'},...
                'propRetMode','list');
            mlunitext.assert_equals(true,isempty(reg));
            mlunitext.assert_equals(true,isempty(prop));
            mlunitext.assert_equals(true,isempty(isRegSpec));
            mlunitext.assert_equals(false,any(isPropSpec));
            mlunitext.assert_equals(2,length(isPropSpec));
            %
            [reg,isRegSpec,prop,isPropSpec]=...
                modgen.common.parseparext({},[],...
                'propRetMode','list');
            mlunitext.assert_equals(true,isempty(reg));
            mlunitext.assert_equals(true,isempty(prop));
            mlunitext.assert_equals(true,isempty(isRegSpec));            
            mlunitext.assert_equals(true,isempty(isPropSpec));
            %
            nRegs=1;
            regDefList={1,3};
            nRegExpMax=[0,2];
            initInpArgList={1,'joinByInst',true,'keepJoinId',true};
            propCheckMat={'joinByInst','keepJoinId';...
                false,false;...
                'isscalar(x)&&islogical(x)','isscalar(x)&&islogical(x)'};
            %
            checkMaster();
            nRegExpMax=[1,2];
            checkMaster();
            %
            nRegExpMax=[0,1];
            checkN('regCheckList',{'true','true'});
            nRegExpMax=1;
            checkN('regCheckList',{'true','true'});
            %
            propCheckMat={'joinByInst','keepJoinId';...
                false,false;...
                @(x)isscalar(x)&&islogical(x),...
                @(x)isscalar(x)&&islogical(x)};
            nRegExpMax=[0,2];
            checkMaster();
            nRegExpMax=[1,2];
            checkMaster();
            nRegExpMax=[0,2];
            nRegs=0;
            initInpArgList={'joinByInst',true,'keepJoinId',true};
            checkMaster();
            %
            function checkMaster()
                checkP();
                checkP('regCheckList',{'true'});
                checkP('regCheckList',{@true});
                checkN('regCheckList','true');
                if nRegs>=1
                    checkN('regCheckList',{'false'});
                end
                checkP('regCheckList',{'true','true'});
                checkP('regCheckList',{@true,@true});                
            end
            function checkN(varargin)
                inpArgList={initInpArgList,propCheckMat,nRegExpMax,...
                    varargin{:}};
                self.runAndCheckError(...
                    'modgen.common.parseparext(inpArgList{:})',...
                    ':wrong');
            end
            function checkP(varargin)
                [reg1,isRegSpec1Vec]=checkPInt(varargin{:});
                [reg2,isRegSpec2Vec]=checkPInt(varargin{:},'regDefList',regDefList);
                if nRegs>=1
                    mlunitext.assert_equals(true,isequal(reg1{1},reg2{1}));
                    mlunitext.assert_equals(true,...
                        isequal(isRegSpec1Vec(1),isRegSpec2Vec(1)));
                end
                mlunitext.assert_equals(false,isRegSpec2Vec(2));
                mlunitext.assert_equals(true,isequal(nRegs,length(isRegSpec1Vec)));
                mlunitext.assert_equals(true,isequal(2,length(isRegSpec2Vec)));
                mlunitext.assert_equals(true,isequal(nRegs,length(reg1)));
                mlunitext.assert_equals(true,isequal(2,length(reg2)));
                mlunitext.assert_equals(true,isequal(3,reg2{2}));
                % 
                inpArgList={initInpArgList,...
                    varargin{:},'regDefList',[regDefList,4]};
                self.runAndCheckError(...
                    'modgen.common.parseparext(inpArgList{:})',...
                    ':wrong');                
                %
                function [reg,isRegSpecVec]=checkPInt(varargin)
                    [reg,isRegSpecVec,isJoinByInst,isJoinIdKept]=...
                        modgen.common.parseparext(initInpArgList,...
                        propCheckMat,nRegExpMax,...
                        varargin{:});
                    if nRegs>=1
                        mlunitext.assert_equals(true,isRegSpecVec(1));
                        mlunitext.assert_equals(true,isequal(reg(1:nRegs),{1}));
                    else
                        [~,prop]=modgen.common.parseparams(varargin,{'regDefList'});
                        if isempty(prop)
                            mlunitext.assert_equals(true,isempty(isRegSpecVec));
                            mlunitext.assert_equals(true,isempty(reg));
                        else
                            mlunitext.assert_equals(false,any(isRegSpecVec))
                            mlunitext.assert_equals(length(prop{2}),...
                                length(reg));
                        end
                    end
                    %
                    mlunitext.assert_equals(true,isJoinByInst);
                    mlunitext.assert_equals(true,isJoinIdKept);
                end
            end
            
        end
        function self=test_parseparams(self)
            [reg,prop]=getparse({'alpha'});
            mlunitext.assert_equals(true,isequal(reg,{'alpha'}));
            mlunitext.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({'alpha','beta',1});
            mlunitext.assert_equals(true,isequal(reg,{'alpha'}));
            mlunitext.assert_equals(true,isequal(prop,{'beta',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1});
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1,3}));
            mlunitext.assert_equals(true,isequal(prop,{'beta',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1},{'alpha'});
            mlunitext.assert_equals(true,isequal(reg,{3,'beta',1}));
            mlunitext.assert_equals(true,isequal(prop,{'alpha',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1},{});
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1,3,'beta',1}));
            mlunitext.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1,'gamma',1},'gamma');
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1,3,'beta',1}));
            mlunitext.assert_equals(true,isequal(prop,{'gamma',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'gamma',1,'beta',1},'gamma');
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1,3,'beta',1}));
            mlunitext.assert_equals(true,isequal(prop,{'gamma',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1,'gamma',1},'Gamma');
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1,3,'beta',1}));
            mlunitext.assert_equals(true,isequal(prop,{'gamma',1}));
            %
            [reg,prop]=getparse({'alpha',1},'beta');
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1}));
            mlunitext.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({'alpha',1},'beta',[0 2]);
            mlunitext.assert_equals(true,isequal(reg,{'alpha',1}));
            mlunitext.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({1,'alpha'},'alpha');
            mlunitext.assert_equals(true,isequal(reg,{1,'alpha'}));
            mlunitext.assert_equals(true,isequal(prop,{}));
            %
            [reg,prop]=getparse(...
                {1,'alpha',3,'beta',3,'gamma'},{'alpha','gamma'});
            mlunitext.assert_equals(true,isequal(reg,{1,'beta',3,'gamma'}));
            mlunitext.assert_equals(true,isequal(prop,{'alpha',3}));
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
                    mlunitext.assert_equals(true,isequal(reg,reg1));
                    isEqual=isequal(propNameList,...
                        propInpNameList)||isempty(propNameList)&&...
                        isempty(propInpNameList);
                    mlunitext.assert_equals(true,isEqual);
                    pNameList=propNameList(isSpecVec);
                    pValList=propValList(isSpecVec);
                    inpArgList=[pNameList;pValList];
                    s1=struct(inpArgList{:});
                    s2=struct(prop{:});
                    isEqual=isequal(s1,s2);
                    mlunitext.assert_equals(true,isEqual);
                    %
                    if ~all(isSpecVec)
                        defValList=num2cell(rand(size(propNameList)));
                        [reg2,~,outCell{:}]=...
                            modgen.common.parseparext(argList,...
                            [propNameList;defValList],varargin{2:end});
                        mlunitext.assert_equals(true,isequal(reg,reg2));
                        [propValList,isSpecVec]=getval(outCell);
                        isEqual=isequal(propValList(~isSpecVec),...
                            defValList(~isSpecVec));
                        mlunitext.assert_equals(true,isEqual);
                        %
                        checkStrList=repmat({'false'},size(defValList));
                        checkStrList(isSpecVec)={'true'};
                        [reg3,~,outCell{:}]=...
                            modgen.common.parseparext(argList,...
                            [propNameList;defValList;...
                            checkStrList],varargin{2:end});
                        [propValList3,isSpecVec3]=getval(outCell);
                        mlunitext.assert_equals(true,isequal(reg,reg3));
                        mlunitext.assert_equals(true,isequal(propValList3,propValList));
                        mlunitext.assert_equals(true,isequal(isSpecVec,isSpecVec3));
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
            mlunitext.assert_equals(true,isequal(reg1,reg2));
            mlunitext.assert_equals(true,isequal(prop1,prop2));
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
        function self=test_getfirstdimsize(self)
            expSizeVec=[2,3];
            inpArray=rand([expSizeVec,4,5]);
            mlunitext.assert_equals(expSizeVec,...
                modgen.common.getfirstdimsize(inpArray,2));
            expSizeVec=[2,3,1];
            inpArray=rand([expSizeVec,1,1]);
            mlunitext.assert_equals(expSizeVec,...
                modgen.common.getfirstdimsize(inpArray,3));
            mlunitext.assert_equals([expSizeVec,[1 1]],...
                modgen.common.getfirstdimsize(inpArray,5));
            mlunitext.assert_equals(true,...
                isempty(modgen.common.getfirstdimsize(inpArray,0)));
            self.runAndCheckError(...
                'modgen.common.getfirstdimsize(inpArray,-1)',...
                ':wrongInput');
            %
        end
        function self=test_checksize(self)
            
            mlunitext.assert_equals(true,modgen.common.checksize(rand(2,3),[2,3,1]));
            mlunitext.assert_equals(true,modgen.common.checksize(rand(2,3),[2,3]));
            mlunitext.assert_equals(false,modgen.common.checksize(rand(2,4),[2,3]));
            mlunitext.assert_equals(false,modgen.common.checksize(rand(2,4,5),[2,4]));
            mlunitext.assert_equals(true,modgen.common.checksize([],[]));
            mlunitext.assert_equals(false,modgen.common.checksize(1,[]));
        end
        function self=test_cat(self)
            typeList={'int8','double','logical','struct'};
            for iType=1:length(typeList)
                for jType=1:length(typeList)
                    iObj=modgen.common.createarray(typeList{iType},[]);
                    jObj=modgen.common.createarray(typeList{jType},[]);
                    res=modgen.common.cat(1,iObj,jObj);
                    mlunitext.assert_equals(true,...
                        isa(res,typeList{iType}));
                end
            end
        end
        function self=test_getcallernameext(self)
            testClassA=GetCallerNameExtTestClassA;
            [methodName className]=getCallerInfo(testClassA);
            mlunitext.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassA')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            testClassA=simpleMethod(testClassA);
            [methodName className]=getCallerInfo(testClassA);
            mlunitext.assert_equals(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            testClassA=subFunctionMethod(testClassA);
            [methodName className]=getCallerInfo(testClassA);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            testClassA=subFunctionMethod2(testClassA);
            [methodName className]=getCallerInfo(testClassA);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            testClassA=subFunctionMethod3(testClassA);
            [methodName className]=getCallerInfo(testClassA);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            %
            testClassB=GetCallerNameExtTestClassB;
            [methodName className]=getCallerInfo(testClassB);
            mlunitext.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassB')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            simpleMethod(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunitext.assert_equals(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            subFunctionMethod(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            subFunctionMethod2(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            subFunctionMethod3(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            %
            testClassB=getcallernameexttest.GetCallerNameExtTestClassB;
            [methodName className]=getCallerInfo(testClassB);
            mlunitext.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassB')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            simpleMethod(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunitext.assert_equals(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            subFunctionMethod(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            subFunctionMethod2(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            subFunctionMethod3(testClassB);
            [methodName className]=getCallerInfo(testClassB);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            %
            testClassC=GetCallerNameExtTestClassC;
            [methodName className]=getCallerInfo(testClassC);
            mlunitext.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassB')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            testClassC=GetCallerNameExtTestClassC(false);
            [methodName className]=getCallerInfo(testClassC);
            mlunitext.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassC')&&...
                isequal(className,'GetCallerNameExtTestClassC'));
            simpleMethod(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunitext.assert_equals(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'GetCallerNameExtTestClassC'));
            subFunctionMethod(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassC'));
            subFunctionMethod2(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            subFunctionMethod3(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'GetCallerNameExtTestClassC'));
            %
            testClassC=getcallernameexttest.GetCallerNameExtTestClassC;
            [methodName className]=getCallerInfo(testClassC);
            mlunitext.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassB')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            testClassC=getcallernameexttest.GetCallerNameExtTestClassC(false);
            [methodName className]=getCallerInfo(testClassC);
            mlunitext.assert_equals(true,...
                isequal(methodName,'GetCallerNameExtTestClassC')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassC'));
            simpleMethod(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunitext.assert_equals(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassC'));
            subFunctionMethod(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassC'));
            subFunctionMethod2(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            subFunctionMethod3(testClassC);
            [methodName className]=getCallerInfo(testClassC);
            mlunitext.assert_equals(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassC'));
            %
            methodName='';className='';
            s_getcallernameext_test;
            mlunitext.assert_equals(true,...
                isequal(methodName,'s_getcallernameext_test')&&...
                isequal(className,''));
            %
            methodName='';className='';
            getcallernameexttest.s_getcallernameext_test;
            mlunitext.assert_equals(true,...
                isequal(methodName,'getcallernameexttest.s_getcallernameext_test')&&...
                isequal(className,''));
            %
            [methodName className]=getcallernameext_simplefunction();
            mlunitext.assert_equals(true,...
                isequal(methodName,'getcallernameext_simplefunction')&&...
                isequal(className,''));
            [methodName className]=getcallernameext_subfunction();
            mlunitext.assert_equals(true,...
                isequal(methodName,'getcallernameext_subfunction/subfunction')&&...
                isequal(className,''));
            [methodName className]=getcallernameext_subfunction2();
            mlunitext.assert_equals(true,...
                isequal(methodName,'getcallernameext_subfunction2/subfunction')&&...
                isequal(className,''));
            [methodName className]=getcallernameext_subfunction3();
            mlunitext.assert_equals(true,...
                isequal(methodName,'getcallernameext_subfunction3/subfunction/subfunction2')&&...
                isequal(className,''));
            %
            [methodName className]=getcallernameexttest.getcallernameext_simplefunction();
            mlunitext.assert_equals(true,...
                isequal(methodName,'getcallernameexttest.getcallernameext_simplefunction')&&...
                isequal(className,''));
            [methodName className]=getcallernameexttest.getcallernameext_subfunction();
            mlunitext.assert_equals(true,...
                isequal(methodName,'getcallernameexttest.getcallernameext_subfunction/subfunction')&&...
                isequal(className,''));
            [methodName className]=getcallernameexttest.getcallernameext_subfunction2();
            mlunitext.assert_equals(true,...
                isequal(methodName,'getcallernameexttest.getcallernameext_subfunction2/subfunction')&&...
                isequal(className,''));
            [methodName className]=getcallernameexttest.getcallernameext_subfunction3();
            mlunitext.assert_equals(true,...
                isequal(methodName,'getcallernameexttest.getcallernameext_subfunction3/subfunction/subfunction2')&&...
                isequal(className,''));
        end
    end
end