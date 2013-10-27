 %classdef TestDynGettersBaseTestCase < mlunitext.test_case
 classdef TestDynGettersBaseTestCase
    properties (Access=private)
        testDataRootDir
        linSys
        reachObj
        tVec
        x0Ell
        l0Mat
        expDim
        reachFactoryObj
        bpbFunc
    end
    methods
        function self = TestDynGettersBaseTestCase(reachObj,reachFactoryObj,bpbFunc)
             self.reachObj=reachObj;
%             self = self@mlunitext.test_case(varargin{:});
%             [~, className] = modgen.common.getcallernameext(1);
%             shortClassName = mfilename('classname');
%             self.testDataRootDir = [fileparts(which(className)),...
%                 filesep, 'TestData', filesep, shortClassName];
            self.bpbFunc=bpbFunc;
            self.reachFactoryObj=reachFactoryObj;
        end
        %
        function self = set_up_param(self, reachFactObj)
            self.reachFactoryObj=reachFactObj;
            self.reachObj = reachFactObj.createInstance();
            self.linSys = reachFactObj.getLinSys();
            self.expDim = reachFactObj.getDim();
            self.tVec = reachFactObj.getTVec();
            self.x0Ell = reachFactObj.getX0Ell();
            self.l0Mat = reachFactObj.getL0Mat();
        end
    end
   methods 
       function isOk = baseTestDynGetters(self)
            isOk=true;
            CMP_TOL=1e-10;
            ellTubeRel=self.reachObj.getEllTubeRel();
            switchSysTimeVec=self.reachObj.getSwitchTimeVec();
            switchTimeVecLenght=numel(switchSysTimeVec);
            intProbDynamicsList=self.reachObj.getIntProbDynamicsList();
            extProbDynamicsList=self.reachObj.getExtProbDynamicsList();
            goodDirSetList=self.reachObj.getGoodDirSetList();
            intEllTube=ellTubeRel.getTuplesFilteredBy('approxType', gras.ellapx.enums.EApproxType.Internal);
            extEllTube=ellTubeRel.getTuplesFilteredBy('approxType',gras.ellapx.enums.EApproxType.External);
            linSysList=self.reachObj.getSystemList();
            sysTimeVecLenght=numel(linSysList);
            regTol=self.reachFactoryObj.getRelTol();
            isRegEnabled=self.reachFactoryObj.getIsRegEnabled();
            isJustCheck=self.reachFactoryObj.getIsJustCheck();
            isReg=isRegEnabled&&(~isJustCheck);
            isBackward=self.reachObj.isbackward();
            hasOk=auxtestProbDynGetters(intEllTube,intProbDynamicsList,goodDirSetList);
            isOk=isOk&&hasOk;
            hasOk=auxtestProbDynGetters(extEllTube,extProbDynamicsList,goodDirSetList);
            isOk=isOk&&hasOk;
            %
            function isOk=auxtestProbDynGetters(ellTube,probDynamicsList,goodDirSetList)
                isOk=true;
                nTube=ellTube.getNTuples();
                goodDirOrderedVec=zeros(1,nTube);
                
                %3) comparison of good directions obtained from GoodDirSetList and EllTubeRel
                
                isEqual=compareGoodCurves(ellTube,goodDirSetList);
                isOk=isOk&&isEqual;
                %2)comparing results of linSys and probDynObj.getBPBgetBPBTransDynamics().evaluate(t)
                
                probDynamicsListLenght=numel(probDynamicsList);
                if (sysTimeVecLenght~=probDynamicsListLenght)
                    isOk=false;
                end;
                isEqual=isEqualBPBandpDynBPB(probDynamicsList);
                isOk=isOk&&isEqual;
                
                %1) comparison of the results obtained from getEllTubeRel and probDynObj.getX0Mat();
                
                isEqual=compareX0Mat(ellTube,probDynamicsList,nTube);
                isOk=isOk&&isEqual;
                
                function isEqual=compareX0Mat(ellTube,probDynamicsList,nTube)
                    isEqual=true;
                    for iTube=1:nTube
                        timeVec=ellTube.timeVec{iTube};
                        switchIndexVec=makeSwitchIndVec(timeVec);
                        probDynObj=probDynamicsList{1}{1};
                        isCurrentEqual=isEqualCurX0(ellTube,probDynObj,timeVec,...
                            switchIndexVec(1),iTube);
                        isEqual=isEqual&&isCurrentEqual;
                        if ((switchTimeVecLenght-1>=2)&&(nTube~=numel(probDynamicsList{2})))
                            isEqual=false;
                        end;
                        if (switchTimeVecLenght-1>=2)&&(isEqual)
                            for iSwitch=2:switchTimeVecLenght-1
                                indTube=goodDirOrderedVec(iTube);
                                probDynObj=probDynamicsList{iSwitch}{indTube};
                                isCurrentEqual=isEqualCurX0(ellTube,probDynObj,timeVec,...
                                    switchIndexVec(iSwitch),iTube);
                                isEqual=isEqual&&isCurrentEqual;
                            end;
                        end;
                    end;
                    %
                    function isCurrentEqual=isEqualCurX0(ellTube,probDynObj,timeVec,ind,iTube)
                        qDynMat=probDynObj.getX0Mat();
                        currentTime=findCurrentTime(timeVec,ind);
                        qMat=ellTube.QArray{iTube}(:,:,currentTime);
                        isCurrentEqual=modgen.common.absrelcompare(qDynMat,...
                            qMat, CMP_TOL, [], @abs);
                    end
                end
                %
                function curTime=findCurrentTime(iTubeTimeVec,switchIndex)
                    if (isBackward)
                        iTubeTimeVecSize=size(iTubeTimeVec);
                        curTime=iTubeTimeVecSize(2)-switchIndex+1;
                    else
                        curTime=switchIndex;
                    end;
                end
                %
                function isEqual=isEqualBPBandpDynBPB(probDynamicsList)
                    isEqual=true;
                    probDynObj=probDynamicsList{1}{1};
                    timeVec=probDynObj.getTimeVec();
                    for iTuple=1:nTube
                        isCurEqual=isEqualBPBandpDynBPBTimeInterval(probDynObj,timeVec,1);
                        isEqual=isEqual&&isCurEqual;
                        if ((switchTimeVecLenght-1>=2)&&(nTube~=numel(probDynamicsList{2}))...
                                ||(sysTimeVecLenght~=numel(probDynamicsList)))
                            isEqual=false;
                        end;
                        if (isEqual)&&(sysTimeVecLenght>1)
                            for iLinSys = 2 : sysTimeVecLenght
                                timeVec=probDynamicsList{iLinSys}{iTuple}.getTimeVec();
                                probDynObj=probDynamicsList{iLinSys}{iTuple};
                                isCurEqual=isEqualBPBandpDynBPBTimeInterval(probDynObj,timeVec,iLinSys);
                                isEqual=isEqual&&isCurEqual;
                            end;
                        end;
                    end;
                    %
                    function isCurEqual=isEqualBPBandpDynBPBTimeInterval(probDynObj,timeVec,iLinSys)
                        timeSize=size(timeVec);
                        isCurEqualVec=true(1,timeSize(2));
                        iStep=1;
                        for curTime=timeVec                            
                            pDynBPBMat=probDynObj.getBPBTransDynamics().evaluate(curTime);                                                       
                            if (isBackward)
                                pDynBPBMat=self.bpbFunc(pDynBPBMat,probDynObj,curTime);                                
                            end;                          
                            isCurEqualVec(iStep)=isEqualBPBandpDynBPBatCurTime(pDynBPBMat,...
                                curTime,iLinSys);
                            iStep=iStep+1;
                        end;
                        isCurEqual=all(isCurEqualVec);
                    end
                    %
                    function isCurEqual=isEqualBPBandpDynBPBatCurTime(pDynBPBMat,curTime,iLinSys)
                        t=curTime;
                        bCMat=linSysList{iLinSys}.getBtMat();
                        bMat=cellfun(@eval,bCMat);
                        uBoundsEll=linSysList{iLinSys}.getUBoundsEll();
                        pCMat=uBoundsEll.shape();
                        pMat=cellfun(@eval,pCMat);
                        bpbMat=bMat*pMat*(bMat)';
                        if (isReg)
                            fPosReg=@(x)gras.mat.MatrixPosReg(x,regTol);
                            bpbRegMat=gras.mat.AConstMatrixFunction(bpbMat);
                            bpbPosReg=fPosReg(bpbRegMat);
                            bpbMat=bpbPosReg.evaluate(t);
                        end;
                        isCurEqual=modgen.common.absrelcompare(bpbMat,pDynBPBMat, CMP_TOL, [], @abs);
                    end
                end
                %
                function switchIndexVec=makeSwitchIndVec(timeVec)
                    switchIndexVec=zeros(1,switchTimeVecLenght);
                    for iSwitch=1:switchTimeVecLenght
                        sIndex=find(timeVec==switchSysTimeVec(iSwitch));
                        switchIndexVec(iSwitch)=sIndex;
                    end;
                end
                %
                function mapGoodDirInd(goodDirSetObj,ellTube)
                    nTuples = ellTube.getNTuples;
                    lsGoodDirMat = goodDirSetObj.getlsGoodDirMat();
                    for iGoodDir = 1:size(lsGoodDirMat, 2)
                        lsGoodDirMat(:, iGoodDir) = ...
                            lsGoodDirMat(:, iGoodDir) / ...
                            norm(lsGoodDirMat(:, iGoodDir));
                    end
                    lsGoodDirCMat = ellTube.lsGoodDirVec();
                    for iTuple = 1 : nTuples
                        %
                        % good directions' indexes mapping
                        %
                        curGoodDirVec = lsGoodDirCMat{iTuple};
                        curGoodDirVec = curGoodDirVec / norm(curGoodDirVec);
                        for iGoodDir = 1:size(lsGoodDirMat, 2)
                            isFound = norm(curGoodDirVec - ...
                                lsGoodDirMat(:, iGoodDir)) <= CMP_TOL;
                            if isFound
                                break;
                            end
                        end
                        mlunitext.assert_equals(true, isFound,...
                            'Vector mapping - good dir vector not found');
                        goodDirOrderedVec(iTuple)=iGoodDir;
                    end
                end
                %
                function isEqual=compareGoodCurves(ellTube,goodDirSetList)
                    isEqual=true;
                    nTuples = ellTube.getNTuples;
                    goodDirSetObj=goodDirSetList{1}{1};
                    mapGoodDirInd(goodDirSetObj,ellTube);
                    for iTuple=1:nTuples
                        goodDirMat=ellTube.ltGoodDirMat{iTuple};
                        timeVec=ellTube.timeVec{iTuple};
                        switchIndVec=makeSwitchIndVec(timeVec);
                        goodDirSetObj=goodDirSetList{1}{1};
                        indTube=goodDirOrderedVec(iTuple);
                        isCurEqual=isEqualGoodCurve(1,timeVec,goodDirMat,switchIndVec,goodDirSetObj,indTube);
                        isEqual=isEqual&&isCurEqual;
                        if ((switchTimeVecLenght-1>=2)&&(nTuples~=numel(goodDirSetList{2}))...
                                ||(sysTimeVecLenght~=numel(goodDirSetList)))
                            isEqual=false;
                        end;
                        if (isEqual)&&(sysTimeVecLenght>1)
                            for iLinSys = 2 : sysTimeVecLenght
                                goodDirSetObj=goodDirSetList{iLinSys}{indTube};
                                isCurEqual=isEqualGoodCurve(iLinSys,timeVec,goodDirMat,...
                                    switchIndVec,goodDirSetObj,indTube);
                                isEqual=isEqual&&isCurEqual;
                            end;
                        end;
                    end;
                    %
                    function isCurEqual=isEqualGoodCurve(iLinSys,timeVec,goodDirMat,switchIndVec,...
                            goodDirSetObj,indTube)
                        [prevTime, curTime, curGoodDirMat]=...
                            setTimeIntervalForGoodDirCompare(iLinSys,timeVec,...
                            goodDirMat,switchIndVec);
                        iTVec=timeVec(prevTime:curTime);
                        if (iLinSys==1)
                            nObj=indTube;
                        else
                            nObj=1;
                        end;
                        curGoodDirOneCurveSplineList=goodDirSetObj.getRGoodDirOneCurveSplineList();
                        goodDirOneMat=curGoodDirOneCurveSplineList{nObj}.evaluate(iTVec);
                        isCurEqual=compareOneGoodCurveFromGoodDirMatAndGoodDirList(curGoodDirMat,...
                            goodDirOneMat);
                    end
                    %
                    function isCurEqual=compareOneGoodCurveFromGoodDirMatAndGoodDirList(goodDirMat,...
                            goodDirCurveArray)
                        isCurEqual=true;
                        sizeGoodDirMat=size(goodDirMat);
                        nDir=sizeGoodDirMat(2);
                        for iDir=1:nDir
                            goodNormDirMat=goodDirMat(:,iDir)./norm(goodDirMat(:,iDir));
                            goodNormDirCurveMat=goodDirCurveArray(:,iDir)./norm(goodDirCurveArray(:,iDir));
                            isCurrentEqual=modgen.common.absrelcompare(goodNormDirMat,...
                                goodNormDirCurveMat, CMP_TOL, [], @abs);
                            isCurEqual=isCurrentEqual&&isCurEqual;
                        end;  
                    end
                end
                %
                function [previousTime, currentTime, currentGoodDirMat]=...
                        setTimeIntervalForGoodDirCompare(iCurLinSys,iTimeVec,goodDirMat,switchIndVec)
                    if (isBackward)
                        iTimeVecSize=size(iTimeVec);
                        previousTime=iTimeVecSize(2)-switchIndVec(iCurLinSys+1)+1;
                        currentTime=iTimeVecSize(2)-switchIndVec(iCurLinSys)+1;
                        currentGoodDirMat=goodDirMat(:,currentTime:-1:previousTime);
                    else
                        currentTime=switchIndVec(iCurLinSys+1);
                        previousTime=switchIndVec(iCurLinSys);
                        currentGoodDirMat=goodDirMat(:,previousTime:currentTime);
                    end
                end
            end
            %mlunitext.assert_equals(true, isOk);
        end
   end
end