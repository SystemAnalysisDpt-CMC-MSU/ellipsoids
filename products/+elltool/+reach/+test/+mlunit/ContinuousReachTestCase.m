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
            ellTubeRel=self.reachObj.getEllTubeRel();
            switchSysTimeVec=self.reachObj.getSwitchTimeVec();
            switchTimeVecLenght=numel(switchSysTimeVec);
            intProbDynamicsList=self.reachObj.getIntProbDynamicsList();
            extProbDynamicsList=self.reachObj.getExtProbDynamicsList();
            intGoodDirSetList=self.reachObj.getIntGoodDirSetList();
            extGoodDirSetList=self.reachObj.getExtGoodDirSetList();            
            intEllTube=ellTubeRel.getTuplesFilteredBy('approxType',0); % now there are only internal tubes in the table
            nTube=intEllTube.getNTuples(); %! кол-во трубок
            extEllTube=ellTubeRel.getTuplesFilteredBy('approxType',1); % there are only external tubes in the table         
            %don't forget to compare the dimensionality of objList{2} (if it exists) and NTubes
            linSys=self.reachObj.getSystemList();
            sysTimeVecLenght=numel(linSys);             
            %2)comparing results of linSys and probDynObj.getBPBgetBPBTransDynamics().evaluate(t)
            
            % should I do that for all time in timeVec? Now only system in switch time are checked
            % incorrect result for matrices containing elements such as '2/3' because of round-off
            ProbDynamicsListLenght=numel(intProbDynamicsList);
            firsttime=switchSysTimeVec(2);
            BCellMat=linSys{1}.getBtMat();
            %BMat=cell2mat(cellfun(@(x)str2num(x),BMatCell,'UniformOutput',false));
            t=firsttime;
            BMat=cellfun(@eval,BCellMat);
            UBoundsEll=linSys{1}.getUBoundsEll();
            PCellMat=UBoundsEll.shape(); 
            %PMat=cell2mat(cellfun(@(x)str2num(x),PMatCell,'UniformOutput',false));
            PMat=cellfun(@eval,PCellMat);
            BPBMat=BMat*PMat*(BMat)';            
            intpDynBPBMat=intProbDynamicsList{1}.getBPBTransDynamics().evaluate(firsttime);
            extpDynBPBMat=extProbDynamicsList{1}.getBPBTransDynamics().evaluate(firsttime);
            flag1=0;
            if ((sum(sum(abs(BPBMat-intpDynBPBMat)))>10^(-16))||(sum(sum(abs(BPBMat-extpDynBPBMat)))>10^(-16))); 
                flag1=1;
            end;                
            if (sysTimeVecLenght==ProbDynamicsListLenght)&&(sysTimeVecLenght>1)
                flag=0;
                for iLinSys = 2 : sysTimeVecLenght
                    itime=switchSysTimeVec(iLinSys+1);
                    BCellMat=linSys{iLinSys}.getBtMat();
                    %BMat=cell2mat(cellfun(@(x)str2num(x),BMatCell,'UniformOutput',false));
                    t=itime;
                    BMat=cellfun(@eval,BCellMat);
                    UBoundsEll=linSys{iLinSys}.getUBoundsEll();
                    PCellMat=UBoundsEll.shape(); 
                    %PMat=cell2mat(cellfun(@(x)str2num(x),PMatCell,'UniformOutput',false));
                    PMat=cellfun(@eval,PCellMat);
                    BPBMat=BMat*PMat*(BMat)';
                    intpDynBPBMat=intProbDynamicsList{iLinSys}{1}.getBPBTransDynamics().evaluate(itime);
                    extpDynBPBMat=intProbDynamicsList{iLinSys}{1}.getBPBTransDynamics().evaluate(itime);
                    if ((sum(sum(abs(BPBMat-intpDynBPBMat)))>10^(-16))||(sum(sum(abs(BPBMat-extpDynBPBMat)))>10^(-16))); 
                        flag=1;
                    end;
%                     intGoodDirSetObj=intGoodDirSetList{iLinSys}{1};
%                     GoodDirOneCurveSplineList=intGoodDirSetObj.getGoodDirOneCurveSplineList();
                end;               
            end;
            %1) comparing results of getEllTubeRel and probDynObj.getX0Mat();
            for iTube=1:nTube
                timeVec=intEllTube.timeVec{iTube};
                switchIndex=[];
                for iSwitch=1:switchTimeVecLenght
                    sIndex=find(timeVec==switchSysTimeVec(iSwitch));
                    switchIndex=[switchIndex sIndex];
                end;
                flagX0Mat=1;
                isBackward=self.reachObj.isbackward();
                probDynObj=intProbDynamicsList{1};
                QDynArray=probDynObj.getX0Mat();                
                if (isBackward)
                    QArraysize=size(intEllTube.QArray{iTube});
                    curTime=QArraysize(3)-switchIndex(1)+1;
                else 
                    curTime=switchIndex(1);
                end;
                QArray=intEllTube.QArray{iTube}(:,:,curTime); 
                isOk=((sum(sum(abs(QDynArray-QArray))))<10^(-16))&&isOk;
                if (switchTimeVecLenght-1>=2)
                    for iSwitch=2:switchTimeVecLenght-1
                        probDynObj=intProbDynamicsList{iSwitch}{iTube};
                        QDynArray=probDynObj.getX0Mat();
                        if (isBackward)                            
                            curTime=QArraysize(3)-switchIndex(iSwitch)+1;
                        else 
                            curTime=switchIndex(iSwitch);
                        end;
                        QArray=intEllTube.QArray{iTube}(:,:,curTime);
                        isOk=(sum(sum(abs(QDynArray-QArray)))<10^(-16))&&isOk;
                    end;
                end;
            end;
            %comparison for extProbDynamicsList
            for iTube=1:nTube
                timeVec=extEllTube.timeVec{iTube};
                switchIndex=[];
                for iSwitch=1:switchTimeVecLenght
                    sIndex=find(timeVec==switchSysTimeVec(iSwitch));
                    switchIndex=[switchIndex sIndex];
                end;
                flagX0Mat=1;
                isBackward=self.reachObj.isbackward();
                probDynObj=extProbDynamicsList{1};
                QDynArray=probDynObj.getX0Mat();
                if (isBackward)
                    QArraysize=size(extEllTube.QArray{iTube});
                    curTime=QArraysize(3)-switchIndex(1)+1;
                else 
                    curTime=switchIndex(1);
                end;
                QArray=extEllTube.QArray{iTube}(:,:,curTime); 
                isOk=(sum(sum(abs(QDynArray-QArray)))<10^(-16))&&isOk;
                if (switchTimeVecLenght-1>=2)
                    for iSwitch=2:switchTimeVecLenght-1
                        probDynObj=extProbDynamicsList{iSwitch}{iTube};
                        QDynArray=probDynObj.getX0Mat();
                        if (isBackward)                            
                            curTime=QArraysize(3)-switchIndex(iSwitch)+1;
                        else 
                            curTime=switchIndex(iSwitch);
                        end;
                        QArray=extEllTube.QArray{iTube}(:,:,curTime);
                        isOk=(sum(sum(abs(QDynArray-QArray)))<10^(-16))&&isOk;
                    end;
                end;
            end;
           
            %3) comparing good directions obtained from GoodDirSetList and
            %EllTubeRel
            %doesn't work!!! just the considerations how to implement
            %obtained results are not equal
            for iTube=1:nTube
                GoodDirMat=intEllTube.ltGoodDirMat{iTube};
                intGoodDirSetObj=intGoodDirSetList{1};
                NGoodDirs=intGoodDirSetObj.getNGoodDirs();
                GoodDirOneCurveSplineList=intGoodDirSetObj.getGoodDirOneCurveSplineList();
                GoodDirOne=GoodDirOneCurveSplineList{iTube}.evaluate(switchSysTimeVec(2));
                %look for a corresponding switch index in timeVec, cut the
                %curve till that moment (is not done)
                %EllData=ellTubeRel.getData();
                %take into account if there is backward time, invert (is not done)
                if (sysTimeVecLenght==ProbDynamicsListLenght)&&(sysTimeVecLenght>1)
                    flag=0;
                    % check if it's a switch time and change the system
                    for iLinSys = 2 : sysTimeVecLenght                     
                        %detach the part of intEllTube corresponding to the
                        %current time interval (is not done)
                        itime=switchSysTimeVec(iLinSys+1);
                        intGoodDirSetObj=intGoodDirSetList{iLinSys}{iTube};
                        NGoodDirs=intGoodDirSetObj.getNGoodDirs();
                        GoodDirOneCurveSplineList=intGoodDirSetObj.getGoodDirOneCurveSplineList();
                        GoodDirOne=GoodDirOneCurveSplineList{1}.evaluate(itime);
                
                    end;
                                         
                %nDir=size(EllData.ltGoodDirMat{1});
                end;
            end;
                       
            isOk
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
