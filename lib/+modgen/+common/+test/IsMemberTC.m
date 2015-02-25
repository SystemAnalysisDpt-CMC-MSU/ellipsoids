classdef IsMemberTC < mlunitext.test_case
    methods
        function self = IsMemberTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function self=testIsMemberJointAdv(self)
            import modgen.common.ismemberjoint;
            leftList={{1,2,nan},{1,2,3,nan}};
            rightList={{1,2,nan},{1,2,3,nan},{1,2,2,nan}};
            [isThereVec,indThereVec]=ismemberjoint({leftList},...
                {rightList},2);
            mlunitext.assert_equals(isThereVec,[true,true]);
            mlunitext.assert_equals(indThereVec,[1,2]);
        end
        function testByInputSize(~)
            N_ISMEMBER_OUTS=2;
            N_UNIQUE_OUTS=3;
            %%
            isMemberInpArgList={{[true,true,false],[1,2,0]},...
                {[1,2,3],[1,2]},N_ISMEMBER_OUTS};
            %
            isMemberInpArgList={{[false,true],[0,1]},...
                {{[1,2,3],[1,2]},{[1,2]}},...
                N_ISMEMBER_OUTS};
            checkMasterIsMember();            
            %
            isMemberInpArgList={{[false,true],[0,2]},...
                {{[1,2,3],[1,2]},{[1,2,4],[1,2]}},...
                N_ISMEMBER_OUTS};
            checkMasterIsMember();            
            %
            checkMasterIsMember();
            isMemberInpArgList={{[false,true,true],[0,2,1]},...
                {{'alpha','beta','gamma'},{'gamma','beta'}},...
                N_ISMEMBER_OUTS};
            checkMasterIsMember();
            %
            checkIsMember(@modgen.common.ismembercellstr);
            checkIsMemberObjects(false);
            checkIsMemberObjects(true);
            %%
            uniqInpArgList={{[1,2,3],[1;2;3],[1;2;3;3]},{[1,2,3,3]},...
                N_UNIQUE_OUTS};
            checkMasterUnique();
            uniqInpArgList={{{'alpha','beta','gamma'},[1;2;4],[1;2;2;3]},...
                {{'alpha','beta','beta','gamma'}},N_UNIQUE_OUTS};
            checkMasterUnique();
            checkUniqueObjects(true);
            checkUniqueObjects(false);
            %
            function checkIsMemberObjects(varargin)
                import modgen.common.test.aux.EntityFactory;
                isMemberInpArgList={{[true,true,true],[1,2,3]},...
                    {EntityFactory.create([1,2,3],varargin{:}),...
                    EntityFactory.create([1,2,3],varargin{:})},...
                    N_ISMEMBER_OUTS};
                checkMasterIsMember();                  
                %
                isMemberInpArgList={{[true,false,true],[2,0,1]},...
                    {EntityFactory.create([2,3,1],varargin{:}),...
                    EntityFactory.create([1,2],varargin{:})},...
                    N_ISMEMBER_OUTS};
                checkMasterIsMember();
                isMemberInpArgList={{true,2},...
                    {EntityFactory.create(2,varargin{:}),...
                    EntityFactory.create([1,2,3],varargin{:})},...
                    N_ISMEMBER_OUTS};
                checkMasterIsMember();
                isMemberInpArgList={{[false,true,false],[0,1,0]},...
                    {EntityFactory.create([2,3,1],varargin{:}),...
                    EntityFactory.create(3,varargin{:})},...
                    N_ISMEMBER_OUTS};
                checkMasterIsMember();
                %
                isMemberInpArgList={{[false,true,false],[0,1,0]},...
                    {EntityFactory.create([2,3,1],varargin{:}),...
                    EntityFactory.create(3,varargin{:})},...
                    N_ISMEMBER_OUTS};
                checkMasterIsMember();                  
            end
            function checkUniqueObjects(varargin)
                import modgen.common.test.aux.EntityFactory;
                uniqInpArgList={...
                    {EntityFactory.create([1,2,3],varargin{:}),[1;2;3],[1;2;3;1]},...
                    {EntityFactory.create([1,2,3,1],varargin{:})},N_UNIQUE_OUTS};
                checkMasterUnique();
            end
            %
            function checkMasterUnique()
                checkUniq(@modgen.common.uniquebyfunc);
                checkUniq(@(x)modgen.common.uniquebyfunc(x,@isequal));
                checkUniq(@(varargin)modgen.common.uniquebyfunc(...
                    varargin{:},@isequal,'mempreserve'));
                checkUniq(@(varargin)modgen.common.uniquebyfunc(...
                    varargin{:},@isequal,'memhungry'));
                %
                checkUniq(@fCallUniqueJoint);
                checkUniq({@(varargin)fCallUniqueJoint(varargin{:},2);...
                    @(varargin)fCallUniqueJoint(varargin{:},1)});
                checkUniq(@modgen.common.unique);
            end
            %
            function checkMasterIsMember()
                checkIsMember(@modgen.common.ismemberbyfunc);
                checkIsMember(@(varargin)modgen.common.ismemberbyfunc(...
                    varargin{:},@isequal));
                checkIsMember(@modgen.common.ismember);
                checkIsMember(@fCallIsMemberJoint);
            end
            function varargout=fCallIsMemberJoint(varargin)
                outList=cell(1,N_ISMEMBER_OUTS);
                inpArgList=cellfun(@(x){x},varargin,'UniformOutput',false);
                [outList{:}]=modgen.common.ismemberjoint(inpArgList{:});
                varargout=outList;
            end
            %
            function varargout=fCallUniqueJoint(varargin)
                outList=cell(1,N_UNIQUE_OUTS);
                [outList{:}]=modgen.common.uniquejoint({varargin{1}},...
                    varargin{2:end});
                outList{1}=outList{1}{1};
                varargout=outList;
            end
            function checkUniq(fUniq)
                check(fUniq,uniqInpArgList{:},1);
            end
            %
            function checkIsMember(fIsMember)
                check(fIsMember,isMemberInpArgList{:});
            end
            function check(fCall,outExpArgList,inpArgList,nArgOuts,...
                    nArgTransposed)
                if iscell(fCall)
                    %this is a list of functions
                    fPlain=fCall{1};
                    fTransposed=fCall{2};
                else
                    fPlain=fCall;
                    fTransposed=fCall;
                end
                %
                if nargin<5
                    nArgTransposed=nArgOuts;
                end
                outActList=cell(1,nArgOuts);
                outTranspList=outActList;
                [outActList{:}]=fPlain(inpArgList{:});
                %
                isOk=isequal(outExpArgList,outActList);
                    mlunitext.assert(isOk);
                %
                inpTranspArgList=cellfun(@transpose,inpArgList,...
                    'UniformOutput',false);
                [outTranspList{:}]=fTransposed(inpTranspArgList{:});
                outList=outTranspList;
                outList(1:nArgTransposed)=cellfun(@transpose,...
                    outTranspList(1:nArgTransposed),...
                    'UniformOutput',false);
                %
                isOk=isequal(outList,outActList);
                mlunitext.assert(isOk);
            end
        end
        %
        function testEqCallCount(~)
            N_OBJS_VEC=[3,2,5,12];
            for iCase=1:numel(N_OBJS_VEC)
                nObjs=N_OBJS_VEC(iCase);
                checkMaster(nObjs);
            end
            %
            function checkMaster(nObjs)
                import modgen.common.test.aux.EqualCallCounter;                
                %% NOT SORTABLE
                objVec=createObjVec(nObjs,false,'checkUniqueIsMember',false);
                nIsMemberJointCalls=EqualCallCounter.getNCalls(...
                    @()modgen.common.ismemberjoint({objVec},{objVec(2:end)}));
                mlunitext.assert_equals((nObjs-1)*(nObjs-1),nIsMemberJointCalls);
                %
                %EqualCallCounter.checkNotSortableCalls(objVec);
                %
                %% SORTABLE
                objVec=createObjVec(nObjs,true,'checkUniqueIsMember',false);
                EqualCallCounter.checkNotSortableCalls(objVec);
                %
                objVec=createObjVec(nObjs,true);
                EqualCallCounter.checkCalls(objVec,false);
                %
                function objVec=createObjVec(nElems,varargin)
                    objVec=modgen.common.test.aux.EntityFactory.create(...
                        1:nElems,varargin{:});
                end
            end
        end
        %
        function self=test_ismemberjoint_simple(self)
            import modgen.common.ismemberjoint;
            leftCell{1,1}=[1 2 3];
            leftCell{2,1}={'a','b','c'};
            leftCell{2,2}={'aa','bc','cc'};
            leftCell{1,2}=[3 4 2];
            %
            rightCell{1,1}=[1 2 3 1];
            rightCell{2,1}={'a','d','c','a'};
            rightCell{1,2}=[3 4 2 3];
            rightCell{2,2}={'aa','dc','cc','aa'};
            %
            [isMember,indMember]=ismemberjoint(leftCell,rightCell);
            
            expIsMember=logical([1,0,1]);
            expIndMember=[4,0,3];
            
            isOk=isequal(isMember,expIsMember) && isequal(indMember,expIndMember);
            mlunitext.assert_equals(true,isOk);
        end
        function self=test_ismemberjoint_empty(self)
            import modgen.common.ismemberjoint;
            [isMember,indMember]=ismemberjoint({[],[]},{[],[]});
            mlunitext.assert_equals(true,isempty(isMember));
            mlunitext.assert_equals(true,isempty(indMember));
            %
            [isMember,indMember]=ismemberjoint({zeros(10,0),false(10,0)},{zeros(5,0),false(5,0)},1);
            mlunitext.assert_equals(true,isequal(isMember,true(10,1)));
            mlunitext.assert_equals(true,isequal(indMember,repmat(5,10,1)));
        end
        function self=test_ismemberjoint(self)
            %
            leftCell={[1 2],{'a','b'};[3 4],{'c','d'}};
            rightCell={[1 2 3],{'a','b','c'};[3 4 5],{'c','d','m'}};
            isMemberVec=[];
            indMemberVec=[];
            %
            isMemberExpVec=[true true];
            indMemberExpVec=[1 2];
            superCheck({},{2});
            self.runAndCheckError(...
                '[isMemberVec,indMemberVec]=modgen.common.ismemberjoint(leftCell,rightCell,1);',...
                'wrongInput');
            %
            leftCell={[1 2;11 22],...
                {'a','b';'aa','bb'},...
                [3 4;33 44],...
                {'c','d';'cc','dd'}};
            rightCell={...
                [1 2 3;11 22 33],...
                {'a','b','c';'aa','bb','cc'},...
                [3 4 5;33 44 55],...
                {'c','d','m';'cc','dd','mm'}};
            superCheck({2});
            for iElem=1:numel(leftCell)
                leftCell{iElem}=transpose(leftCell{iElem});
                rightCell{iElem}=transpose(rightCell{iElem});
            end
            isMemberExpVec=transpose(isMemberExpVec);
            indMemberExpVec=transpose(indMemberExpVec);
            superCheck({1});
            %
            ethRightCell=rightCell;
            rightCell={nan(2,0),cell(2,0),nan(2,0),cell(2,0)};
            isMemberExpVec=false(1,2);
            indMemberExpVec=zeros(1,2);
            superCheck({2});
            rightCell={[],{},[],{}};
            self.runAndCheckError(...
                '[isMemberVec,indMemberVec]=modgen.common.ismemberjoint(leftCell,rightCell,2);',...
                ':wrongInput');
            %
            rightCell=ethRightCell;
            leftCell={nan(3,0),cell(3,0),nan(3,0),cell(3,0)};
            isMemberExpVec=false(1,0);
            indMemberExpVec=zeros(1,0);
            superCheck({2});
            leftCell={[],{},[],{}};
            self.runAndCheckError(...
                '[isMemberVec,indMemberVec]=modgen.common.ismemberjoint(leftCell,rightCell,2);',...
                ':wrongInput');
            %
            function superCheck(varargin)
                import modgen.common.ismemberjoint;
                for iArg=1:nargin
                    [isMemberVec,indMemberVec]=...
                        ismemberjoint(leftCell,rightCell,varargin{iArg}{:});
                    check();
                end
            end
            function check()
                mlunitext.assert_equals(true,...
                    isequal(isMemberVec,isMemberExpVec));
                %
                mlunitext.assert_equals(true,...
                    isequal(indMemberVec,indMemberExpVec));
            end
        end
        %
        function self=test_uniquejoint(self)
            import modgen.common.uniquejoint;
            inpCell{1,1}=[1 2 1];
            inpCell{2,1}={'a','b','a'};
            inpCell{1,2}=[3 5 3];
            inpCell{2,2}={'ddd','c','ddd'};
            %
            expResCell{1,1}=[1,2];
            expResCell{1,2}=[3,5];
            expResCell{2,1}={'a','b'};
            expResCell{2,2}={'ddd','c'};
            expIndList={[3;2],[1;2;1]};
            %
            resIndList=cell(1,2);
            [resCell,resIndList{:}]=uniquejoint(inpCell);
            check_results();
            [resCell,resIndList{:}]=uniquejoint(inpCell,2);
            check_results();
            %
            inpCell=cellfun(@transpose,inpCell,'UniformOutput',false);
            expResCell=cellfun(@transpose,expResCell,'UniformOutput',false);
            %
            [resCell,resIndList{:}]=uniquejoint(inpCell);
            check_results();
            [resCell,resIndList{:}]=uniquejoint(inpCell,1);
            check_results();
            %
            inpCell{1,1}=[1 3;2 4;1 3];
            inpCell{2,1}=cat(3,{'a','b';'b','a';'a','b'},{'c','d';'e','f';'c','d'});
            inpCell{1,2}=cat(3,[3 4 2;5 6 7;3 4 2],[1 3 2;7 4 5;1 3 2]);
            inpCell{2,2}={'ddd';'c';'ddd'};
            inpCell{1,3}=zeros(3,0);
            inpCell{2,3}=false(3,4,0,2);
            %
            expResCell{1,1}=[1 3;2 4];
            expResCell{1,2}=cat(3,[3 4 2;5 6 7],[1 3 2;7 4 5]);
            expResCell{1,3}=zeros(2,0);
            expResCell{2,1}=cat(3,{'a','b';'b','a'},{'c','d';'e','f'});
            expResCell{2,2}={'ddd';'c'};
            expResCell{2,3}=false(2,4,0,2);
            expIndList={[3;2],[1;2;1]};
            %
            [resCell,resIndList{:}]=uniquejoint(inpCell,1);
            check_results();
            %
            inpCell=cellfun(@(x)permute(x,[2 1 3:ndims(x)]),...
                inpCell,'UniformOutput',false);
            expResCell=cellfun(@(x)permute(x,[2 1 3:ndims(x)]),...
                expResCell,'UniformOutput',false);
            %
            [resCell,resIndList{:}]=uniquejoint(inpCell,2);
            check_results();
            
            function check_results()
                isOk= isequal(resIndList,expIndList)...
                    && isequal(resCell,expResCell);
                mlunitext.assert_equals(true,isOk);
            end
        end
        function self=test_uniquejoint_empty(self)
            import modgen.common.uniquejoint;
            expResCell={zeros(1,0),zeros(1,0)};
            expIndList={1,ones(1,10)};
            resIndList=cell(1,2);
            %
            inpCell={zeros(10,0),zeros(10,0)};
            [resCell,resIndList{:}]=uniquejoint(inpCell);
            check_results();
            %
            inpCell={zeros(10,0).',zeros(10,0).'};
            expResCell={zeros(1,0).',zeros(1,0).'};
            [resCell,resIndList{:}]=uniquejoint(inpCell);
            check_results();
            %
            inpCell={[],[]};
            expResCell=inpCell;
            expIndList={[],[]};
            [resCell,resIndList{:}]=uniquejoint(inpCell);
            check_results();
            %
            inpCell={zeros(0,2,5,3),false(0,4)};
            expResCell=inpCell;
            expIndList={nan(0,1),nan(0,1)};
            [resCell,resIndList{:}]=uniquejoint(inpCell,1);
            %
            inpCell={zeros(2,5,0,3),false(4,2,0)};
            expResCell=inpCell;
            expIndList={nan(1,0),nan(1,0)};
            [resCell,resIndList{:}]=uniquejoint(inpCell,3);
            check_results();
            %
            inpCell={zeros(1,0),false(1,0)};
            expResCell=inpCell;
            expIndList={1,1};
            [resCell,resIndList{:}]=uniquejoint(inpCell,1);
            check_results();
            %
            inpCell={zeros(10,0),false(10,0)};
            expIndList={10,ones(10,1)};
            [resCell,resIndList{:}]=uniquejoint(inpCell,1);
            check_results();
            %
            function check_results()
                isOk= isequal(expIndList,resIndList)...
                    && isequal(resCell,expResCell);
                mlunitext.assert_equals(true,isOk);
            end
        end
        %
        function self=test_uniquejoint_funchandle(self)
            import modgen.common.uniquejoint;
            inpCell={{@(x)ones(x),@sort,@(y)ones(y),@(x)ones(x)}};
            %
            expResCell={{@(x)ones(x),@(y)ones(y),@sort}};
            expIndList={[1;3;2],[1;3;2;1]};
            resIndList=cell(1,2);
            %
            [resCell,resIndList{:}]=uniquejoint(inpCell);
            check_results();
            [resCell,resIndList{:}]=uniquejoint(inpCell,2);
            check_results();
            %
            inpCell=cellfun(@transpose,inpCell,'UniformOutput',false);
            expResCell=cellfun(@transpose,expResCell,'UniformOutput',false);
            %
            [resCell,resIndList{:}]=uniquejoint(inpCell);
            check_results();
            [resCell,resIndList{:}]=uniquejoint(inpCell,1);
            %
            check_results();
            %
            inpCell={{@(x)ones(x),@sort;@min,@(y)ones(y);@(x)ones(x),@sort}};
            %
            expResCell={{@(x)ones(x),@sort;@min,@(y)ones(y)}};
            expIndList={[1;2],[1;2;1]};
            %
            [resCell,resIndList{:}]=uniquejoint(inpCell,1);
            %
            check_results();
            %
            inpCell=cellfun(@(x)permute(x,[2 1 3:ndims(x)]),...
                inpCell,'UniformOutput',false);
            expResCell=cellfun(@(x)permute(x,[2 1 3:ndims(x)]),...
                expResCell,'UniformOutput',false);
            %
            [resCell,resIndList{:}]=uniquejoint(inpCell,2);
            %
            check_results();
            %
            function check_results()
                isOk= isequal(resIndList,expIndList)...
                    && isequal(func2strForCell(resCell),func2strForCell(expResCell));
                mlunitext.assert_equals(true,isOk);
                
                function inpVec=func2strForCell(inpVec)
                    if iscell(inpVec),
                        inpVec=cellfun(@func2strForCell,inpVec,'UniformOutput',false);
                    elseif isa(inpVec,'function_handle')&&numel(inpVec)==1,
                        inpVec=func2str(inpVec);
                    end
                end
            end
        end
        function self=test_ismemberjoint_enum(self)
            import modgen.common.ismemberjoint;
            enumVal=modgen.common.test.aux.TestEnum.Alpha;
            arrayList={[1;2],[enumVal;enumVal]};
            [a,b]=ismemberjoint(arrayList,arrayList,1);
            mlunitext.assert_equals(true,isequal(a,[true;true]));
            mlunitext.assert_equals(true,isequal(b,[1;2]));
        end
        function self=test_uniquejoint_ext(self)
            import modgen.common.uniquejoint;
            import modgen.common.uniquebyfunc;
            %
            pathStr=fileparts(mfilename('fullpath'));
            StData=load([pathStr ...
                strrep('\+aux\uniquejoint_testdata.mat','\',filesep)]);
            inputCell=cellfun(@(x)x(:),struct2cell(StData),'UniformOutput',false);
            [~,~,~,isSorted]=uniquejoint(inputCell,1);
            mlunitext.assert_equals(true,isSorted);
            %
            nRows=200;
            inputCell=cellfun(@(x)x(1:nRows),inputCell,'UniformOutput',false);
            [outputCell1,indForward1Vec,indBackward1Vec]=uniquejoint(inputCell,1);
            nUniqueRows=numel(indForward1Vec);
            nElems=numel(inputCell);
            outputCell2=cell(1,nElems);
            for iElem=1:nElems,
                [~,~,outputCell2{iElem}]=uniquebyfunc(inputCell{iElem});
            end
            [~,indForward2Vec,indBackward2Vec]=uniquejoint(outputCell2,1);
            outputCell2=cellfun(@(x)x(indForward2Vec),inputCell,'UniformOutput',false);
            mlunitext.assert_equals(nUniqueRows,numel(indForward2Vec));
            indForwardVec=indBackward1Vec(indForward2Vec);
            mlunitext.assert_equals(true,~any(diff(sort(indForwardVec))==0));
            outputCell1=cellfun(@(x)x(indForwardVec),outputCell1,'UniformOutput',false);
            for iElem=1:nElems,
                mlunitext.assert_equals(true,...
                    isequaln(outputCell1{iElem},outputCell2{iElem}));
            end
            mlunitext.assert_equals(true,isequal(indBackward1Vec,indForwardVec(indBackward2Vec)));
            mlunitext.assert_equals(true,isequal(indForwardVec(indBackward2Vec(indForward1Vec)),(1:nUniqueRows).'));
        end
        function self=test_ismemberjointwithnulls(self)
            %
            leftCell={[1 2],{'a','b'};[3 4],{'c','d'}};
            rightCell={[1 2 3],{'a','b','c'};[3 4 5],{'c','d','m'}};
            leftIsNullCell=repmat({false(1,2)},size(leftCell));
            rightIsNullCell=repmat({false(1,3)},size(rightCell));
            isMemberVec=[];
            indMemberVec=[];
            %
            isMemberExpVec=[true true];
            indMemberExpVec=[1 2];
            superCheck(2);
            self.runAndCheckError(...
                '[isMemberVec,indMemberVec]=modgen.common.ismemberjointwithnulls(leftCell,leftIsNullCell,rightCell,rightIsNullCell,1);',...
                ':wrongInput');
            %
            leftCell={[1 2],{'c','b'};[5 4],{'c','d'}};
            rightCell={[1 2 3],{'a','b','c'};[3 4 5],{'c','d','m'}};
            leftIsNullCell={[true,false],[false,false];[false,false],[true,false]};
            rightIsNullCell={[false,false,true],[true,false,false];[false,false,false],[true,false,true]};
            isMemberExpVec=[true true];
            indMemberExpVec=[3 2];
            superCheck(2);
            self.runAndCheckError(...
                '[isMemberVec,indMemberVec]=modgen.common.ismemberjointwithnulls(leftCell,leftIsNullCell,rightCell,rightIsNullCell,1);',...
                ':wrongInput');
            %
            leftCell={[1 2;11 22],...
                {'a','b';'aa','bb'},...
                [3 4;33 44],...
                {'c','d';'cc','dd'}};
            rightCell={...
                [1 2 3;11 22 33],...
                {'a','b','c';'aa','bb','cc'},...
                [3 4 5;33 44 55],...
                {'c','d','m';'cc','dd','mm'}};
            leftIsNullCell=repmat({false(2,2)},size(leftCell));
            rightIsNullCell=repmat({false(2,3)},size(rightCell));
            isMemberExpVec=[true true];
            indMemberExpVec=[1 2];
            superCheck(2);
            for iElem=1:numel(leftCell)
                leftCell{iElem}=transpose(leftCell{iElem});
                leftIsNullCell{iElem}=transpose(leftIsNullCell{iElem});
                rightCell{iElem}=transpose(rightCell{iElem});
                rightIsNullCell{iElem}=transpose(rightIsNullCell{iElem});
            end
            isMemberExpVec=transpose(isMemberExpVec);
            indMemberExpVec=transpose(indMemberExpVec);
            superCheck(1);
            %
            leftCell={[1 2;11 22],...
                {'a','b';'cc','bb'},...
                [5 4;33 44],...
                {'c','d';'cc','dd'}};
            rightCell={...
                [1 2 3;11 22 33],...
                {'a','b','c';'aa','bb','cc'},...
                [3 4 5;33 44 55],...
                {'c','d','m';'cc','dd','mm'}};
            leftIsNullCell={[true,false;true,false],...
                [true,false;false,true],...
                [false,true;true,false],...
                [true,false;true,false]};
            rightIsNullCell={[false,false,true;true,false,true],...
                [false,false,true;true,true,false],...
                [false,true,false;true,false,true],...
                [true,false,true;true,false,true]};
            isMemberExpVec=[true true];
            indMemberExpVec=[3 2];
            superCheck(2);
            for iElem=1:numel(leftCell)
                leftCell{iElem}=transpose(leftCell{iElem});
                leftIsNullCell{iElem}=transpose(leftIsNullCell{iElem});
                rightCell{iElem}=transpose(rightCell{iElem});
                rightIsNullCell{iElem}=transpose(rightIsNullCell{iElem});
            end
            isMemberExpVec=transpose(isMemberExpVec);
            indMemberExpVec=transpose(indMemberExpVec);
            superCheck(1);
            %
            ethLeftCell=leftCell;
            ethLeftIsNullCell=leftIsNullCell;
            ethRightCell=rightCell;
            ethRightIsNullCell=rightIsNullCell;
            ethIsMemberExpVec=isMemberExpVec;
            ethIndMemberExpVec=indMemberExpVec;
            %
            leftIsNullCell=cellfun(@(x)x(:,1),leftIsNullCell,'UniformOutput',false);
            rightIsNullCell=cellfun(@(x)x(:,1),rightIsNullCell,'UniformOutput',false);
            isMemberExpVec=[false;true];
            indMemberExpVec=[0;2];
            superCheck(1);
            leftCell{3}(1,2)=55;
            isMemberExpVec=ethIsMemberExpVec;
            indMemberExpVec=ethIndMemberExpVec;
            superCheck(1);
            leftCell{3}(:,2)=[];
            leftIsNullCell{3}(:)=true;
            rightIsNullCell{3}(:)=true;
            superCheck(1);
            leftCell{3}=ethLeftCell{3};
            rightCell{3}=nan(3,0);
            superCheck(1);
            %
            leftCell=ethLeftCell;
            leftIsNullCell=ethLeftIsNullCell;
            rightCell={nan(2,0),cell(2,0),nan(2,0),cell(2,0)};
            rightIsNullCell=repmat({false(2,0)},size(rightCell));
            isMemberExpVec=false(1,2);
            indMemberExpVec=zeros(1,2);
            superCheck(2);
            rightCell={[],{},[],{}};
            rightIsNullCell=repmat({false(0,0)},size(rightCell));
            self.runAndCheckError(...
                '[isMemberVec,indMemberVec]=modgen.common.ismemberjointwithnulls(leftCell,rightCell,2);',...
                ':wrongInput');
            %
            rightCell=ethRightCell;
            rightIsNullCell=ethRightIsNullCell;
            leftCell={nan(3,0),cell(3,0),nan(3,0),cell(3,0)};
            leftIsNullCell=repmat({false(3,0)},size(leftCell));
            isMemberExpVec=false(1,0);
            indMemberExpVec=zeros(1,0);
            superCheck(2);
            leftCell={[],{},[],{}};
            leftIsNullCell=repmat({false(0,0)},size(leftCell));
            self.runAndCheckError(...
                '[isMemberVec,indMemberVec]=modgen.common.ismemberjointwithnulls(leftCell,rightCell,2);',...
                ':wrongInput');
            %
            leftCell=ethLeftCell;
            leftIsNullCell=cellfun(@(x)true(size(x)),ethLeftIsNullCell,'UniformOutput',false);
            rightCell=ethRightCell;
            rightIsNullCell=cellfun(@(x)true(size(x)),ethRightIsNullCell,'UniformOutput',false);
            isMemberExpVec=[true;true];
            indMemberExpVec=[3;3];
            superCheck(1);
            %
            StAsgn=substruct('()',{2,':'});
            rightIsNullCell=cellfun(@(x)subsasgn(x,StAsgn,true),ethRightIsNullCell,'UniformOutput',false); %#ok<SUBSASGN>
            isMemberExpVec=[true;true];
            indMemberExpVec=[2;2];
            superCheck(1);
            %
            rightIsNullCell=ethRightIsNullCell;
            isMemberExpVec=[false;false];
            indMemberExpVec=[0;0];
            superCheck(1);
            %
            leftIsNullCell=cellfun(@(x)subsasgn(x,StAsgn,true),ethLeftIsNullCell,'UniformOutput',false); %#ok<SUBSASGN>
            rightIsNullCell=cellfun(@(x)true(size(x)),ethRightIsNullCell,'UniformOutput',false);
            isMemberExpVec=[false;true];
            indMemberExpVec=[0;3];
            superCheck(1);
            %
            leftCell={[1 2;11 22],...
                {'a','b';'cc','bb'},...
                [5 4;33 44],...
                {'c','d';'cc','dd'}};
            rightCell={...
                [1 2 3;11 22 33],...
                {'a','b','c';'aa','bb','cc'},...
                [3 4 5;33 44 55],...
                {'c','d','m';'cc','dd','mm'}};
            leftIsNullCell={[true,true;true,false],...
                [true,false;false,true],...
                [false,true;true,false],...
                [true,false;true,false]};
            rightIsNullCell={[false,false,true;true,false,true],...
                [false,false,true;true,true,false],...
                [false,true,false;true,false,true],...
                [true,false,true;true,false,true]};
            isMemberExpVec=[true true];
            indMemberExpVec=[3 2];
            superCheck(2);
            %
            leftCell={[1 2;11 22],...
                {'a','b';'cc','bb'},...
                [5 4;33 44],...
                {'c','d';'cc','dd'}};
            rightCell={...
                [1 2 3;11 22 33],...
                {'d','b';'aa','b'},...
                [3 4;5 44],...
                {'c','d','m';'cc','dd','mm'}};
            leftIsNullCell={[true;false],...
                [true,false;false,true],...
                [false,true;true,false],...
                [true;false]};
            rightIsNullCell={[false;true],...
                [false,true;true,false],...
                [true,false;false,true],...
                [false;true]};
            isMemberExpVec=[true;false];
            indMemberExpVec=[2;0];
            superCheck(1);
            %
            function superCheck(dim)
                [isMemberVec,indMemberVec]=...
                    modgen.common.ismemberjointwithnulls(leftCell,leftIsNullCell,rightCell,rightIsNullCell,dim);
                check();
            end
            function check()
                mlunitext.assert_equals(true,...
                    isequal(isMemberVec,isMemberExpVec));
                %
                mlunitext.assert_equals(true,...
                    isequal(indMemberVec,indMemberExpVec));
            end
        end
        function self=test_uniquejoint_performance(self)
            inpMat=randi([1 2],8500,4);
            checkTime(inpMat,100);
            inpMat=randi([1 2],300,10);
            checkTime(inpMat,100);
            inpMat=randi([1 20],1000,20);
            checkTime(inpMat,100);
            inpMat=randi([1 20],4000,500);
            checkTime(inpMat,10);
            inpMat=randi([1 20],1000,500);
            checkTime(inpMat,100);
            
            function checkTime(inpMat,nRuns) %#ok<INUSL>
                import modgen.common.uniquejoint;
                MAX_TOLERANCE=0.9;
                outMat1=[];
                indForwardVec1=[];
                indBackwardVec1=[];
                outMat2=[];
                indForwardVec2=[];
                indBackwardVec2=[];
                time1=self.runAndCheckTime(...
                    '[outMat1,indForwardVec1,indBackwardVec1]=modgen.common.uniquejoint({inpMat},1,''optimized'');',...
                    'nRuns',nRuns,'useMedianTime',true);
                time2=self.runAndCheckTime(...
                    '[outMat2,indForwardVec2,indBackwardVec2]=modgen.common.uniquejoint({inpMat},1,''standard'');',...
                    'nRuns',nRuns,'useMedianTime',true);
                mlunitext.assert_equals(true,isequal(outMat1,outMat2));
                mlunitext.assert_equals(true,isequal(indForwardVec1,indForwardVec2));
                mlunitext.assert_equals(true,isequal(indBackwardVec1,indBackwardVec2));
                time1=min(time1,time2);
                time2=self.runAndCheckTime('[outMat2,indForwardVec2,indBackwardVec2]=modgen.common.uniquejoint({inpMat},1);',...
                    'nRuns',nRuns,'useMedianTime',true);
                mlunitext.assert_equals(true,isequal(outMat1,outMat2));
                mlunitext.assert_equals(true,isequal(indForwardVec1,indForwardVec2));
                mlunitext.assert_equals(true,isequal(indBackwardVec1,indBackwardVec2));
                curTolerance=max(max(time1/time2,time2/time1)-1,0);
                messageStr=sprintf('Ratio error %f between chosen and mininal exceeds maximal one %f',...
                    curTolerance,MAX_TOLERANCE);
                mlunitext.assert_equals(true,curTolerance<MAX_TOLERANCE,messageStr);
            end
        end
        function self=test_ismemberjoint_performance(self)
            inpMat1=randi([1 2],10000,10);
            inpMat2=randi([1 2],100000,10);
            checkTime(inpMat1,inpMat2,10);
            inpMat1=randi([1 10],500,10);
            inpMat2=randi([1 10],1000,10);
            checkTime(inpMat1,inpMat2,100);
            inpMat1=randi([1 100],400,100);
            inpMat2=randi([1 100],800,100);
            checkTime(inpMat1,inpMat2,100);
            inpMat1=randi([1 100],2000,100);
            inpMat2=randi([1 100],4000,100);
            checkTime(inpMat1,inpMat2,10);
            inpMat1=randi([1 10],20,500);
            inpMat2=randi([1 10],40,500);
            checkTime(inpMat1,inpMat2,100);
            inpMat1=randi([1 100],1000,1000);
            inpMat2=randi([1 100],2000,1000);
            checkTime(inpMat1,inpMat2,10,0.4);
            
            function checkTime(inpMat1,inpMat2,nRuns,maxTol) %#ok<INUSL>
                import modgen.common.ismemberjoint;
                MAX_TOLERANCE_DEFAULT=0.9;                
                if nargin<4
                    maxTol=MAX_TOLERANCE_DEFAULT;
                end
                isMemberVec1=[];
                indMemberVec1=[];
                isMemberVec2=[];
                indMemberVec2=[];
                time1=self.runAndCheckTime(...
                    '[isMemberVec1,indMemberVec1]=modgen.common.ismemberjoint({inpMat1},{inpMat2},1,''optimized'');',...
                    'nRuns',nRuns,'useMedianTime',true);
                time2=self.runAndCheckTime(...
                    '[isMemberVec2,indMemberVec2]=modgen.common.ismemberjoint({inpMat1},{inpMat2},1,''standard'');',...
                    'nRuns',nRuns,'useMedianTime',true);
                mlunitext.assert_equals(true,isequal(isMemberVec1,isMemberVec2));
                mlunitext.assert_equals(true,isequal(indMemberVec1,indMemberVec2));
                time1=min(time1,time2);
                time2=self.runAndCheckTime(...
                    '[isMemberVec2,indMemberVec2]=modgen.common.ismemberjoint({inpMat1},{inpMat2},1);',...
                    'nRuns',nRuns,'useMedianTime',true);
                mlunitext.assert_equals(true,isequal(isMemberVec1,isMemberVec2));
                mlunitext.assert_equals(true,isequal(indMemberVec1,indMemberVec2));
                curTolerance=max(max(time1/time2,time2/time1)-1,0);
                messageStr=sprintf('Ratio error %f between chosen and mininal exceeds maximal one %f',...
                    curTolerance,maxTol);
                mlunitext.assert_equals(true,...
                    curTolerance<maxTol,messageStr);
            end
        end
    end
end