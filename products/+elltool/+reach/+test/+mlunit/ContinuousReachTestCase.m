classdef ContinuousReachTestCase < mlunitext.test_case
    properties (Access=private, Constant)
        FIELDS_NOT_TO_COMPARE={'LT_GOOD_DIR_MAT';'LT_GOOD_DIR_NORM_VEC';...
            'LS_GOOD_DIR_NORM';'LS_GOOD_DIR_VEC';'IND_S_TIME';'S_TIME'};
        COMP_PRECISION = 5e-3;
        REL_TOL = 1e-5;
        SPLIT_FACTOR=0.25;
        DISABLE_CUT_AND_EVOLVE_ISSUE_126=true;
    end
    properties (Access=private)
        testDataRootDir
        linSys
        reachObj
        tVec
        x0Ell
        l0Mat
        expDim
        reachFactoryObj
    end
    methods (Access=private, Static)
        function verticesCVec =...
                getVerticesFromHMap(axesHMap, specStr)
            axesHMapKeysCVec = axesHMap.keys;
            if strcmp(specStr, 'Ellipsoidal/reach tubes')
                findStr = 'Reach Tube';
            else
                findStr = 'Good directions curve';
            end
            isIndAxesVec =...
                ~cellfun(@isempty, strfind(axesHMapKeysCVec, specStr));
            objectHandlesVec = axesHMap(axesHMapKeysCVec{isIndAxesVec});
            %
            objectNamesCVec = get(objectHandlesVec, 'DisplayName');
            isIndObjectVec = ~cellfun(@isempty,...
                strfind(objectNamesCVec, findStr));
            object = objectHandlesVec(isIndObjectVec);
            %
            verticesCVec = get(object, 'Vertices');
        end
    end
    methods (Access=private)
        function plotApproxTest(self, reachObj, approxType)
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            if approxType == EApproxType.External
                ellArray = reachObj.get_ea();
                dim = ellArray(1, 1).dimension;
                if ~reachObj.isprojection()
                    projReachObj = reachObj.projection(eye(dim, 2));
                else
                    projReachObj = reachObj.getCopy();
                end
                plotter = projReachObj.plotEa();
                scaleFactor = reachObj.getEaScaleFactor();
            elseif approxType == EApproxType.Internal
                ellArray = reachObj.get_ia();
                dim = ellArray(1, 1).dimension;
                if ~reachObj.isprojection()
                    projReachObj = reachObj.projection(eye(dim, 2));
                else
                    projReachObj = reachObj.getCopy();
                end
                plotter = projReachObj.plotIa();
                scaleFactor = reachObj.getIaScaleFactor();
            end
            [dirCVec timeVec] = reachObj.get_directions();
            goodDirCVec =...
                cellfun(@(x) x(:, 1), dirCVec.', 'UniformOutput', false);
            
            if dim > 2
                ellArray = ellArray.projection(eye(dim, 2));
                goodDirCVec = cellfun(@(x) x(1:2), goodDirCVec,...
                    'UniformOutput', false);
            end
            nGoodDirs = numel(goodDirCVec);
            %
            axesHMapList =...
                plotter.getPlotStructure.figToAxesToPlotHMap.values;
            nFigures = numel(axesHMapList);
            for iAxesHMap = 1 : nFigures
                axesHMap = axesHMapList{iAxesHMap};
                %
                rtVerticesVec = self.getVerticesFromHMap(axesHMap,...
                    'Ellipsoidal/reach tubes');
                gdVerticesCVec = self.getVerticesFromHMap(axesHMap,...
                    'Good directions');
                %
                plottedGoodDirCVec = cellfun(@(x) x(1, 2 : 3).',...
                    gdVerticesCVec, 'UniformOutput', false);
                %
                normalizeCVecFunc =...
                    @(v)cellfun(@(x) x / realsqrt(sum(x.*x)),...
                    v, 'UniformOutput', false);
                goodDirCVec = normalizeCVecFunc(goodDirCVec);
                plottedGoodDirCVec = normalizeCVecFunc(plottedGoodDirCVec);
                plottedGoodDirIndex = 0;
                for iGoodDir = 1 : nGoodDirs
                    goodDir = goodDirCVec{iGoodDir};
                    for iPlottedGoodDir = 1 : numel(plottedGoodDirCVec)
                        plottedGoodDir =...
                            plottedGoodDirCVec{iPlottedGoodDir};
                        if max(abs(goodDir - plottedGoodDir)) < self.REL_TOL
                            plottedGoodDirIndex = iGoodDir;
                            break;
                        end
                    end
                end
                if plottedGoodDirIndex == 0
                    throwerror('wrongData', 'No good direction found.');
                end
                %
                reachTubeEllipsoids = ellArray(plottedGoodDirIndex, :);
                nTimePoints = numel(timeVec);
                %
                for iTimePoint = 1 : nTimePoints
                    ell = reachTubeEllipsoids(iTimePoint);
                    curT = timeVec(iTimePoint);
                    pointsMat =...
                        rtVerticesVec(rtVerticesVec(:, 1) == curT, 2 : 3);
                    pointsMat = pointsMat.';
                    [centerVec shapeMat] = parameters(ell);
                    centerPointsMat = pointsMat -...
                        repmat(centerVec, 1, size(pointsMat, 2));
                    sqrtScalProdVec = realsqrt(abs(dot(centerPointsMat,...
                        shapeMat\centerPointsMat) - 1));
                    mlunitext.assert_equals(...
                        max(sqrtScalProdVec) < self.COMP_PRECISION, true);
                end
            end
            plotter.closeAllFigures();
        end
        %
        function displayTest(self, reachObj, timeVec)
            rxDouble = '([\d.+\-e]+)';
            %
            resStr = evalc('reachObj.display()');
            % time interval
            tokens = regexp(resStr,...
                ['time interval \[' rxDouble ',\s' rxDouble '\]'],...
                'tokens');
            tLimsRead = str2double(tokens{1}.').';
            difference = abs(tLimsRead(:) - timeVec(:));
            mlunitext.assert_equals(...
                max(difference) < self.COMP_PRECISION, true);
            % time typez
            if isa(reachObj, 'elltool.reach.ReachContinuous')
                isOk = ~isempty(strfind(resStr, 'continuous-time'));
            else
                isOk = ~isempty(strfind(resStr, 'discrete-time'));
            end
            mlunitext.assert_equals(isOk, true);
            % dimension
            tokens = regexp(resStr,...
                ['linear system in R\^' rxDouble],...
                'tokens');
            dimRead = str2double(tokens{1}{1});
            mlunitext.assert_equals(dimRead, reachObj.dimension);
        end
        %
        function runPlotTest(self, approxType)
            self.plotApproxTest(self.reachObj, approxType);
            newTimeVec = [sum(self.tVec)*self.SPLIT_FACTOR, self.tVec(2)];
            cutReachObj = self.reachObj.cut(newTimeVec);
            self.plotApproxTest(cutReachObj, approxType);
            projReachObj =...
                self.reachObj.projection(eye(self.reachObj.dimension(), 2));
            self.plotApproxTest(projReachObj, approxType);
        end
    end
    methods
        function self = ContinuousReachTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName];
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
        %
        function self = testDisplay(self)
            self.displayTest(self.reachObj, self.tVec);
            newTimeVec = [sum(self.tVec)*self.SPLIT_FACTOR, self.tVec(2)];
            cutReachObj = self.reachObj.cut(newTimeVec);
            self.displayTest(cutReachObj, newTimeVec);
            projReachObj =...
                self.reachObj.projection(eye(self.reachObj.dimension(), 2));
            self.displayTest(projReachObj, self.tVec);
        end
        %
        function self = testPlotEa(self)
            import gras.ellapx.enums.EApproxType;
            self.runPlotTest(EApproxType.External);
            self.reachObj.plotEa();
        end
        %
        function self = testPlotIa(self)
            import gras.ellapx.enums.EApproxType;
            self.runPlotTest(EApproxType.Internal);
            self.reachObj.plotIa();
        end
        %
        function self = testDimension(self)
            newTimeVec = [sum(self.tVec)*self.SPLIT_FACTOR, self.tVec(2)];
            cutReachObj = self.reachObj.cut(newTimeVec);
            cutDim = cutReachObj.dimension();
            projReachObj =...
                self.reachObj.projection(eye(self.reachObj.dimension(), 1));
            [rsDim ssDim] = projReachObj.dimension();
            isOk = (rsDim == self.expDim) && (ssDim == 1) &&...
                (cutDim == self.expDim);
            mlunitext.assert_equals(true, isOk);
        end
        %
        function self = testDynGetters(self)
            isOk=1;
            isEqual=1;
            CMP_TOL=10^(-16);
            ellTubeRel=self.reachObj.getEllTubeRel();
            switchSysTimeVec=self.reachObj.getSwitchTimeVec();
            switchTimeVecLenght=numel(switchSysTimeVec);
            intProbDynamicsList=self.reachObj.getIntProbDynamicsList();
            extProbDynamicsList=self.reachObj.getExtProbDynamicsList();
            intGoodDirSetList=self.reachObj.getIntGoodDirSetList();
            extGoodDirSetList=self.reachObj.getExtGoodDirSetList();            
            intEllTube=ellTubeRel.getTuplesFilteredBy('approxType',0); % now there are only internal tubes in the table
            nTube=intEllTube.getNTuples();
            extEllTube=ellTubeRel.getTuplesFilteredBy('approxType',1); % there are only external tubes in the table         
            %don't forget to compare the dimensionality of objList{2} (if it exists) and NTubes
            linSys=self.reachObj.getSystemList();
            sysTimeVecLenght=numel(linSys); 
            regTol=self.reachFactoryObj.getRelTol();
            isRegEnabled=self.reachFactoryObj.getIsRegEnabled();
            isJustCheck=self.reachFactoryObj.getIsJustCheck();
            isReg=isRegEnabled&&(~isJustCheck);
            %2)comparing results of linSys and probDynObj.getBPBgetBPBTransDynamics().evaluate(t)
            
            % should I do that for all time in timeVec? Now only systems in switch time are checked
            % incorrect result for matrices containing elements such as '2/3'
            ProbDynamicsListLenght=numel(intProbDynamicsList);
            firsttime=switchSysTimeVec(2);
            
            intpDynBPBMat=intProbDynamicsList{1}.getBPBTransDynamics().evaluate(firsttime);         
            extpDynBPBMat=extProbDynamicsList{1}.getBPBTransDynamics().evaluate(firsttime);    
            t=firsttime;
            [isEqual,BPBMat]=compareBPBandpDynBPB(1,intpDynBPBMat,t);
            [extIsEqual,BPBMat]=compareBPBandpDynBPB(1,extpDynBPBMat,t);
            isEqual=isEqual*extIsEqual;
            if (sysTimeVecLenght==ProbDynamicsListLenght)&&(sysTimeVecLenght>1)
                for iLinSys = 2 : sysTimeVecLenght
                    itime=switchSysTimeVec(iLinSys+1);                    
                    intpDynBPBMat=intProbDynamicsList{iLinSys}{1}.getBPBTransDynamics().evaluate(itime);
                    extpDynBPBMat=extProbDynamicsList{iLinSys}{1}.getBPBTransDynamics().evaluate(itime);
                    [isEqual,BPBMat]=compareBPBandpDynBPB(iLinSys,intpDynBPBMat,itime);
                    [extIsEqual,BPBMat]=compareBPBandpDynBPB(iLinSys,extpDynBPBMat,itime);
                    isEqual=isEqual*extIsEqual;
                end;               
            end;
            %1) comparison of the results obtained from getEllTubeRel and probDynObj.getX0Mat();
            
            isEqual=compareX0Mat(intEllTube,intProbDynamicsList,nTube);
            isOk=isOk&&isEqual;
            isEqual=compareX0Mat(extEllTube,extProbDynamicsList,nTube);
            isOk=isOk&&isEqual;             
           
            %3) comparison of good directions obtained from GoodDirSetList and EllTubeRel 
            
            %obtained results are not equal!!! Why?
            
%           timeCVec = intEllTube.timeVec;
            nTuples = intEllTube.getNTuples;
            goodDirSetObj=intGoodDirSetList{1};
            calcPrecision=regTol;
            
            lsGoodDirMat = goodDirSetObj.getlsGoodDirMat();
            for iGoodDir = 1:size(lsGoodDirMat, 2)
                lsGoodDirMat(:, iGoodDir) = ...
                    lsGoodDirMat(:, iGoodDir) / ...
                        norm(lsGoodDirMat(:, iGoodDir));
            end
            lsGoodDirCMat = intEllTube.lsGoodDirVec();
 %           curGoodDirObj = goodDirSetObj;
 
            %find the corresponding indexes for good directions obtained from EllTube
            %in goodDirSetObj
            GoodDirOrdered=[];
            for iTuple = 1 : nTuples
%               curTimeVec = timeCVec{iTuple};
                    %
                    % good directions' indexes mapping
                    %
                curGoodDirVec = lsGoodDirCMat{iTuple};
                curGoodDirVec = curGoodDirVec / norm(curGoodDirVec);
                for iGoodDir = 1:size(lsGoodDirMat, 2)
                    isFound = norm(curGoodDirVec - ...
                    lsGoodDirMat(:, iGoodDir)) <= calcPrecision;
                    if isFound
                    	break;
                    end
                end
                mlunitext.assert_equals(true, isFound,...
                    'Vector mapping - good dir vector not found');
                GoodDirOrdered=[GoodDirOrdered iGoodDir];

            end

            for iTuple=1:nTube
                GoodDirMat=intEllTube.ltGoodDirMat{iTuple};
                timeVec=intEllTube.timeVec{iTuple};
                switchIndex=[];
                for iSwitch=1:switchTimeVecLenght
                    sIndex=find(timeVec==switchSysTimeVec(iSwitch));
                    switchIndex=[switchIndex sIndex];
                end;

                [previousTime,currentTime,CurrentGoodDirMat]=setTimeIntervalForGoodDirCompare(1,timeVec);
                iTimeVec=timeVec(previousTime:currentTime);
                intGoodDirSetObj=intGoodDirSetList{1};
                NGoodDirs=intGoodDirSetObj.getNGoodDirs();
                GoodDirOneCurveSplineList=intGoodDirSetObj.getRGoodDirOneCurveSplineList();
                properITube=GoodDirOrdered(iTuple);                
                GoodDirOne=GoodDirOneCurveSplineList{properITube}.evaluate(iTimeVec);
                %CurrentGoodDirMat is not equal to GoodDirOne
                if (sysTimeVecLenght==ProbDynamicsListLenght)&&(sysTimeVecLenght>1)
                    for iLinSys = 2 : sysTimeVecLenght                                            
                        [previousTime, currentTime, CurrentGoodDirMat]=...
                            setTimeIntervalForGoodDirCompare(iLinSys,timeVec);
                        iTimeVec=timeVec(previousTime:currentTime);
                        itime=switchSysTimeVec(iLinSys+1);
                        intGoodDirSetObj=intGoodDirSetList{iLinSys}{properITube};
                        NGoodDirs=intGoodDirSetObj.getNGoodDirs();
                        GoodDirOneCurveSplineList=intGoodDirSetObj.getRGoodDirOneCurveSplineList();
                        GoodDirOne=GoodDirOneCurveSplineList{1}.evaluate(iTimeVec);
                        %CurrentGoodDirMat is not equal to GoodDirOne
                    end;
                end;                
            end;
                       
            isOk
            function [isEqual,BPBMat]=compareBPBandpDynBPB(iLinSys,pDynBPBMat,tEval)
                BCellMat=linSys{iLinSys}.getBtMat();
                %BMat=cell2mat(cellfun(@(x)str2num(x),BMatCell,'UniformOutput',false));
                t=tEval;
                BMat=cellfun(@eval,BCellMat);
                UBoundsEll=linSys{iLinSys}.getUBoundsEll();
                PCellMat=UBoundsEll.shape(); 
                %PMat=cell2mat(cellfun(@(x)str2num(x),PMatCell,'UniformOutput',false));               
                PMat=cellfun(@eval,PCellMat);
                BPBMat=BMat*PMat*(BMat)'; 
                if (isReg)
                    fPosReg=@(x)gras.mat.MatrixPosReg(x,regTol);
                    BPBMatReg=gras.mat.AConstMatrixFunction(BPBMat);
                    BPBPosReg=fPosReg(BPBMatReg);
                    BPBMatAfterReg=BPBPosReg.evaluate(1);
                end;
                                          
                [isEqual, absDiff]=modgen.common.absrelcompare(BPBMat,pDynBPBMat, CMP_TOL, [], @abs);
            end
            function curTime=findCurrentTime(iTubeTimeVec,iSwitch)
                isBackward=self.reachObj.isbackward();                              
                if (isBackward)
                    iTubeTimeVecSize=size(iTubeTimeVec);
                    curTime=iTubeTimeVecSize(2)-switchIndex(iSwitch)+1;
                else 
                    curTime=switchIndex(iSwitch);
                end; 
            end
            function isEqual=compareX0Mat(EllTube,ProbDynamicsList,nTube)  
                isEqual=1;
                for iTube=1:nTube
                    timeVec=EllTube.timeVec{iTube};
                    switchIndex=[];
                    for iSwitch=1:switchTimeVecLenght
                        sIndex=find(timeVec==switchSysTimeVec(iSwitch));
                        switchIndex=[switchIndex sIndex];
                    end;                
                    probDynObj=ProbDynamicsList{1};
                    QDynArray=probDynObj.getX0Mat();                
                    currentTime=findCurrentTime(timeVec,1);
                    QArray=EllTube.QArray{iTube}(:,:,currentTime);                 
                    [isCurrentEqual, absDiff]=modgen.common.absrelcompare(QDynArray,QArray, CMP_TOL, [], @abs);
                    isEqual=isEqual&&isCurrentEqual;
                    if (switchTimeVecLenght-1>=2)
                        for iSwitch=2:switchTimeVecLenght-1
                            probDynObj=ProbDynamicsList{iSwitch}{iTube};
                            QDynArray=probDynObj.getX0Mat();
                            currentTime=findCurrentTime(timeVec,iSwitch);
                            QArray=EllTube.QArray{iTube}(:,:,currentTime);                        
                            [isCurrentEqual, absDiff]=modgen.common.absrelcompare(QDynArray,...
                                QArray, CMP_TOL, [], @abs);
                            isEqual=isEqual&&isCurrentEqual;
                        end;
                    end;
                end;                                
            end
            function [previousTime, currentTime, CurrentGoodDirMat]=...
                    setTimeIntervalForGoodDirCompare(iCurLinSys,iTimeVec)
                isBackward=self.reachObj.isbackward();
                if (isBackward)
                    iTimeVecSize=size(iTimeVec);
                    previousTime=iTimeVecSize(2)-switchIndex(iCurLinSys+1)+1;
                    currentTime=iTimeVecSize(2)-switchIndex(iCurLinSys)+1;
                    CurrentGoodDirMat=GoodDirMat(:,currentTime:-1:previousTime);
                else 
                    currentTime=switchIndex(iCurLinSys+1);
                    previousTime=switchIndex(iCurLinSys);
                    CurrentGoodDirMat=GoodDirMat(:,previousTime:currentTime);
                end                
            end
            
            %mlunitext.assert_equals(true, isOk);
        end
        %
        function self = testIsEmpty(self)
            emptyRs = feval(class(self.reachObj));
            newTimeVec = [sum(self.tVec)*self.SPLIT_FACTOR self.tVec(2)];
            cutReachObj = self.reachObj.cut(newTimeVec);
            projReachObj =...
                self.reachObj.projection(eye(self.reachObj.dimension(), 1));
            mlunitext.assert_equals(true, emptyRs.isEmpty());
            mlunitext.assert_equals(false, self.reachObj.isEmpty());
            mlunitext.assert_equals(false, cutReachObj.isEmpty());
            mlunitext.assert_equals(false, projReachObj.isEmpty());
        end
        %
        function self = DISABLE_testEvolve(self)
            import gras.ellapx.smartdb.F;
            %
            timeVec = [self.tVec(1), sum(self.tVec)*self.SPLIT_FACTOR];
            newReachObj = feval(class(self.reachObj), ...
                self.linSys, self.x0Ell, self.l0Mat, timeVec);
            auxCheckIndSTime(self.reachObj);
            %
            evolveReachObj = newReachObj.evolve(self.tVec(2));
            auxCheckIndSTime(self.reachObj);
            %
            [isEqual,reportStr] = self.reachObj.isEqual(evolveReachObj);
            mlunitext.assert(isEqual,reportStr);
        end
        %
        function self = testGetSystem(self)
            isEqual = self.linSys.isEqual(self.reachObj.get_system());
            mlunitext.assert_equals(true, isEqual);
            projReachObj = self.reachObj.projection(...
                eye(self.reachObj.dimension(), 2));
            isEqual = self.linSys.isEqual(projReachObj.get_system());
            mlunitext.assert_equals(true, isEqual);
        end
        %
        function self = DISABLE_testCut(self)
            origReachObj=self.reachObj;
            auxCheckIndSTime(origReachObj);
            timeLimVec=self.tVec;
            tStart=min(timeLimVec);
            tEnd=max(timeLimVec);
            tMid=sum(timeLimVec)*self.SPLIT_FACTOR;
            %
            isBackward=timeLimVec(2)<timeLimVec(1);
            %
            checkCut([tStart,tEnd]);
            %
            checkScalarCut(tEnd);
            checkScalarCut(tStart);
            %
            checkCut([tMid,tEnd]);
            checkCut([tStart,tMid]);
            %
            function checkScalarCut(tScalar)
                cutReachObj = self.reachObj.cut(tScalar);
                cutReachObj.dimension();
            end
            %
            function checkCut(newTimeVec)
                import gras.ellapx.enums.EApproxType;
                import gras.ellapx.smartdb.F;
                %
                cutReachObj = origReachObj.cut(newTimeVec);
                check('get_ea',[false, true]);
                check('get_ia',[true, false]);
                %
                function check(fGetApx,isIntExtApxVec)
                    auxCheckIndSTime(cutReachObj);
                    [apxEllMat,timeVec] = feval(fGetApx,cutReachObj);
                    nTuples = size(apxEllMat, 1);
                    mlunitext.assert(timeVec(1)==newTimeVec(1));
                    mlunitext.assert(timeVec(end)==newTimeVec(end));
                    %
                    for iTuple = 1 : nTuples
                        directionsCVec = cutReachObj.get_directions();
                        if self.reachObj.isbackward()
                            x0ApxEll = apxEllMat(iTuple, end);
                            l0Vec = directionsCVec{iTuple}(:, end);
                        else
                            x0ApxEll = apxEllMat(iTuple, 1);
                            l0Vec = directionsCVec{iTuple}(:, 1);
                        end
                        l0Vec = l0Vec ./ norm(l0Vec);
                        %
                        newApxTimeVec=newTimeVec;
                        if isBackward
                            newApxTimeVec=fliplr(newTimeVec);
                        end
                        %
                        newApxReachObj = feval(class(self.reachObj), ...
                            self.linSys, x0ApxEll, l0Vec, newApxTimeVec);
                        [isApxEqual, repStr] = cutReachObj.getCopy(...
                            'isIntExtApxVec',isIntExtApxVec,...
                            'l0Mat',l0Vec).isEqual(...
                            newApxReachObj.getCopy(...
                            'isIntExtApxVec',isIntExtApxVec));
                        %
                        mlunitext.assert_equals(true, isApxEqual,repStr);
                    end
                end
            end
        end
        %
        function self = testProjectionCut(self)
            projReachObj =...
                self.reachObj.projection(eye(self.reachObj.dimension(), 2));
            newTimeVec = [sum(self.tVec)/2, self.tVec(2)];
            projReachObj.cut(newTimeVec);
        end
        %
        function self = testNegativePlot(self)
            dim = self.reachObj.dimension();
            if dim == 2
                projReachSet =...
                    self.reachObj.projection(eye(dim, 1));
            else
                projReachSet =...
                    self.reachObj.projection(eye(dim, 3));
            end
            self.runAndCheckError('projReachSet.plotEa()', 'wrongInput');
            self.runAndCheckError('projReachSet.plotIa()', 'wrongInput');
        end
        %
        function self = testGetCopy(self)
            copiedReachObj = self.reachObj.getCopy();
            isEqual = copiedReachObj.isEqual(self.reachObj);
            mlunitext.assert_equals(true, isEqual);
        end
        %
        %
        function self = testGetCopyAdvanced(self)
            initL0Mat=self.l0Mat;
            nDims=size(initL0Mat,1);
            nOrigDirs=size(initL0Mat,2);
            expL0Mat=[initL0Mat, initL0Mat-1, initL0Mat+1];
            expL0Mat=expL0Mat./...
                repmat(realsqrt(dot(expL0Mat,expL0Mat,1)),nDims,1);
            %
            reachObj=self.reachFactoryObj.createInstance('l0Mat',...
                expL0Mat,'isRegEnabled',true);
            checkApxFilter(reachObj,[true,false]);
            checkApxFilter(reachObj,[false,true]);
            %
            nOrigTuples=reachObj.getEllTubeRel().getNTuples();
            copyReachObj=reachObj.getCopy('isIntExtApxVec',[true,false]);
            nCopiedTuples=copyReachObj.getEllTubeRel().getNTuples();
            mlunitext.assert(nCopiedTuples==0.5*nOrigTuples);
            %
            [~,~,l0Mat]=reachObj.get_directions();
            %
            mlunitext.assert_equals(true, getIsEqual(expL0Mat,l0Mat));
            indSubDirVec=[1,nOrigDirs+1,2*nOrigDirs+1];
            l0SubMat=expL0Mat(:,indSubDirVec);
            %
            copiedReachObj = reachObj.getCopy('l0Mat',l0SubMat);
            expReachObj=self.reachFactoryObj.createInstance('l0Mat',l0SubMat);
            %
            [isEqual,reportStr] = copiedReachObj.isEqual(expReachObj);
            mlunitext.assert_equals(true, isEqual,reportStr);
            %
            copyIntReachObj=...
                expReachObj.getCopy('l0Mat',l0SubMat,...
                'isIntExtApxVec',[true,false]);
            copyExtReachObj=...
                expReachObj.getCopy('l0Mat',l0SubMat,...
                'isIntExtApxVec',[false,true]);
            %
            allTubeRel=copyIntReachObj.getEllTubeRel();
            allTubeRel.unionWith(copyExtReachObj.getEllTubeRel());
            [isEqual,reportStr]=allTubeRel.isEqual(...
                expReachObj.getEllTubeRel());
            mlunitext.assert(isEqual,reportStr);
            %
            function checkApxFilter(reachObj,isIntExptApxVec)
                nOrigTuples=reachObj.getEllTubeRel().getNTuples();
                copyReachObj=reachObj.getCopy('isIntExtApxVec',...
                    isIntExptApxVec);
                nCopiedTuples=copyReachObj.getEllTubeRel().getNTuples();
                mlunitext.assert(nCopiedTuples==0.5*nOrigTuples);
            end
            %
            function isPos=getIsEqual(leftDirMat,rightDirMat)
                CMP_TOL=1e-15;
                diffMat=sortrows(leftDirMat.')-sortrows(rightDirMat.');
                isPos=max(abs(diffMat(:)))<=CMP_TOL;
            end
        end
        %
        function self = testSortedTimeVec(self)
            ellTube = self.reachObj.getEllTubeRel();
            switchTimeVec = self.reachObj.getSwitchTimeVec();
            timeVec = ellTube.timeVec{1};
            if numel(switchTimeVec) == 1
                isOk = numel(timeVec) == 1;
                mlunitext.assert_equals(true, isOk);
            else
                isnOk = any(diff(switchTimeVec) <= 0);
                mlunitext.assert_equals(false, isnOk);
                isOk = switchTimeVec(1) <= timeVec(1) ||...
                    switchTimeVec(end) >= timeVec(end);
                mlunitext.assert_equals(true, isOk);
            end
        end
    end
end
function auxCheckIndSTime(reachObj)
if reachObj.isbackward()
    isOk=all(reachObj.getEllTubeRel().indSTime==...
        cellfun(@numel,reachObj.getEllTubeRel().timeVec));
    mlunitext.assert(isOk);
else
    isOk=all(reachObj.getEllTubeRel().indSTime==1);
    mlunitext.assert(isOk);
end
end
