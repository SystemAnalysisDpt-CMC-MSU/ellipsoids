classdef StructDispTC < mlunitext.test_case %#ok<*NASGU>
    %
    %$Author: Alexander Karev <Alexander.Karev.30@gmail.com> $
    %$Date: 2013-06$
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    properties (Access=private)
        testDataRootDir
        resTmpDir
    end
    methods
        function self = StructDispTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
        end
        function self = set_up_param(self,varargin)
        end
        %
        function self = set_up(self)
            self.resTmpDir=modgen.test.TmpDataManager.getDirByCallerKey();
        end
        function self = tear_down(self)
            modgen.io.rmdir(self.resTmpDir,'s');
        end
        %
        function self = test_strucdisp(self)
            import modgen.struct.strucdisp;
            S.name='';
            S.description=[]; %#ok<STRNU>
            %
            res=evalc('strucdisp(S)');
            ind=strfind(res,'name');
            mlunitext.assert_equals(1,numel(ind));
            ind=strfind(res,'description');
            mlunitext.assert_equals(1,numel(ind));
        end
        function testStruct2Str(~)
            import modgen.struct.strucdisp;
            S.alpha=1;
            S.beta=2;
            S.gamma.alpha=1;
            S.gamma.beta=2;
            resStr=strucdisp(S);
            resStr2=modgen.struct.struct2str(S);
            mlunitext.assert_equals(true,isequal(resStr,resStr2));
        end
        function testStrucDispSimpleRegress(~)
            import modgen.struct.strucdisp;
            S.alpha=1;
            S.beta=2;
            S.gamma.alpha=1;
            S.gamma.beta=2;
            expList={'|    ';...
                '|--- gamma';...
                '|       |    ';...
                '|       |-- alpha : 1';...
                '|       |--- beta : 2';...
                '|       O';...
                '|    ';...
                '|-- alpha : 1';...
                '|--- beta : 2'};
            check(S,expList);
            function check(S,expList)
                import modgen.struct.strucdisp;
                inpArgList={S,'depth',2,'printValues',true};
                resStr=evalc('modgen.struct.strucdisp(inpArgList{:})');
                resStr2=strucdisp(inpArgList{:});
                mlunitext.assert_equals(true,isequal(resStr,resStr2));
                resList=textscan(resStr,'%s','delimiter','\n');
                resList=resList{1};
                mlunitext.assert_equals(true,isequal(resList,expList));
            end
        end
        function testStrucDispRegress(self)
            %
            ARG_COMB_LIST={...
                {'depth',100,'printValues',false,'maxArrayLength',100},...
                {'depth',100,'printValues',true,'maxArrayLength',100},...
                {'depth',2,'printValues',true},...
                {'depth',100,'printValues',true},...
                {'depth',100,'printValues',false}};
            %
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            
            resMap=modgen.containers.ondisk.HashMapMatXML(...
                'storageLocationRoot',self.testDataRootDir,...
                'storageBranchKey',[methodName,'_out'],'storageFormat','mat',...
                'useHashedPath',false,'useHashedKeys',true);
            SData=load(inpFileName);
            structNameList=fieldnames(SData);
            nFields=length(structNameList);
            nArgCombs=length(ARG_COMB_LIST);
            %
            %resTmpDir=self.resTmpDir;
            %resFileName=[resTmpDir,filesep,'out.txt'];
            for iField=1:nFields
                structName=structNameList{iField};
                S=SData.(structName);
                for iArgComb=1:nArgCombs
                    inpArgList=ARG_COMB_LIST{iArgComb};
                    resStr=evalc('modgen.struct.strucdisp(S,inpArgList{:})');
                    inpKey=modgen.common.hash({S,inpArgList});
                    SRes.S=S;
                    SRes.inpArgList=inpArgList;
                    SRes.resStr=resStr;
                    %
                    %resMap.put(inpKey,SRes);
                    SExpRes=resMap.get(inpKey);
                    [isPos,reportStr]=...
                        modgen.struct.structcompare(SRes,SExpRes);
                    mlunitext.assert_equals(true,isPos,reportStr);
                end
            end
            %
        end
        function testGetLeaveList(~)
            Data=modgen.common.genteststruct(0);
            check();
            Data=struct();
            Data.alpha(2,1).a=2;
            Data.alpha(2,4).a=6;
            check();
            Data=struct();
            Data.alpha(1).a=2;
            Data.alpha(4).a=6;
            check();
            Data=struct();
            Data.alpha(2,1,5).a=2;
            Data.alpha(2,4,4).a=6;
            %
            check();
            function SRes=check()
                SRes=checkGetField();
                compare();
                SRes=checkValue();
                compare();
                %
                function compare()
                    [isEqual,reportStr]=modgen.struct.structcompare(SRes,Data);
                    mlunitext.assert_equals(true,isEqual,reportStr);
                    mlunitext.assert_equals(true,isequaln(SRes,Data));
                end
                function SRes=checkValue()
                    [pathSpecList,valList]=modgen.struct.getleavelist(Data);
                    nPaths=numel(pathSpecList);
                    SRes=struct();
                    for iPath=1:nPaths
                        SRes=setfield(SRes,pathSpecList{iPath}{:},...
                            valList{iPath});
                    end
                end
                function SRes=checkGetField()
                    pathSpecList=modgen.struct.getleavelist(Data);
                    nPaths=numel(pathSpecList);
                    SRes=struct();
                    for iPath=1:nPaths
                        SRes=setfield(SRes,pathSpecList{iPath}{:},...
                            getfield(Data,pathSpecList{iPath}{:}));
                    end
                end
            end
        end
        function test_updateLeaves(~)
            import modgen.struct.updateleavesext;
            SData.a.b=1;
            SRes=updateleavesext(SData,@fTransform);
            %
            SExp.a.bb=1;
            mlunitext.assert_equals(true,isequal(SRes,SExp));
            %
            function [val,path]=fTransform(val,path)
                path{4}=repmat(path{4},1,2);
            end
        end
        function testGetUpdateLeaves(~)
            checkPathList(modgen.struct.getleavelist(struct()));
            %
            SData.a.b=1;
            SData.a.c=20;
            SData.b.a.d=1;
            SData.c=10;
            SData.d='c';
            SData.alpha.beta.gamma.theta=2;
            SData.alpha.beta.gamma.delta='vega';
            SData.alpha.beta.gamma.delta2=1;
            %
            check();
            SData=struct();
            check();
            SData=modgen.common.genteststruct(0);
            check();
            function check()
                SRes=modgen.struct.updateleaves(SData,@(x,y)x);
                mlunitext.assert_equals(true,...
                    isequaln(SData,SRes));
                SRes=modgen.struct.updateleaves(SData,@fMinus);
                SRes=modgen.struct.updateleaves(SRes,@fMinus);
                mlunitext.assert_equals(true,...
                    isequaln(SData,SRes));
                %
                pathExpList=modgen.struct.getleavelist(SData);
                pathList={};
                %
                modgen.struct.updateleaves(SRes,@storePath);
                mlunitext.assert_equals(true,isequal(pathList,pathExpList));
                %
                function value=storePath(value,subFieldNameList)
                    pathList=[pathList;{subFieldNameList}];
                end
                function x=fMinus(x,~)
                    if isnumeric(x)
                        x=-x;
                    end
                end
            end
            function checkPathList(pathList)
                import modgen.common.type.simple.lib.iscellofstring;
                mlunitext.assert_equals(true,iscell(pathList));
                if ~isempty(pathList)
                    mlunitext.assert_equals(true,...
                        all(cellfun('isclass',pathList,'cell')));
                    mlunitext.assert_equals(true,...
                        iscellofstring([pathList{:}]));
                end
            end
        end
        
        function self = testArrays(self)
            import modgen.struct.strucdisp;
            S = struct('a', 1);
            str = evalc('strucdisp(S)');
            isOk = ~isempty(strfind(str, '1'));
            
            S = struct('a', [1 2 3]);
            str = evalc('strucdisp(S)');
            isOk = isOk & ~isempty(strfind(str, '[1 2 3]'));
            
            S = struct('a', ones(5, 3, 2)); 
            str = evalc('strucdisp(S)');
            isOk = isOk & ~isempty(strfind(str, '[5x3x2 Array]'));
            
            mlunitext.assert_equals(isOk, true);
        end
        %
        function self = testLogicalFields(self)
            import modgen.struct.strucdisp;
            S = struct('a', false(1, 2));
            str = evalc('strucdisp(S)');
            isOk = ~isempty(strfind(str, '[false false]'));
            
            S = struct('a', false);
            str = evalc('strucdisp(S)');
            isOk = isOk & ~isempty(strfind(str, 'false'));
            
            S = struct('a', false(5));
            str = evalc('strucdisp(S)');
            isOk = isOk & ~isempty(strfind(str, '[5x5 Logic array]'));
            
            mlunitext.assert_equals(isOk, true);
        end
        
        function self = testUpdateRegress(self)
            import modgen.struct.strucdisp;
            ARG_COMB_LIST={...
                {'depth',100,'printValues',false,'maxArrayLength',100},...
                {'depth',100,'printValues',true,'maxArrayLength',100},...
                {'depth',2,'printValues',true},...
                {'depth',100,'printValues',true},...
                {'depth',100,'printValues',false}};
            %
            methodName=modgen.common.getcallernameext(1);
            
            inpResMap=modgen.containers.ondisk.HashMapMatXML(...
                'storageLocationRoot',self.testDataRootDir,...
                'storageBranchKey',[methodName '_inp'],'storageFormat','mat',...
                'useHashedPath',false,'useHashedKeys',true);
            outResMap=modgen.containers.ondisk.HashMapMatXML(...
                'storageLocationRoot',self.testDataRootDir,...
                'storageBranchKey',[methodName '_out'],'storageFormat','mat',...
                'useHashedPath',false,'useHashedKeys',true);
            nArgCombs=length(ARG_COMB_LIST);
            %
            keyList=inpResMap.getKeyList();
            nKeys=numel(keyList);
            for iKey=1:nKeys,
                keyName=keyList{iKey};
                SDataVec=inpResMap.get(keyName);
                for iArgComb=1:nArgCombs
                    inpArgList=ARG_COMB_LIST{iArgComb};
                    nElems=numel(SDataVec);
                    stDispObj=modgen.struct.StructDisp(SDataVec(1),...
                        inpArgList{:});
                    for iElem=1:nElems,
                        if iElem==1,
                            rowIndVec=nan(0,1);
                            colIndVec=nan(0,1);
                        else
                            [rowIndVec,colIndVec]=...
                                stDispObj.update(SDataVec(iElem));
                        end
                        resStr=stDispObj.display();
                        SRes=struct(...
                            'S',{SDataVec(iElem)},...
                            'inpArgList',{inpArgList},...
                            'rowIndVec',{rowIndVec},...
                            'colIndVec',{colIndVec},...
                            'resStr',{resStr});
                        mlunitext.assert_equals(true,isequal(resStr,...
                            strucdisp(SDataVec(iElem),inpArgList{:})));
                        inpKey=modgen.common.hash({SDataVec(iElem),...
                            inpArgList});
                        %
                        SExpRes=outResMap.get(inpKey);
                        if isunix()&&(iKey==3)
                            %different behavior on Linux
                            SExpRes.resStr=strrep(SExpRes.resStr,...
                                '-1430.13','-1430.12');
                            SExpRes.resStr=strrep(SExpRes.resStr,...
                                '-3102.63','-3102.62');                            
                        end
                        [isPos,reportStr]=...
                            modgen.struct.structcompare(SRes,SExpRes);
                        mlunitext.assert_equals(true,isPos,reportStr);
                    end
                end
            end
            %
        end
    end
end