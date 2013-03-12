classdef ContinuousReachTestCase < mlunitext.test_case
    properties (Access = private, Constant)
        FIELDS_NOT_TO_COMPARE={'LT_GOOD_DIR_MAT';'LT_GOOD_DIR_NORM_VEC';...
            'LS_GOOD_DIR_NORM';'LS_GOOD_DIR_VEC';'IND_S_TIME';'S_TIME'};
        COMP_PRECISION = 5e-3;
        REL_TOL = 1e-5;
    end
    properties (Access=private)
        testDataRootDir
        linSys
        reachObj
        tVec
        x0Ell
        l0Mat
        expDim
    end
    methods (Access = private)
        %
        function plotApproxTest(self, reachObj, approxType)
            import gras.ellapx.enums.EApproxType;
            import modgen.common.throwerror;
            if approxType == EApproxType.External
                ellArray = reachObj.get_ea;
                plotter = reachObj.plot_ea;
                scaleFactor = reachObj.getEaScaleFactor;
            elseif approxType == EApproxType.Internal
                ellArray = reachObj.get_ia;
                plotter = reachObj.plot_ia;
                scaleFactor = reachObj.getIaScaleFactor;
            end
            [dirCVec timeVec] = reachObj.get_directions;
            goodDirCVec =...
                cellfun(@(x) x(:, 1), dirCVec.', 'UniformOutput', false);
            dim = ellArray(1, 1).dimension;
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
                normalizeCVecFunc =...
                    @(v)cellfun(@(x) x / sqrt(sum(x.*x)),...
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
                    pointsMat = rtVertices(rtVertices(:, 1) == curT, 2 : 3);
                    pointsMat = pointsMat.';
                    [centerVec shapeMat] = parameters(ell);
                    centerPointsMat = pointsMat -...
                        repmat(centerVec, 1, size(pointsMat, 2));
                    if ~reachObj.isprojection
                        centerPointsMat = centerPointsMat / scaleFactor;
                    end
                    sqrtScalProdVec = sqrt(abs(dot(centerPointsMat,...
                        shapeMat\centerPointsMat) - 1));
                    mlunit.assert_equals(...
                        max(sqrtScalProdVec) < self.COMP_PRECISION, true);
                end
            end
            plotter.closeAllFigures();
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
        function self = ContinuousReachTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName];
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
            emptyRs = elltool.reach.ReachContinuous();
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
            newReachObj = elltool.reach.ReachContinuous(self.linSys,...
                self.x0Ell, self.l0Mat, timeVec);
            evolveReachObj = newReachObj.evolve(self.tVec(2));
            %
            isEqual = self.reachObj.isEqual(evolveReachObj);
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
            import gras.ellapx.enums.EApproxType;
            %
            newTimeVec = [sum(self.tVec)/2, self.tVec(2)];
            cutReachObj = self.reachObj.cut(newTimeVec);
            [iaEllMat timeVec] = cutReachObj.get_ia;
            eaEllMat = cutReachObj.get_ea;
            nTuples = size(iaEllMat, 1);
            timeDif = timeVec(1) - newTimeVec(1);
            for iTuple = 1 : nTuples
                x0IaEll = iaEllMat(iTuple, 1);
                x0EaEll = eaEllMat(iTuple, 1);
                l0Mat = cutReachObj.get_directions{iTuple}(:, 1);
                l0Mat = l0Mat ./ norm(l0Mat);
                newIaReachObj = elltool.reach.ReachContinuous(self.linSys,...
                    x0IaEll, l0Mat, newTimeVec + timeDif);
                newEaReachObj = elltool.reach.ReachContinuous(self.linSys,...
                    x0EaEll, l0Mat, newTimeVec + timeDif);
                isIaEqual = cutReachObj.isEqual(newIaReachObj, iTuple,...
                    EApproxType.Internal);
                isEaEqual = cutReachObj.isEqual(newEaReachObj, iTuple,...
                    EApproxType.External);
                mlunit.assert_equals(true, isIaEqual);
                mlunit.assert_equals(true, isEaEqual);
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