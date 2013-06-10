classdef SuiteEllTube < mlunitext.test_case
    
    methods
        function self = SuiteEllTube(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function tear_down(~)
            close all;
        end
        function testCutAndCat(~)
            nDims=2;
            nTubes=3;
            calcPrecision=0.001;
            cutTimeVec = [20, 80];
            timeVec = 1 : 100;
            evolveTimeVec = 101 : 200;
            fieldToExcludeList = {'sTime','lsGoodDirVec'};
            % cut: test interval
            rel = create(timeVec);
            cutRel = rel.cut(cutTimeVec);
            expRel = create(cutTimeVec(1) : cutTimeVec(2));
            fieldList = setdiff(fieldnames(cutRel),fieldToExcludeList);
            [isOk,reportStr] = ...
                cutRel.getFieldProjection(fieldList).isEqual(...
                expRel.getFieldProjection(fieldList));
            mlunitext.assert(isOk, reportStr);
            % cut: test point
            rel = create(timeVec);
            cutRel = rel.cut(timeVec(end) / 2);
            expRel = create(timeVec(end) / 2);
            [isOk,reportStr] = ...
                cutRel.getFieldProjection(fieldList).isEqual(...
                expRel.getFieldProjection(fieldList));
            mlunitext.assert(isOk, reportStr);
            % cat: test
            firstRel = create(timeVec);
            secondRel = create(evolveTimeVec);
            expRel = create([timeVec evolveTimeVec]);
            catRel = firstRel.cat(secondRel);
            [isOk,reportStr] = ...
                catRel.getFieldProjection(fieldList).isEqual(...
                expRel.getFieldProjection(fieldList));
            mlunitext.assert(isOk, reportStr);
            %
            function rel = create(timeVec)
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
        function testProjectionAndScale(~)
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
            projType=gras.ellapx.enums.EProjType.Static;
            projMatList={[1 0 1;0 1 1],[1 0 0;0 1 0]};
            rel=create();
            relProj=rel.project(projType,projMatList,@fGetProjMat); 
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

        
        
        function testPlotTouch(self)
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
        %
        function [rel,relStatProj,relDynProj]=auxGenSimpleTubeAndProj(~,...
                nPoints,nTubes)
            calcPrecision=0.001;
            approxSchemaDescr=char.empty(1,0);
            approxSchemaName=char.empty(1,0);
            nDims=2;
            if nargin<3
                nTubes=1;
            end
            lsGoodDirVec=[1;0];
            qMat=eye(nDims);
            QArrayList=repmat({repmat(qMat,[1,1,nPoints])},1,nTubes);
            aMat=zeros(nDims,nPoints);
            timeVec=1:nPoints;
            sTime=nPoints;
            approxType=gras.ellapx.enums.EApproxType.Internal;
            %
            rel=create();
            qMat=diag([1,2]);
            QArrayList=repmat({repmat(qMat,[1,1,nPoints])},1,nTubes);
            approxType=gras.ellapx.enums.EApproxType.External;
            rel.unionWith(create());
            relWithReg=rel.getCopy();
            relWithReg.scale(@(varargin)0.5,{});
            %
            relWithReg.MArray=cellfun(@(x)x*0.1,relWithReg.QArray,...
                'UniformOutput',false);
            rel.unionWith(relWithReg);
            %
            projSpaceList = {[1 0; 0 1].'};
            %
            projType=gras.ellapx.enums.EProjType.Static;
            relStatProj=rel.project(projType,projSpaceList,@fGetProjMat);
            %
            projType=gras.ellapx.enums.EProjType.DynamicAlongGoodCurve;
            relDynProj=rel.project(projType,projSpaceList,@fGetProjMat);
            function [projOrthMatArray, projOrthMatTransArray] =...
                    fGetProjMat(projMat, timeVec, varargin)
                nTimePoints = length(timeVec);
                projOrthMatArray = repmat(projMat, [1, 1, nTimePoints]);
                projOrthMatTransArray = repmat(projMat.', [1,1,nTimePoints]);
            end
            function rel = create()
                ltGoodDirArray=repmat(lsGoodDirVec,[1,nTubes,nPoints]);
                rel=gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                    QArrayList, aMat, timeVec,...
                    ltGoodDirArray, sTime, approxType, approxSchemaName,...
                    approxSchemaDescr, calcPrecision);
            end
        end
        function testSimpleCreate(self)
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
                rel=gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                    QArrayList,aMat,timeVec,...
                    ltGoodDirArray,sTime,approxType,approxSchemaName,...
                    approxSchemaDescr,calcPrecision);
            end
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
            [isOk, reportStr] = extFromEllTubeEllArray(1).eq(ellArray(1));
            mlunitext.assert(isOk,reportStr);
            [isOk, reportStr] = extFromEllTubeEllArray(2).eq(ellArray(2));
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
            [isOk, reportStr] = intFromEllTubeEllArray(1).eq(ellArray(1));
            mlunitext.assert(isOk,reportStr);
            [isOk, reportStr] = intFromEllTubeEllArray(2).eq(ellArray(2));
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
        %
        function self = testUnionFromEllTubes(self)
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.smartdb.rels.EllUnionTubeStaticProj;
            import gras.ellapx.smartdb.rels.EllUnionTube;
            %
            qMatArray(:,:,2) = [1,0,0;0,2,0;0,0,3];
            qMatArray(:,:,1) = [5,0,0;0,6,0;0,0,7];
            aMat(:,2) = [1,2,3];
            aMat(:,1) = [5,6,7];
            ellArray = ellipsoid(aMat,qMatArray);
            timeVec = [1,2];
            sTime = 2;
            lsGoodDirMat=[1,0,0;0,1,0;0,0,1];
            lsGoodDirArray(:,:,1) = lsGoodDirMat;
            lsGoodDirArray(:,:,2) = lsGoodDirMat;
            approxSchemaDescr=char.empty(1,0);
            approxSchemaName=char.empty(1,0);
            calcPrecision=0.001;
            testEllTube = ...
                gras.ellapx.smartdb.rels.EllTube.fromEllArray(...
                ellArray, timeVec,...
                lsGoodDirArray, sTime, EApproxType.External, ...
                approxSchemaName,...
                approxSchemaDescr, calcPrecision);
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
end