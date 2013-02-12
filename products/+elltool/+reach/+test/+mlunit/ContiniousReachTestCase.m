classdef ContiniousReachTestCase < mlunitext.test_case
    properties (Access = private, Constant)
        FIELDS_NOT_TO_COMPARE={'LT_GOOD_DIR_MAT';'LT_GOOD_DIR_NORM_VEC';...
            'LS_GOOD_DIR_NORM';'LS_GOOD_DIR_VEC';'IND_S_TIME';'S_TIME'};
        COMP_PRECISION = 5e-3;
    end
    properties (Access=private)
        testDataRootDir
        etalonDataRootDir
        etalonDataBranchKey
        linSys
        reachObj
        tVec
        x0Ell
        l0Mat
        expDim
    end
    methods (Access = private)
        function plotApproxTest(self, reachObj, approxType)
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            if approxType == EApproxType.External
                ellArray = reachObj.get_ea;
                plotter = reachObj.plot_ea;
                scaleFactor = reachObj.getEaScaleFactor;
            elseif approxType == EApproxType.Internal
                ellArray = reachObj.get_ia;
                plotter = reachObj.plot_ia;
                scaleFactor = reachObj.getIaScaleFactor;
            end
            ellTubes = reachObj.getEllTubeRel.getTuplesFilteredBy(...
                APPROX_TYPE, approxType);
            goodDirCVec = ellTubes.lsGoodDirVec;
            nGoodDirs = numel(goodDirCVec);
            plotter.closeAllFigures();
            %
            axesHMapList =...
                plotter.getPlotStructure.figToAxesToPlotHMap.values;
            nFigures = numel(axesHMapList);
            for iAxesHMap = 1 : nFigures
                axesHMap = axesHMapList{iAxesHMap};
                axesHMapKeys = axesHMap.keys;
                %
                indReachTubeAxes = ~cellfun(@isempty,...
                    strfind(axesHMapKeys, 'Ellipsoidal tubes'));
                indGoodDirsAxes = ~cellfun(@isempty,...
                    strfind(axesHMapKeys, 'Good directions'));
                %
                rtObjectHandles = axesHMap(axesHMapKeys{indReachTubeAxes});
                gdObjectHandles = axesHMap(axesHMapKeys{indGoodDirsAxes});
                %
                rtObjectNames = get(rtObjectHandles, 'DisplayName');
                gdObjectNames = get(gdObjectHandles, 'DisplayName');
                indRtObject = ~cellfun(@isempty,...
                    strfind(rtObjectNames, 'Reach Tube'));
                indGdObjects = ~cellfun(@isempty,...
                    strfind(gdObjectNames, 'Good directions curve'));
                rtObject = rtObjectHandles(indRtObject);
                gdObjects = gdObjectHandles(indGdObjects);
                %
                rtVertices = get(rtObject, 'Vertices');
                gdVerticesCVec = get(gdObjects, 'Vertices');
                %
                plottedGoodDirCVec = cellfun(@(x) x(1, 2 : 3).',...
                    gdVerticesCVec, 'UniformOutput', false);
                %
                plottedGoodDirIndex = 0;
                for iGoodDir = 1 : nGoodDirs
                    goodDir = goodDirCVec{iGoodDir};
                    for iPlottedGoodDir = 1 : numel(plottedGoodDirCVec)
                        plottedGoodDir =...
                            plottedGoodDirCVec{iPlottedGoodDir};
                        if all(goodDir == plottedGoodDir)
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
                timeVec = ellTubes.timeVec{plottedGoodDirIndex, :};
                nTimePoints = numel(timeVec);
                %
                for iTimePoint = 1 : nTimePoints
                    ell = reachTubeEllipsoids(iTimePoint);
                    curT = timeVec(iTimePoint);
                    pointsMat = rtVertices(rtVertices(:, 1) == curT, 2 : 3);
                    pointsMat =...
                        pointsMat.' / scaleFactor;
                    [centerVec shapeMat] = parameters(ell);
                    centerPointsMat = pointsMat -...
                        repmat(centerVec, 1, size(pointsMat, 2));
                    sqrtScalProdVec = sqrt(abs(dot(centerPointsMat,...
                        shapeMat\centerPointsMat) - 1));
                    mlunit.assert_equals(...
                        max(sqrtScalProdVec) < self.calcPrecision, true);
                end
            end
        end
        %
        function displayTest(self, reachObj, timeVec)
            rxDouble = '([\d.+\-e]+)';
            %
            resStr = evalc('reachObj.display');
            % time interval
            tokens = regexp(resStr,...
                ['time interval \[' rxDouble ',\s' rxDouble '\]'],...
                'tokens');
            tLimsRead = str2double(tokens{1}.').';
            difference = abs(tLimsRead(:) - timeVec(:));
            mlunit.assert_equals(max(difference) < self.COMP_PRECISION, true);
            % continuous-time
            isOk = ~isempty(strfind(resStr, 'continuous-time'));
            mlunit.assert_equals(isOk, true);
            % dimension
            tokens = regexp(resStr,...
                ['linear system in R\^' rxDouble],...
                'tokens');
            dimRead = str2double(tokens{1}{1});
            mlunit.assert_equals(dimRead, reachObj.dimension);
        end
    end
    methods
        function self = ContiniousReachTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName];
            % obtain the path of etalon data
            regrClassName =...
                'gras.ellapx.uncertcalc.test.regr.mlunit.SuiteRegression';
            shortRegrClassName = 'SuiteRegression';
            self.etalonDataRootDir = [fileparts(which(regrClassName)),...
                filesep, 'TestData', filesep, shortRegrClassName];
            self.etalonDataBranchKey = 'testRegression_out';
        end
        %
        function self = set_up_param(self, reachFactObj)
            self.reachObj = reachFactObj.createInstence();
            self.linSys = reachFactObj.getLinSys();
            self.expDim = reachFactObj.getDim();
            self.tVec = reachFactObj.getTVec();
            self.x0Ell = reachFactObj.getX0Ell();
            self.l0Mat = reachFactObj.getL0Mat();
        end
        %
        function self = testDisplay(self)
            self.displayTest(self.reachObj, self.tVec);
            newTimeVec = [sum(self.tVec)/2, self.tVec(2)];
            cutReachObj = self.reachObj.cut(newTimeVec);
            self.displayTest(cutReachObj, newTimeVec);
            projReachObj =...
                self.reachObj.projection(eye(self.reachObj.dimension, 2));
            self.displayTest(projReachObj, self.tVec);
        end
        %
        function self = testPlotEa(self)
            import gras.ellapx.enums.EApproxType;
            self.plotApproxTest(self.reachObj, EApproxType.External);
            newTimeVec = [sum(self.tVec) / 2, self.tVec(2)];
            cutReachObj = self.reachObj.cut(newTimeVec);
            self.plotApproxTest(cutReachObj, EApproxType.External);
            projReachObj =...
                self.reachObj.projection(eye(self.reachObj.dimension, 2));
            self.plotApproxTest(projReachObj, EApproxType.External);
        end
        %
        function self = testPlotIa(self)
            import gras.ellapx.enums.EApproxType;
            self.plotApproxTest(self.reachObj, EApproxType.Internal);
            newTimeVec = [sum(self.tVec) / 2, self.tVec(2)];
            cutReachObj = self.reachObj.cut(newTimeVec);
            self.plotApproxTest(cutReachObj, EApproxType.Internal);
            projReachObj =...
                self.reachObj.projection(eye(self.reachObj.dimension, 2));
            self.plotApproxTest(projReachObj, EApproxType.Internal);
        end
        %
        function self = testDimension(self)
            newTimeVec = [sum(self.tVec) / 2, self.tVec(2)];
            cutReachObj = self.reachObj.cut(newTimeVec);
            cutDim = cutReachObj.dimension;
            projReachObj =...
                self.reachObj.projection(eye(self.reachObj.dimension, 1));
            [rsDim ssDim] = projReachObj.dimension();
            isOk = (rsDim == self.expDim) && (ssDim == 1) &&...
                (cutDim == self.expDim);
            mlunit.assert_equals(true, isOk);
        end
        %
        function self = testIsEmpty(self)
            emptyRs = elltool.reach.ReachContinious();
            newTimeVec = [sum(self.tVec)/2, self.tVec(2)];
            cutReachObj = self.reachObj.cut(newTimeVec);
            projReachObj =...
                self.reachObj.projection(eye(self.reachObj.dimension, 1));
            mlunit.assert_equals(true, emptyRs.isempty);
            mlunit.assert_equals(false, self.reachObj.isempty);
            mlunit.assert_equals(false, cutReachObj.isempty);
            mlunit.assert_equals(false, projReachObj.isempty);
        end
        %
        function self = testEvolve(self)
            import gras.ellapx.smartdb.F;
            %
            timeVec = [self.tVec(1), sum(self.tVec)/2];
            newReachObj = elltool.reach.ReachContinious(self.linSys,...
                self.x0Ell, self.l0Mat, timeVec);
            evolveReachObj = newReachObj.evolve(self.tVec(2));
            %
            ellTube = self.reachObj.getEllTubeRel;
            pointsNum = numel(ellTube.timeVec{1});
            compTimeGridIndVec = 2 .* (1 : pointsNum) - 1;
            compTimeGridIndVec = compTimeGridIndVec +...
                double(compTimeGridIndVec > pointsNum);
            evolveEllTube = evolveReachObj.getEllTubeRel;
            fieldsNotToCompVec =...
                F.getNameList(self.FIELDS_NOT_TO_COMPARE);
            fieldsToCompVec =...
                setdiff(ellTube.getFieldNameList, fieldsNotToCompVec);
            newPointsNum = numel(evolveEllTube.timeVec{1});
            if pointsNum ~= newPointsNum
                evolveEllTube =...
                    evolveEllTube.thinOutTuples(compTimeGridIndVec);
            end
            isEqual = evolveEllTube.getFieldProjection(...
                fieldsToCompVec).isEqual(...
                ellTube.getFieldProjection(fieldsToCompVec),...
                'maxTolerance', self.COMP_PRECISION);
            mlunit.assert_equals(true, isEqual);
        end
        %
        function self = testGetSystem(self)
            isEqual = self.linSys == self.reachObj.get_system;
            mlunit.assert_equals(true, isEqual);
            projReachObj = self.reachObj.projection(...
                eye(self.reachObj.dimension, 2));
            isEqual = self.linSys == projReachObj.get_system;
            mlunit.assert_equals(true, isEqual);
            mlunit.assert_equals(true, isEqual);
        end
        %
        function self = testCut(self)
            import gras.ellapx.smartdb.F;
            %
            newTimeVec = [sum(self.tVec)/2, self.tVec(2)];
            cutReachObj = self.reachObj.cut(newTimeVec);
            cutEllTubeRel = cutReachObj.getEllTubeRel;
            nTuples = cutEllTubeRel.getNTuples;
            fieldsNotToCompVec =...
                F.getNameList(self.FIELDS_NOT_TO_COMPARE);
            fieldsToCompVec =...
                setdiff(cutEllTubeRel.getFieldNameList, fieldsNotToCompVec);
            for iTuple = 1 : nTuples
                compTuple = cutEllTubeRel.getTuples(iTuple);
                pointsNum = numel(compTuple.timeVec{1});
                timeDif = compTuple.timeVec{1}(1) - newTimeVec(1);
                compTimeGridIndVec = 2 .* (1 : pointsNum) - 1;
                x0DefVec = compTuple.aMat{1}(:, 1);
                x0DefMat = compTuple.QArray{1}(:, :, 1);
                x0Ell = ellipsoid(x0DefVec, x0DefMat);
                l0Mat = compTuple.ltGoodDirMat{1}(:, 1) /...
                    compTuple.ltGoodDirNormVec{1}(1);
                newReachObj = elltool.reach.ReachContinious(self.linSys,...
                    x0Ell, l0Mat, newTimeVec + timeDif);
                newEllTube =...
                    newReachObj.getEllTubeRel.getTuplesFilteredBy(...
                    'approxType', compTuple.approxType);
                newPointsNum = numel(newEllTube.timeVec{1});
                if pointsNum ~= newPointsNum
                    newEllTube =...
                        newEllTube.thinOutTuples(compTimeGridIndVec);
                end
                isEqual = compTuple.getFieldProjection(...
                    fieldsToCompVec).isEqual(...
                    newEllTube.getFieldProjection(fieldsToCompVec),...
                    'maxTolerance', self.COMP_PRECISION);
                mlunit.assert_equals(true, isEqual);
            end
        end
        %
        function self = testNegativeCut(self)
            projReachObj =...
                self.reachObj.projection(eye(self.reachObj.dimension, 2));
            newTimeVec = [sum(self.tVec)/2, self.tVec(2)];
            self.runAndCheckError('projReachObj.cut(newTimeVec)',...
                'wrongInput');
        end
    end
end