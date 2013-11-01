classdef SuiteEllTube < mlunitext.test_case
    
    methods
        function self = SuiteEllTube(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function tear_down(~)
            close all;
        end
        function testProjectTouch(~)
            import gras.ellapx.smartdb.rels.EllUnionTube;
            rel = gras.ellapx.smartdb...
                .test.mlunit.EllTubePlotTestCase.createTube(1);
            projSpaceList = {[1 0; 0 1].'};
            projType = gras.ellapx.enums.EProjType.Static;
            relStatProj = ...
                rel.project(projType,projSpaceList,@fGetProjMat);
            %
            %
            ellTubeUnionRel=...
                gras.ellapx.smartdb.rels.EllUnionTubeStaticProj.fromEllTubes(relStatProj);
            ellTubeUnionRel = ...
                gras.ellapx.smartdb.rels.EllUnionTube.fromEllTubes(rel);
            
            function [projOrthMatArray, projOrthMatTransArray] =...
                    fGetProjMat(projMat, timeVec, varargin)
                nTimePoints = length(timeVec);
                projOrthMatArray = repmat(projMat, [1, 1, nTimePoints]);
                projOrthMatTransArray = repmat(projMat.',...
                    [1,1,nTimePoints]);
            end
        end
        function testProjectionOneDimension(~)
            import gras.ellapx.smartdb.RelDispConfigurator;
            import gras.ellapx.smartdb.rels.EllUnionTube;
            import gras.ellapx.proj.EllTubeStaticSpaceProjector;
            n = 4;
            T = 1;
            q11 = @(t)[ cos(2*pi*t/n) sin(2*pi*t/n) ; -sin(2*pi*t/n)  cos(2*pi*t/n) ];
            ltGDir = [];
            QArrList = cell(n+1,1);
            sTime =1;
            timeVec = 1:T;
            for i= 0:n
                ltGDir = [ltGDir ([1 0]*q11(i))'];
                QArrListTemp = repmat(q11(i)'*diag([1 4])*q11(i),[1,1,T]);
                QArrList{i+1} = QArrListTemp;
            end
            
            ltGDir = repmat(ltGDir,[1 1 T]);
            aMat = repmat([1 0]',[1,T]);
            approxType = gras.ellapx.enums.EApproxType(1);
            calcPrecision = 10^(-3);
            rel = gras.ellapx.smartdb.rels.EllUnionTube.fromEllTubes(gras.ellapx.smartdb.rels.EllTube.fromQArrays(QArrList',aMat...
                ,timeVec,ltGDir,sTime',approxType,...
                char.empty(1,0),char.empty(1,0),...
                calcPrecision));
            projSpaceList = {eye(1, 2)};
            projType = gras.ellapx.enums.EProjType.Static;
            
            projObj=EllTubeStaticSpaceProjector(projSpaceList);
            relStatProj=projObj.project(rel);
        end
        %
        function testSizeConsistency(self)
            nPoints=3;
            nTubes=2;
            [rel,relStatProj,relDynProj]=auxGenSimpleTubeAndProj(self,...
                nPoints,nTubes);
            check(rel);
            check(relStatProj);
            check(relDynProj);
            function check(rel)
                fieldNameList=rel.getFieldNameList();
                nFields=numel(fieldNameList);
                for iField=1:nFields
                    fieldName=fieldNameList{iField};
                    SData=rel.getData();
                    if iscell(SData.(fieldName))
                        SData.(fieldName)=cat(2,SData.(fieldName),...
                            SData.(fieldName));
                        self.runAndCheckError(@checkField,...
                            'wrongInput:badSize','reportStr',...
                            sprintf('failure for field %s',fieldName));
                    end
                end
                function checkField()
                    rel.createInstance(SData);
                end
            end
        end
        %
        function testCut(~)
            calcPrecision=0.001;
            nTubes=3;
            nDims=2;
            cutTimeVec = [20, 80];
            nPoints=100;
            %
            timeVec = 1 : nPoints;
            [rel,relProj]=create(timeVec);
            checkMaster(relProj,2);
            checkMaster(rel,1);            
            %
            function checkMaster(rel,outNum)
                check(rel,cutTimeVec,outNum);
                check(rel,timeVec(end)/2,outNum);
            end
            function check(rel,cutTimeVec,outNum)
                cutRel = rel.cut([cutTimeVec(1),cutTimeVec(end)]);
                outList=cell(1,2);
                [outList{:}]=create(cutTimeVec(1):cutTimeVec(end));
                expRel=outList{outNum};
                %
                fieldToExcludeList = rel.getNoCatOrCutFieldsList();                
                fieldList = setdiff(cutRel.getFieldNameList(),fieldToExcludeList);
                %
                [isOk,reportStr] = ...
                    cutRel.getFieldProjection(fieldList).isEqual(...
                    expRel.getFieldProjection(fieldList));
                mlunitext.assert(isOk, reportStr);                 
            end
            %
            function [rel,varargout] = create(timeVec)
                if nargin==0
                    rel=gras.ellapx.smartdb.rels.EllTube();
                else
                    nPoints = numel(timeVec);
                    aMat=zeros(nDims,nPoints);
                    %
                    QArray = zeros(nDims,nDims,nPoints);
                    for iPoint = 1:nPoints
                        QArray(:,:,iPoint) = timeVec(iPoint)*eye(nDims);
                    end
                    QArrayList=repmat({QArray},1,nTubes);
                    %
                    ltSingleGoodDirArray = zeros(nDims,1,nPoints);
                    for iPoint = 1:nPoints
                        ltSingleGoodDirArray(:,:,iPoint) = ...
                            timeVec(iPoint)*eye(nDims,1);
                    end
                    ltGoodDirArray=repmat(ltSingleGoodDirArray,1,nTubes);
                    %
                    rel = gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                        QArrayList,aMat,timeVec,ltGoodDirArray,timeVec(1),...
                        gras.ellapx.enums.EApproxType.Internal,...
                        char.empty(1,0),char.empty(1,0),calcPrecision);
                    if nargout>1
                        projMatList = {[1 0; 0 1].'};
                        %
                        relStatProj=rel.projectStatic(projMatList);
                        varargout{1}=relStatProj;
                    end                    
                end
            end            
        end
        function testCat(~)
            nDims=2;
            nTubes=3;
            calcPrecision=0.001;
            timeVec = 1 : 100;
            evolveTimeVec = 101 : 200;
            rel=create();
            fieldToExcludeList = rel.getNoCatOrCutFieldsList();
            % cat: test
            firstRel = create(timeVec);
            secondRel = create(evolveTimeVec);
            expRel = create([timeVec evolveTimeVec]);
            catRel = firstRel.cat(secondRel);
            check();
            catRel = firstRel.cat(secondRel,'isReplacedByNew',true);
            check();
            isOk=all(cellfun(@(x)isequal(catRel.(x),secondRel.(x)),...
                setdiff(fieldToExcludeList,{'sTime','indSTime'})));
            mlunitext.assert(isOk);
            function check()
                fieldList = setdiff(catRel.getFieldNameList(),fieldToExcludeList);
                [isOk,reportStr] = ...
                    catRel.getFieldProjection(fieldList).isEqual(...
                    expRel.getFieldProjection(fieldList));
                mlunitext.assert(isOk, reportStr);
            end
            %
            function rel = create(timeVec)
                if nargin==0
                    rel=gras.ellapx.smartdb.rels.EllTube();
                else
                    nPoints = numel(timeVec);
                    aMat=zeros(nDims,nPoints);
                    %
                    QArray = zeros(nDims,nDims,nPoints);
                    for iPoint = 1:nPoints
                        QArray(:,:,iPoint) = timeVec(iPoint)*eye(nDims);
                    end
                    QArrayList=repmat({QArray},1,nTubes);
                    %
                    ltSingleGoodDirArray = zeros(nDims,1,nPoints);
                    for iPoint = 1:nPoints
                        ltSingleGoodDirArray(:,:,iPoint) = ...
                            timeVec(iPoint)*eye(nDims,1);
                    end
                    ltGoodDirArray=repmat(ltSingleGoodDirArray,1,nTubes);
                    %
                    rel = gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                        QArrayList,aMat,timeVec,ltGoodDirArray,timeVec(1),...
                        gras.ellapx.enums.EApproxType.Internal,...
                        char.empty(1,0),char.empty(1,0),calcPrecision);
                end
            end
        end
        function testRegCreate(self)
            nDims=2;
            nPoints=3;
            approxSchemaDescr=char.empty(1,0);
            approxSchemaName=char.empty(1,0);
            nTubes=3;
            %
            checkAll();
            %%
            function checkAll()
                checkMaster(@fGetDiffMArray);
                checkMaster(@fGetSame);
                checkMaster(@fGetDiffScale2);
                checkMaster(@fGetDiffScale);
            end
            function [isScaleDiff,isMDiff,scaleFactor,MArrayList]=fGetSame(~,~)
                isScaleDiff=false;
                isMDiff=false;
                scaleFactor=1.02;
                MArrayList=repmat({repmat(0.1*eye(nDims),[1,1,nPoints])},1,nTubes);
            end
            %
            function [isScaleDiff,isMDiff,scaleFactor,MArrayList]=fGetDiffScale(isScaleDiff,~)
                if isScaleDiff
                    scaleFactor=1.02;
                else
                    scaleFactor=1.01;
                end
                isMDiff=false;
                isScaleDiff=true;
                MArrayList=repmat({repmat(0.1*eye(nDims),[1,1,nPoints])},1,nTubes);
            end
            function [isScaleDiff,isMDiff,scaleFactor,MArrayList]=fGetDiffScale2(isScaleDiff,~)
                if isScaleDiff
                    scaleFactor=6;
                else
                    scaleFactor=1.01;
                end
                isScaleDiff=true;
                isMDiff=false;
                MArrayList=repmat({repmat(0.1*eye(nDims),[1,1,nPoints])},1,nTubes);
            end
            %
            function [isScaleDiff,isMDiff,scaleFactor,MArrayList]=fGetDiffMArray(~,isMDiff)
                if isMDiff
                    mArrayMult=0.1;
                else
                    mArrayMult=0.2;
                end
                isScaleDiff=false;
                isMDiff=true;
                %
                scaleFactor=1.1;
                MArrayList=repmat({repmat(mArrayMult*eye(nDims),...
                    [1,1,nPoints])},1,nTubes);
            end
            %
            function checkMaster(fGetScaleAndReg)
                calcPrecision=0.001;
                scaleFactor=1.01;
                lsGoodDirVec=[1;0];
                QArrayList=repmat({repmat(eye(nDims),[1,1,nPoints])},1,nTubes);
                %
                aMat=zeros(nDims,nPoints);
                timeVec=1:nPoints;
                sTime=nPoints;
                %
                [~,~,scaleFactor,MArrayList]=fGetScaleAndReg(false,false);
                approxType=gras.ellapx.enums.EApproxType.Internal;
                scaleFactorInt=scaleFactor; %#ok<NASGU>
                rel1=create(); %#ok<NASGU>
                QArrayList=repmat({repmat(0.5*eye(nDims),[1,1,nPoints])},1,nTubes);
                approxType=gras.ellapx.enums.EApproxType.External;
                [isScaleDiff,isMDiff,scaleFactor,MArrayList]=fGetScaleAndReg(true,true);
                rel2=create(); %#ok<NASGU>
                if ~(isMDiff||isScaleDiff)
                    check('wrongInput:touchCurveDependency');
                else
                    check();
                end
                %
                QArrayList=repmat({repmat(diag([1 0.5]),[1,1,nPoints])},1,nTubes);
                [isScaleDiff,isMDiff,scaleFactor,MArrayList]=fGetScaleAndReg(true,true);
                rel2=create(); %#ok<NASGU>
                if ~(isMDiff||isScaleDiff)
                    check('wrongInput:internalWithinExternal');
                else
                    check();
                end
                %
                lsGoodDirVec=[0;1];
                QArrayList=repmat({repmat(diag([0.5 0.2]),[1,1,nPoints])},1,nTubes);
                [isScaleDiff,isMDiff,scaleFactor,MArrayList]=fGetScaleAndReg(false,false);
                rel1=create(); %#ok<NASGU>
                %
                if ~(isMDiff||isScaleDiff)
                    check('wrongInput:touchLineValueFunc');
                else
                    check();
                end
                %%
                function check(errorTag,cmdStr)
                    CMD_STR='rel1.getCopy().unionWith(rel2)';
                    if nargin<2
                        cmdStr=CMD_STR;
                    end
                    if nargin==0
                        eval(cmdStr);
                    else
                        self.runAndCheckError(cmdStr,errorTag);
                    end
                end
                function rel=create()
                    ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
                    rel=gras.ellapx.smartdb.rels.EllTube.fromQMScaledArrays(...
                        QArrayList,aMat,MArrayList,timeVec,...
                        ltGoodDirArray,sTime,approxType,approxSchemaName,...
                        approxSchemaDescr,calcPrecision,...
                        scaleFactor(ones(1,nTubes)));
                end
            end
            %
        end
        %
        function testProjectAdv(self)
            import gras.ellapx.smartdb.rels.EllUnionTube;
            nFirstPoints=100;
            nTubes=2;
            [rel]=self.auxGenSimpleTubeAndProj(...
                nFirstPoints,nTubes,nFirstPoints);
            %
            rel.aMat=cellfun(@(x,y)repmat(sin(x/10),y,1),rel.timeVec,...
                num2cell(rel.dim),...
                'UniformOutput',false);
            unionEllTube = EllUnionTube.fromEllTubes(rel);
            %
            check([1 0]);
            check([0 -1]);
            check([1 -1]);
            function check(projMat)
                rel0Proj=unionEllTube.projectStatic(projMat);
                [isOk,reportStr]=rel0Proj.isEqual(rel0Proj);
                mlunitext.assert(isOk,reportStr);
                %
                rel1Proj=rel.projectStatic(projMat);
                rel2Proj=rel.projectStatic({projMat});
                [isPos,reportStr]=rel1Proj.isEqual(rel2Proj);
                mlunitext.assert(isPos,reportStr);
            end
        end
        %
        function testProjectionAndScale(~)
            import gras.ellapx.proj.EllTubeStaticSpaceProjector;
            relProj=gras.ellapx.smartdb.rels.EllTubeProj(); %#ok<NASGU>
            %
            nPoints = 5;
            calcPrecision = 0.001;
            approxSchemaDescr = char.empty(1,0);
            approxSchemaName = char.empty(1,0);
            nDims = 3;
            nTubes = 4;
            lsGoodDirVec=[1; 0; 1];
            aMat = zeros(nDims, nPoints);
            timeVec = 1:nPoints;
            sTime = nPoints;
            approxType = gras.ellapx.enums.EApproxType.Internal;
            %
            MArrayList = repmat({repmat(diag([0.1 0.2 0.3]),[1,1,nPoints])},...
                1,nTubes);
            QArrayList = repmat({repmat(diag([1 2 3]),[1,1,nPoints])},1,nTubes);
            scaleFactor = 1.01;
            rel=create();
            projMatList={[1 0 1;0 1 1],[1 0 0;0 1 0]};
            projObj=EllTubeStaticSpaceProjector(projMatList);
            relProj=projObj.project(rel);
            
            
            
            relProj.plot();
            %
            MBeforeArray=rel.MArray;
            rel2=rel.getCopy();
            rel2.scale(@(varargin)2,{});
            MAfterArray=rel2.MArray;
            %
            mlunitext.assert_equals(false,isequal(MBeforeArray,MAfterArray));
            rel2.scale(@(varargin)0.5,{});
            [isEqual,reportStr]=rel.isEqual(rel2);
            mlunitext.assert_equals(true,isEqual,reportStr);
            %
            projType = gras.ellapx.enums.EProjType.Static;
            projObj=EllTubeStaticSpaceProjector({[0 1 0;0 0 1]});
            relProjOrthExp=projObj.project(rel);
            relProjOrthGot=rel.projectToOrths([2,3],projType);
            [isEqual,reportStr]=relProjOrthExp.isEqual(relProjOrthGot);
            mlunitext.assert_equals(true,isEqual,reportStr);
            %
            function [projOrthMatArray,projOrthMatTransArray]=...
                    fGetProjMat(projMat,timeVec,varargin)
                nPoints=length(timeVec);
                projOrthMatArray=repmat(projMat,[1,1,nPoints]);
                projOrthMatTransArray=repmat(projMat.',[1,1,nPoints]);
            end
            function rel=create()
                ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
                gras.ellapx.smartdb.rels.EllTube.fromQMScaledArrays(...
                    QArrayList,aMat,MArrayList,timeVec,...
                    ltGoodDirArray,sTime,approxType,approxSchemaName,...
                    approxSchemaDescr,calcPrecision,...
                    scaleFactor(ones(1,nTubes)));
                rel=gras.ellapx.smartdb.rels.EllTube.fromQMArrays(...
                    QArrayList,aMat,MArrayList,timeVec,...
                    ltGoodDirArray,sTime,approxType,approxSchemaName,...
                    approxSchemaDescr,calcPrecision);
            end
        end
        function testSimpleNegRegCreate(self)
            nPoints = 3;
            calcPrecision = 0.001;
            approxSchemaDescr = char.empty(1,0);
            approxSchemaName = char.empty(1,0);
            nDims = 2;
            nTubes = 3;
            lsGoodDirVec = [1;0];
            aMat = zeros(nDims,nPoints);
            timeVec = 1:nPoints;
            sTime = nPoints;
            approxType = gras.ellapx.enums.EApproxType.Internal;
            %
            MArrayList=repmat({repmat(diag([0.1 0.1]),[1,1,nPoints])},...
                1,nTubes);
            QArrayList=repmat({repmat(diag([1 1]),[1,1,nPoints])},1,nTubes);
            scaleFactor=1.01;
            create();
            QArrayList=repmat({repmat(diag([-1 1]),[1,1,nPoints])},1,nTubes);
            scaleFactor=1.01;
            %
            check('wrongInput:QArray',@create);
            %
            QArrayList=repmat({repmat(eye(nDims),[1,1,nPoints])},1,nTubes);
            MArrayList=repmat({repmat(diag([-0.1 0.1]),[1,1,nPoints])},...
                1,nTubes);
            %
            check('wrongInput:MArray',@create);
            QArrayList=repmat({repmat(eye(nDims),[1,1,nPoints])},1,nTubes);
            timeVec=1:nPoints-1;
            MArrayList=repmat({repmat(diag([0.1 0.1]),[1,1,nPoints])},...
                1,nTubes);
            sTime=1;
            check('wrongInput',@create);
            timeVec=1:nPoints;
            MArrayList=repmat({repmat(diag([0.1 0.1]),[1,1,nPoints-1])},...
                1,nTubes);
            check('wrongInput',@create);
            MArrayList=repmat({repmat(diag([0.1 0.1 0.1]),[1,1,nPoints])},...
                1,nTubes);
            %
            function rel=create()
                ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
                gras.ellapx.smartdb.rels.EllTube.fromQMScaledArrays(...
                    QArrayList,aMat,MArrayList,timeVec,...
                    ltGoodDirArray,sTime,approxType,approxSchemaName,...
                    approxSchemaDescr,calcPrecision,...
                    scaleFactor(ones(1,nTubes)));
                rel=gras.ellapx.smartdb.rels.EllTube.fromQMArrays(...
                    QArrayList,aMat,MArrayList,timeVec,...
                    ltGoodDirArray,sTime,approxType,approxSchemaName,...
                    approxSchemaDescr,calcPrecision);
            end
            function check(errorTag,cmdStr)
                CMD_STR='rel1.getCopy().unionWith(rel2)';
                if nargin<2
                    cmdStr=CMD_STR;
                end
                if nargin==0
                    if ischar(cmdStr)
                        eval(cmdStr);
                    else
                        feval(cmdStr);
                    end
                else
                    self.runAndCheckError(cmdStr,errorTag);
                end
            end
        end
        %
       
        function testPlotReg(self)
            [relStatProj,relDynProj]=checkMaster(1);
            [rel2StatProj,rel2DynProj]=checkMaster(10);
            rel=smartdb.relationoperators.union(relStatProj,relDynProj,...
                rel2StatProj,rel2DynProj);
            plObj=rel.plot();
            plObj.closeAllFigures();
            function [relStatProj,relDynProj]=checkMaster(nPoints)
                [~,relStatProj,relDynProj]=auxGenSimpleTubeAndProj(...
                    self,nPoints);
                %
                check(relStatProj,relDynProj);
                %
            end
            function check(relStatProj,relDynProj)
                plObj=relStatProj.plot();
                %
                try
                    relDynProj.plot(plObj);
                    plObj.closeAllFigures();
                catch meObj
                    plObj.closeAllFigures();
                    rethrow(meObj);
                end
            end
        end
        function testCatCommonTime(self)
            nFirstPoints=100;
            nSecPoints=150;
            nTubes=2;
            rel1=self.auxGenSimpleTubeAndProj(...
                nFirstPoints,nTubes,nFirstPoints);
            %
            rel2=self.auxGenSimpleTubeAndProj(...
                nSecPoints,nTubes,nSecPoints+nFirstPoints-1,nFirstPoints);
            %
            rel1.sortDetermenistically();
            rel2.sortDetermenistically();
            self.runAndCheckError('rel3=rel1.cat(rel2);',...
                'wrongInput:commonValuesDiff');
            rel1.cat(rel2,'isCommonValuesChecked',false);
            rel3=rel1.cat(rel2,'commonTimeAbsTol',2,'commonTimeRelTol',1);
            check(rel3,nFirstPoints,rel1,nFirstPoints);
            self.runAndCheckError(...
                'rel3=rel1.cat(rel2,''isReplacedByNew'',true);',...
                'wrongInput:commonValuesDiff');
            rel1.cat(rel2,'isReplacedByNew',true,...
                'isCommonValuesChecked',false);
            rel3=rel1.cat(rel2,'isReplacedByNew',true,...
                'commonTimeAbsTol',2,'commonTimeRelTol',1);
            check(rel3,nFirstPoints,rel2,1);
            %
            function check(relLeft,indLeft,relRight,indRight)
                import modgen.cell.cellstr2expression;
                fieldNameList=setdiff(relLeft.getFieldNameList(),...
                    relLeft.getNoCatOrCutFieldsList());
                %
                nFields=length(fieldNameList);
                isOkVec=false(1,nFields);
                for iField=1:nFields
                    fieldName=fieldNameList{iField};
                    if isnumeric(relLeft.(fieldName))
                        isOkVec(iField)=isequal(relLeft.(fieldName),...
                            relRight.(fieldName));
                    else
                        isOkVec(iField)=...
                            all(cellfun(...
                            @(x,y)isEqSmart(x,y,indLeft,indRight),...
                            relLeft.(fieldName),relRight.(fieldName)));
                    end
                end
                isOk=all(isOkVec);
                mlunitext.assert(isOk,sprintf('not consistent fields %s',...
                    cellstr2expression(fieldNameList(~isOkVec))));
                %
                function isOk=isEqSmart(leftArr,rightArr,indLeft,indRight)
                    nDims=ndims(leftArr);
                    leftArr=permute(leftArr,[nDims,1:nDims-1]);
                    rightArr=permute(rightArr,[nDims,1:nDims-1]);
                    isOk=isequal(leftArr(indLeft,:),rightArr(indRight,:));
                end
            end
        end
        function testThinOutTuples(self)
            nFirstPoints=100;
            nTubes=2;
            rel=self.auxGenSimpleTubeAndProj(...
                nFirstPoints,nTubes,nFirstPoints);
            rel2=rel.thinOutTuples([2,100]);
            rel2=rel.thinOutTuples(1:100);
            rel2=rel.thinOutTuples(1:2);
        end
        function testCatAdvanced(self)
            nFirstPoints=100;
            nSecPoints=150;
            nTubes=2;
            rel1=self.auxGenSimpleTubeAndProj(...
                nFirstPoints,nTubes,nFirstPoints);
            rel2=self.auxGenSimpleTubeAndProj(...
                nSecPoints,nTubes,nSecPoints+nFirstPoints,nFirstPoints+1);
            catRel=rel1.cat(rel2,'isReplacedByNew',true);
            isOk=all(catRel.indSTime==(nFirstPoints+nSecPoints));
            mlunitext.assert(isOk);
            %
            self.runAndCheckError(@badAction,...
                'wrongInput:commonTimeVecEntries');
            %
            function badAction()
                rel1.cat(rel1);
            end
        end
        %
        function varargout=auxGenSimpleTubeAndProj(~,...
                nPoints,nTubes,indSTime,indStart)
            persistent hashMap;
            if nargin<5
                indStart=1;
                if nargin<4
                    indSTime=nPoints;
                    if nargin<3
                        nTubes=1;
                    end
                end
            end
            if isempty(hashMap)
                hashMap=containers.Map();
            end
            varargout=cell(1,nargout);
            keyStr=mat2str([nargout,nPoints,nTubes,indSTime]);
            if hashMap.isKey(keyStr)
                argList=hashMap(keyStr);
                [varargout{:}]=deal(argList{:});
            else
                calcPrecision=0.001;
                approxSchemaDescr=char.empty(1,0);
                approxSchemaName=char.empty(1,0);
                nDims=2;
                lsGoodDirVec=[1;0];
                QArrayList=createQArrayList(ones(1,nDims));
                %aMat=zeros(nDims,nPoints);
                timeVec=indStart:(indStart+nPoints-1);
                aMat=repmat(sin(timeVec/10),nDims,1);
                sTime=indSTime;
                approxType=gras.ellapx.enums.EApproxType.Internal;
                %
                rel=create();
                qMat=diag([1,2]);
                QArrayList=createQArrayList(1:nDims);
                approxType=gras.ellapx.enums.EApproxType.External;
                rel.unionWith(create());
                relWithReg=rel.getCopy();
                relWithReg.scale(@(varargin)0.5,{});
                %
                relWithReg.MArray=cellfun(@(x)x*0.1,relWithReg.QArray,...
                    'UniformOutput',false);
                rel.unionWith(relWithReg);
                varargout{1}=rel;
                %
                if nargout>1
                    projMatList = {[1 0; 0 1].'};
                    %
                    projType=gras.ellapx.enums.EProjType.Static;
                    relStatProj=rel.project(projType,projMatList,@fGetProjMat);
                    varargout{2}=relStatProj;
                    if nargout>2
                        projType=gras.ellapx.enums.EProjType.DynamicAlongGoodCurve;
                        relDynProj=rel.project(projType,projMatList,@fGetProjMat);
                        varargout{3}=relDynProj;
                    end
                end
                hashMap(keyStr)=varargout;
            end
            function QArrayList=createQArrayList(diagVec)
                qMat=diag(diagVec);
                multVec=linspace(1,2,nPoints);
                QArray=repmat(qMat,[1,1,nPoints]);
                QArray=QArray.*repmat(shiftdim(multVec,-1),...
                    [nDims,nDims,1]);
                QArrayList=repmat({QArray},1,nTubes);
            end
            function [projOrthMatArray, projOrthMatTransArray] =...
                    fGetProjMat(projMat, timeVec, varargin)
                nTimePoints = length(timeVec);
                projOrthMatArray = repmat(projMat, [1, 1, nTimePoints]);
                projOrthMatTransArray = repmat(projMat.', [1,1,nTimePoints]);
            end
            function rel = create()
                multVec=cos(linspace(1,2,nPoints)/(10*pi))+...
                    linspace(1,2,nPoints);
                ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]).*...
                    repmat(reshape(multVec,[1,1,nPoints]),[nDims,nTubes]);
                rel=gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                    QArrayList, aMat, timeVec,...
                    ltGoodDirArray, sTime, approxType, approxSchemaName,...
                    approxSchemaDescr, calcPrecision);
            end
        end
        function aux_testSimpleCreate(self,isApproxSchemaUniform)
            nPoints=3;
            calcPrecision=0.001;
            approxSchemaDescr=char.empty(1,0);
            approxSchemaName=char.empty(1,0);
            nDims=2;
            nTubes=3;
            lsGoodDirVec=[1;0];
            QArrayList=repmat({repmat(eye(nDims),[1,1,nPoints])},1,nTubes);
            aMat=zeros(nDims,nPoints);
            timeVec=1:nPoints;
            sTime=nPoints;
            approxType=gras.ellapx.enums.EApproxType.Internal;
            
            rel1=create(); %#ok<NASGU>
            QArrayList=repmat({repmat(0.5*eye(nDims),[1,1,nPoints])},1,nTubes);
            approxType=gras.ellapx.enums.EApproxType.External;
            rel2=create(); %#ok<NASGU>
            check('wrongInput:touchCurveDependency');
            %
            QArrayList=repmat({repmat(diag([1 0.5]),[1,1,nPoints])},1,nTubes);
            rel2=create(); %#ok<NASGU>
            check('wrongInput:internalWithinExternal');
            %
            lsGoodDirVec=[0;1];
            QArrayList=repmat({repmat(diag([0.5 0.2]),[1,1,nPoints])},1,nTubes);
            
            rel1=create(); %#ok<NASGU>
            %
            check('wrongInput:touchLineValueFunc');
            %
            function check(errorTag)
                CMD_STR='rel1.getCopy().unionWith(rel2)';
                if nargin==0
                    eval(CMD_STR);
                else
                    self.runAndCheckError(CMD_STR,...
                        errorTag);
                end
            end
            function rel=create()
                ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
                if isApproxSchemaUniform
                    rel=gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                        QArrayList,aMat,timeVec,...
                        ltGoodDirArray,sTime,approxType,approxSchemaName,...
                        approxSchemaDescr,calcPrecision);
                else
                    approxTypeVec = repmat(approxType,nTubes,1);
                    approxSchemaNameCVec = repmat({approxSchemaName},nTubes,1);
                    approxSchemaDescrCVec = repmat({approxSchemaDescr},nTubes,1);
                    rel=gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                        QArrayList,aMat,timeVec,...
                        ltGoodDirArray,sTime,approxTypeVec,approxSchemaNameCVec,...
                        approxSchemaDescrCVec,calcPrecision);
                end
            end
        end
        function testSimpleCreate(self)
            self.aux_testSimpleCreate(true);
            self.aux_testSimpleCreate(false);
        end
        
        function testCreateSTimeOutOfBounds(self)
            nPoints=3;
            calcPrecision=0.001;
            approxSchemaDescr=char.empty(1,0);
            approxSchemaName=char.empty(1,0);
            nDims=2;
            nTubes=3;
            lsGoodDirVec=[1;0];
            QArrayList=repmat({repmat(eye(nDims),[1,1,nPoints])},1,nTubes);
            aMat=zeros(nDims,nPoints);
            timeVec=1:nPoints;
            sTime=nPoints+1;
            approxType=gras.ellapx.enums.EApproxType.Internal;
            
            self.runAndCheckError(@create,'wrongInput:sTimeOutOfBounds');
            
            function rel=create()
                ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
                rel=gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                    QArrayList,aMat,timeVec,...
                    ltGoodDirArray,sTime,approxType,approxSchemaName,...
                    approxSchemaDescr,calcPrecision);
            end
        end
        function testEllTubeFromEllArray(~)
            import gras.ellapx.smartdb.rels.EllTube.fromQArrays;
            import gras.ellapx.smartdb.rels.EllTube.fromEllArray;
            nPoints=5;
            calcPrecision=0.001;
            approxSchemaDescr=char.empty(1,0);
            approxSchemaName=char.empty(1,0);
            nDims=3;
            nTubes=1;
            lsGoodDirVec=[1;0;1];
            aMat=zeros(nDims,nPoints);
            timeVec=1:nPoints;
            sTime=nPoints;
            approxType=gras.ellapx.enums.EApproxType.Internal;
            %
            mArrayList=repmat({repmat(diag([0.1 0.2 0.3]),[1,1,nPoints])},...
                1,nTubes);
            qArrayList=repmat({repmat(diag([1 2 3]),[1,1,nPoints])},...
                1,nTubes);
            ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
            %
            ellArray(nPoints) = ellipsoid();
            arrayfun(@(iElem)fMakeEllArrayElem(iElem), 1:nPoints);
            %
            fromMatEllTube=gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                qArrayList, aMat, timeVec,...
                ltGoodDirArray, sTime, approxType, approxSchemaName,...
                approxSchemaDescr, calcPrecision);
            fromMatMEllTube=gras.ellapx.smartdb.rels.EllTube.fromQMArrays(...
                qArrayList, aMat, mArrayList, timeVec,...
                ltGoodDirArray, sTime, approxType, approxSchemaName,...
                approxSchemaDescr, calcPrecision);
            fromEllArrayEllTube = ...
                gras.ellapx.smartdb.rels.EllTube.fromEllArray(...
                ellArray, timeVec,...
                ltGoodDirArray, sTime, approxType, approxSchemaName,...
                approxSchemaDescr, calcPrecision);
            fromEllMArrayEllTube=...
                gras.ellapx.smartdb.rels.EllTube.fromEllMArray(...
                ellArray, mArrayList{1}, timeVec,...
                ltGoodDirArray, sTime, approxType, approxSchemaName,...
                approxSchemaDescr, calcPrecision);
            %
            [isEqual,reportStr]=...
                fromEllArrayEllTube.isEqual(fromMatEllTube);
            mlunitext.assert(isEqual,reportStr);
            [isEqual,reportStr]=...
                fromEllMArrayEllTube.isEqual(fromMatMEllTube);
            mlunitext.assert(isEqual,reportStr);
            %
            function fMakeEllArrayElem(iElem)
                ellArray(iElem) = ellipsoid(...
                    aMat(:,iElem), qArrayList{1}(:,:,iElem));
            end
        end
        function self = testEllArrayFromEllTube(self)
            import gras.ellapx.enums.EApproxType;
            %
            qMatArray(:,:,2) = [1,0;0,2];
            qMatArray(:,:,1) = [5,0;0,6];
            aMat(:,2) = [1,2];
            aMat(:,1) = [5,6];
            ellArray = ellipsoid(aMat,qMatArray);
            timeVec = [1,2];
            sTime = 2;
            lsGoodDirMat=[1,0;0,1];
            lsGoodDirArray(:,:,1) = lsGoodDirMat;
            lsGoodDirArray(:,:,2) = lsGoodDirMat;
            approxSchemaDescr=char.empty(1,0);
            approxSchemaName=char.empty(1,0);
            calcPrecision=0.001;
            extFromEllArrayEllTube = ...
                gras.ellapx.smartdb.rels.EllTube.fromEllArray(...
                ellArray, timeVec,...
                lsGoodDirArray, sTime, EApproxType.External, ...
                approxSchemaName,...
                approxSchemaDescr, calcPrecision);
            [extFromEllTubeEllArray extTimeVec] =...
                extFromEllArrayEllTube.getEllArray(EApproxType.External);
            [isOk, reportStr] = extFromEllTubeEllArray(1).isEqual(ellArray(1));
            mlunitext.assert(isOk,reportStr);
            [isOk, reportStr] = extFromEllTubeEllArray(2).isEqual(ellArray(2));
            mlunitext.assert(isOk,reportStr);
            mlunitext.assert(all(extTimeVec == [1 2]));
            %
            intFromEllArrayEllTube = ...
                gras.ellapx.smartdb.rels.EllTube.fromEllArray(...
                ellArray, timeVec,...
                lsGoodDirArray, sTime, EApproxType.Internal, ...
                approxSchemaName,...
                approxSchemaDescr, calcPrecision);
            [intFromEllTubeEllArray intTimeVec] =...
                intFromEllArrayEllTube.getEllArray(EApproxType.Internal);
            [isOk, reportStr] = intFromEllTubeEllArray(1).isEqual(ellArray(1));
            mlunitext.assert(isOk,reportStr);
            [isOk, reportStr] = intFromEllTubeEllArray(2).isEqual(ellArray(2));
            mlunitext.assert(isOk,reportStr);
            mlunitext.assert(all(intTimeVec == [1 2]));
            % no assertions, just error test
            intFromEllArrayEllTube.getEllArray(EApproxType.External);
            [~, ~] =...
                intFromEllArrayEllTube.getEllArray(EApproxType.External);
            extFromEllArrayEllTube.getEllArray(EApproxType.Internal);
            [~, ~] =...
                extFromEllArrayEllTube.getEllArray(EApproxType.Internal);
        end
        
        function [qMatArray, aMat, timeVec, sTime, lsGoodDirArray,...
                approxSchemaDescr, approxSchemaName] = ...
                getSimpleInputData(~)
            qMatArray(:,:,3) = [1,0;0,2];
            qMatArray(:,:,2) = [3,0;0,4];
            qMatArray(:,:,1) = [5,0;0,6];
            aMat(:,3) = [1,2];
            aMat(:,2) = [3,4];
            aMat(:,1) = [5,6];
            timeVec = [1,2,3];
            sTime = 1;
            lsGoodDirMat=[1;0];
            lsGoodDirArray(:,:,1) = lsGoodDirMat;
            lsGoodDirArray(:,:,2) = lsGoodDirMat;
            lsGoodDirArray(:,:,3) = lsGoodDirMat;
            approxSchemaDescr=char.empty(1,0);
            approxSchemaName=char.empty(1,0);
        end
        function testInterpAdvanced(self)
            nTubes=3;
            nPoints=10;
            [rel,relStatProj,relDynProj]=auxGenSimpleTubeAndProj(self,...
                nPoints,nTubes);
            %
            timeVec=rel.timeVec{1};
            checkScalarTime(min(timeVec),rel);
            checkScalarTime(max(timeVec),rel);
            checkScalarTime(max(timeVec),relStatProj);
            checkScalarTime(min(timeVec),relStatProj);
            checkScalarTime(max(timeVec),relDynProj);
            checkScalarTime(min(timeVec),relDynProj);
            %
            function checkScalarTime(interpTime,inpRel)
                interpRel=inpRel.interp(interpTime);
                mlunitext.assert(all(cellfun(@(x)numel(x)==1,...
                    interpRel.timeVec)));
            end
        end
        function self = testInterp(self)
            import gras.ellapx.enums.EApproxType;
            %
            INTERP_TIME_VEC=[1,1.6,2,2.3,3];
            [qMatArray, aMat, timeVec, sTime, lsGoodDirArray,...
                approxSchemaDescr, approxSchemaName] = ...
                self.getSimpleInputData();
            approxType = EApproxType.Internal;
            CALC_PRECISION=0.01;
            fromMat1EllTube = ...
                gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                {qMatArray}, aMat, timeVec,...
                lsGoodDirArray, sTime, approxType, approxSchemaName,...
                approxSchemaDescr, CALC_PRECISION);
            fromMat1EllTubeDouble = ...
                gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                {qMatArray, qMatArray}, aMat, timeVec,...
                [lsGoodDirArray,lsGoodDirArray], sTime,...
                approxType, approxSchemaName,...
                approxSchemaDescr, CALC_PRECISION);
            interpEllTube = fromMat1EllTube.interp(INTERP_TIME_VEC);
            interpDoubleEllTube =...
                fromMat1EllTubeDouble.interp(INTERP_TIME_VEC);
            mlunitext.assert(all(interpEllTube.aMat{1}(:,2)==[3;4]));
            mlunitext.assert(...
                all(interpEllTube.aMat{1}(:,4)==[3;4]));
            mlunitext.assert(...
                all(interpEllTube.QArray{1}(:,:,4)==[3,0;0,4]));
            mlunitext.assert(...
                all(interpEllTube.QArray{1}(:,:,2)==[3,0;0,4]));
            mlunitext.assert(all(interpDoubleEllTube.aMat{1}(:,2)==[3;4]));
            mlunitext.assert(all(interpDoubleEllTube.aMat{2}(:,4)==[3;4]));
            mlunitext.assert(...
                all(interpDoubleEllTube.QArray{1}(:,:,4)==[3,0;0,4]));
            mlunitext.assert(...
                all(interpDoubleEllTube.QArray{2}(:,:,2)==[3,0;0,4]));
            %
            projSpaceList = {[1,0;0,1].'};
            projType=gras.ellapx.enums.EProjType.DynamicAlongGoodCurve;
            interpProjTube =...
                interpEllTube.project(projType, projSpaceList,...
                @fGetProjMat);
            noInterpProjTube = fromMat1EllTube.project(projType, ...
                projSpaceList, @fGetProjMat);
            interpProj2Tube = noInterpProjTube.interp([1,1.5,2,2.5,3]);
            mlunitext.assert(all(all(interpProj2Tube.aMat{1}-...
                interpProjTube.aMat{1} < CALC_PRECISION)));
            mlunitext.assert(all(all(all(interpProj2Tube.QArray{1}-...
                interpProjTube.QArray{1} < CALC_PRECISION))));
            self.runAndCheckError(...
                'fromMat1EllTube.interp([])','wrongInput');
            self.runAndCheckError(...
                'fromMat1EllTube.interp([0])','wrongInput');
            self.runAndCheckError(...
                'fromMat1EllTube.interp([10])','wrongInput');
            self.runAndCheckError(...
                'fromMat1EllTube.interp([1,2;3,4])','wrongInput');
            ellTubeVec = [interpEllTube, interpEllTube];
            self.runAndCheckError(...
                'ellTubeVec.interp([2])',':noScalarObj');
            %
            function [projOrthMatArray,projOrthMatTransArray]=...
                    fGetProjMat(projMat,timeVec,varargin)
                nTimePoints=length(timeVec);
                projOrthMatArray=repmat(projMat,[1,1,nTimePoints]);
                projOrthMatTransArray=repmat(projMat.',[1,1,nTimePoints]);
            end
        end
        %
        function self = testIsEqual(self)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.smartdb.rels.EllUnionTube;
            import gras.ellapx.smartdb.rels.EllUnionTubeStaticProj;
            %
            IS_LINEAR_INTERP=false;
            [qMatArray, aMat, timeVec, sTime, lsGoodDirArray,...
                approxSchemaDescr, approxSchemaName] = ...
                self.getSimpleInputData();
            approx1Type = EApproxType.Internal;
            approx2Type = EApproxType.External;
            CHECK_INEQUALITY = 1;
            CALC_PRECISION=0.01;
            mixedExtIntEllTube = ...
                gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                {qMatArray,qMatArray,qMatArray}, aMat, timeVec,...
                [lsGoodDirArray,lsGoodDirArray,lsGoodDirArray], sTime, ...
                [approx1Type,approx2Type,approx1Type]',...
                approxSchemaName,...
                approxSchemaDescr, CALC_PRECISION);
            mixedExtInt2EllTube = ...
                gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                {qMatArray,qMatArray,qMatArray}, aMat, timeVec,...
                [lsGoodDirArray,lsGoodDirArray,lsGoodDirArray], sTime, ...
                [approx1Type,approx1Type,approx2Type]',...
                approxSchemaName,...
                approxSchemaDescr, CALC_PRECISION);
            nonMixedEllTube = ...
                gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                {qMatArray,qMatArray,qMatArray}, aMat, timeVec,...
                [lsGoodDirArray,lsGoodDirArray,lsGoodDirArray], sTime, ...
                [approx1Type,approx1Type,approx1Type]',...
                approxSchemaName,...
                approxSchemaDescr, CALC_PRECISION);
            % nonscalar input
            myEllTubeArr = [nonMixedEllTube,nonMixedEllTube];
            self.runAndCheckError(...
                'myEllTubeArr.isEqual(nonMixedEllTube)','noScalarObj');
            self.runAndCheckError(...
                'nonMixedEllTube.isEqual(myEllTubeArr)','noScalarObj');
            % self equal
            fCheckIsEqual(mixedExtIntEllTube, mixedExtIntEllTube);
            fCheckIsEqual(nonMixedEllTube, nonMixedEllTube);
            % inequal because of different approxType
            fCheckIsEqual(nonMixedEllTube, mixedExtIntEllTube, ...
                CHECK_INEQUALITY);
            fCheckIsEqual(mixedExtIntEllTube, nonMixedEllTube, ...
                CHECK_INEQUALITY);
            % equality of differently sorted tubes
            fCheckIsEqual(mixedExtIntEllTube, mixedExtInt2EllTube);
            % enclosed time vectors
            interpTimeVec = [1,1.5,2,2.5,3];
            interpMixedEllTube = ...
                mixedExtIntEllTube.interp(interpTimeVec);
            interpMixed2EllTube = ...
                mixedExtInt2EllTube.interp(interpTimeVec);
            fCheckIsEqual(mixedExtIntEllTube, interpMixedEllTube);
            fCheckIsEqual(interpMixedEllTube, mixedExtInt2EllTube);
            fCheckIsEqual(interpMixed2EllTube, mixedExtInt2EllTube);
            % inenclosed time vectors
            q2MatArray = qMatArray(:,:,1:2:3);
            a2Mat = aMat(:,1:2:3);
            ls2GoodDirArray = lsGoodDirArray(:,:,1:2:3);
            smallerTimeVec = [1,3];
            smallerMixedEllTube = ...
                gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                {q2MatArray,q2MatArray,q2MatArray}, a2Mat, ...
                smallerTimeVec,...
                [ls2GoodDirArray,ls2GoodDirArray,ls2GoodDirArray],sTime,...
                [approx1Type,approx2Type,approx1Type]',...
                approxSchemaName,...
                approxSchemaDescr, CALC_PRECISION);
            fCheckIsEqual(smallerMixedEllTube, mixedExtInt2EllTube);
            interp2TimeVec = [1,1.5,3];
            interpSmallerEllTube = smallerMixedEllTube.interp(...
                interp2TimeVec);
            %
            if IS_LINEAR_INTERP
                fCheckIsEqual(interpSmallerEllTube, mixedExtInt2EllTube);
            end
            %
            % different time vectors
            badTimeVec = [1,4];
            badTimedMixedEllTube = ...
                gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                {q2MatArray,q2MatArray,q2MatArray}, a2Mat, badTimeVec,...
                [ls2GoodDirArray,ls2GoodDirArray,ls2GoodDirArray],sTime,...
                [approx1Type,approx2Type,approx1Type]',...
                approxSchemaName,...
                approxSchemaDescr, CALC_PRECISION);
            %
            if IS_LINEAR_INTERP
                fCheckIsEqual(badTimedMixedEllTube, smallerMixedEllTube,...
                    CHECK_INEQUALITY);
            end
            % projection
            projSpaceList = {[1,0;0,1].'};
            projType=gras.ellapx.enums.EProjType.Static;
            projEllTube = mixedExtIntEllTube.project(projType,...
                projSpaceList, @fGetProjMat);
            self.runAndCheckError(...
                ['projEllTube.isEqual('...
                'mixedExtIntEllTube)'],'wrongInput');
            proj2EllTube = interpMixedEllTube.project(projType,...
                projSpaceList, @fGetProjMat);
            fCheckIsEqual(projEllTube, proj2EllTube);
            proj2EllTube = interpSmallerEllTube.project(projType,...
                projSpaceList, @fGetProjMat);
            if IS_LINEAR_INTERP
                fCheckIsEqual(proj2EllTube, projEllTube);
            end
            mlunitext.assert(isEqual, reportStr);
            % union
            unionEllTube = EllUnionTube.fromEllTubes(...
                mixedExtIntEllTube);
            union2EllTube = EllUnionTube.fromEllTubes(...
                mixedExtInt2EllTube);
            fCheckIsEqual(unionEllTube, union2EllTube);
            unionProjEllTube = ...
                EllUnionTubeStaticProj.fromEllTubes(...
                proj2EllTube);
            unionProj2EllTube = ...
                EllUnionTubeStaticProj.fromEllTubes(...
                projEllTube);
            if IS_LINEAR_INTERP
                fCheckIsEqual(unionProjEllTube, unionProj2EllTube);
            end
            %
            function fCheckIsEqual(ellTube1, ellTube2, notEqual)
                [isEqual, reportStr] = ellTube1.isEqual(...
                    ellTube2);
                if (nargin == 3 && notEqual == 1)
                    mlunitext.assert(~isEqual, reportStr);
                else
                    mlunitext.assert(isEqual, reportStr);
                end
            end
            function [projOrthMatArray,projOrthMatTransArray]=...
                    fGetProjMat(projMat,timeVec,varargin)
                nTimePoints=length(timeVec);
                projOrthMatArray=repmat(projMat,[1,1,nTimePoints]);
                projOrthMatTransArray=repmat(projMat.',[1,1,nTimePoints]);
            end
        end
        %
        function testUnionFromEllTubesAdvanced(self)
            nTubes=3;
            nPoints=10;
            [rel,relStatProj]=auxGenSimpleTubeAndProj(self,...
                nPoints,nTubes);
            rel1=gras.ellapx.smartdb.rels.EllUnionTube.fromEllTubes(...
                rel);
            rel2=gras.ellapx.smartdb.rels.EllUnionTubeStaticProj.fromEllTubes(...
                relStatProj);
        end
        function self = testUnionFromEllTubes(self)
            check([0 2]);
            check([1 2]);
            function check(multVec)
                import gras.ellapx.enums.EApproxType;
                import gras.ellapx.smartdb.rels.EllUnionTubeStaticProj;
                import gras.ellapx.smartdb.rels.EllUnionTube;
                qMatArray(:,:,2) = [1,0,0.1;0,2,0;0.1,0,3];
                qMatArray(:,:,1) = [5,0,0.1;0,6,0;0.1,0,7];
                aMat(:,2) = [1,2,3];
                aMat(:,1) = [5,6,7];
                ellArray = ellipsoid(aMat,qMatArray);
                timeVec = [1,2];
                sTime = 2;
                lsGoodDirMat=[1,0,0;0,2,0;0,0,3];
                ltGoodDirArray(:,:,1) = lsGoodDirMat*multVec(1);
                ltGoodDirArray(:,:,2) = lsGoodDirMat*multVec(2);
                approxSchemaDescr=char.empty(1,0);
                approxSchemaName=char.empty(1,0);
                calcPrecision=0.001;
                testEllTube = ...
                    gras.ellapx.smartdb.rels.EllTube.fromEllArray(...
                    ellArray, timeVec,...
                    ltGoodDirArray, sTime, EApproxType.External, ...
                    approxSchemaName,...
                    approxSchemaDescr, calcPrecision);
                %
                testEllUnionTube=...
                    gras.ellapx.smartdb.rels.EllUnionTube.fromEllTubes(...
                    testEllTube);
                %
                projSpaceList = {[1 0 0; 0 1 1]};
                projType = gras.ellapx.enums.EProjType.Static;
                testEllProj = testEllTube.project(projType,projSpaceList,...
                    @fGetProjMat);
                testEllUnionStaticProj = ...
                    EllUnionTubeStaticProj.fromEllTubes(testEllProj);
                testEllUnionTube = EllUnionTube.fromEllTubes(testEllTube);
                testEllUnionStaticProj0 = testEllUnionTube.project(...
                    projType,projSpaceList,@fGetProjMat);
                [isEqual, reportStr] = testEllUnionStaticProj.isEqual(...
                    testEllUnionStaticProj0);
                mlunitext.assert(isEqual, reportStr);
                %
                function [projOrthMatArray,projOrthMatTransArray]=...
                        fGetProjMat(projMat,timeVec,varargin)
                    nTimePoints=length(timeVec);
                    projOrthMatArray=repmat(projMat,[1,1,nTimePoints]);
                    projOrthMatTransArray=repmat(projMat.',[1,1,nTimePoints]);
                end
            end
        end
        function self = testRelativeComparison(self)
            nPoints=5;
            relTolerance=0.01;
            lsGoodDirVec=[1;0;1];
            timeVec=1:nPoints;
            sTime=nPoints;
            fCheckFun = @(x, y) x.isEqual(y, 'MaxRelativeTolerance', ...
                relTolerance);
            %
            qArrayListBase = repmat({repmat(diag([1 2 3]), [1, 1, ...
                nPoints])}, 1, 1);
            firstEllTube = createSimpleRel(lsGoodDirVec, ...
                qArrayListBase, timeVec, sTime);
            %
            qArrayList = {qArrayListBase{:} .* (1 - 0.5 * relTolerance)};
            secondEllTube = createSimpleRel(lsGoodDirVec, ...
                qArrayList, timeVec, sTime);
            [isEqual,reportStr] = fCheckFun(firstEllTube, secondEllTube);
            mlunitext.assert(isEqual,reportStr);
            %
            qArrayList = {qArrayListBase{:} .* (1 + 2 * relTolerance)};
            secondEllTube = createSimpleRel(lsGoodDirVec, ...
                qArrayList, timeVec, sTime);
            [isEqual,~] = fCheckFun(firstEllTube, secondEllTube);
            mlunitext.assert(~isEqual, ['Ellipsoids relative', ...
                ' difference must be greater than  tolerance']);
            %
            function rel = createSimpleRel(lsGoodDirVec, qArrayList, ...
                    timeVec, sTime)
                import gras.ellapx.smartdb.rels.EllTube;
                %
                calcPrecision = 0.001;
                nTubes = size(qArrayList, 2);
                approxSchemaDescr = char.empty(1,0);
                approxSchemaName = char.empty(1,0);
                approxType = gras.ellapx.enums.EApproxType.Internal;
                nTimePoints = timeVec(end);
                if ~isempty(qArrayList)
                    nDims = size(qArrayList{1}, 1);
                else
                    rel = [];
                    return;
                end
                aMat = zeros(nDims,nTimePoints);
                ltGoodDirArray = repmat(lsGoodDirVec,[1,nTubes,nTimePoints]);
                %
                rel = EllTube.fromQArrays(qArrayList, aMat, timeVec,...
                    ltGoodDirArray, sTime, approxType, approxSchemaName,...
                    approxSchemaDescr, calcPrecision);
            end
        end
    end
end