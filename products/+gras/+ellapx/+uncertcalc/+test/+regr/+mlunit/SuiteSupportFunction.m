classdef SuiteSupportFunction < mlunitext.test_case
% $Author: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: 2-11-2012 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Computer Science,
%             System Analysis Department 2012 $
    properties (Access=private)
        testDataRootDir
        confNameList
        crm
        crmSys
    end
    properties (Constant, GetAccess = private)
        REL_TOL_FACTOR = 1e-3;
        ABS_TOL_FACTOR = 1e-3;
    end
    methods (Static)
        function difVec = derivativeSupportFunction(t, ~, fxVec, fAMat,...
                fBMat, fPVec, fPMat, nElem)
            cxVec = fxVec(t);
            cBMat = fBMat(t);
            difVec =...
                (cxVec.') * cBMat * fPVec(t) +...
                sqrt((cxVec.') * cBMat * fPMat(t) * (cBMat.') ...
                * cxVec);
        end
    end
    methods
        function self = SuiteSupportFunction(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName];
        end
        %
        function self = set_up_param(self, varargin)
            if nargin > 2
                self.crm = varargin{2};
            else
                self.crm =...
                    gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
            end
            if nargin > 3
                self.crmSys = varargin{3};
            else
                self.crmSys =...
                    gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
            end
            confNameList = varargin{1};
            if strcmp(confNameList, '*')
                self.crm.deployConfTemplate('*');
                confNameList = self.crm.getConfNameList();
            end
            if ischar(confNameList)
                confNameList = {confNameList};
            end
            self.confNameList = confNameList;
        end
        %
        function testSupportCompare(self)
            crm = self.crm;
            crmSys = self.crmSys;
            confNameList = self.confNameList;
            nConfs = length(confNameList);
            for iConf = 1 : nConfs
                crm.deployConfTemplate(confNameList{iConf});
            end
            %
            matOpObj = gras.mat.CompositeMatrixOperations();
            %
            for iConf = 1 : nConfs
                confName = confNameList{iConf};
                crm.selectConf(confName);
                crm.setParam('plottingProps.isEnabled',false,...
                    'writeDepth','cache');
                %
                SRunProp = gras.ellapx.uncertcalc.run(confName,...
                    'confRepoMgr', crm, 'sysConfRepoMgr', crmSys);
                %
                fGetScaleFactor = @(x)1/x;
                scaleFactorFieldList = {'scaleFactor'};
                SRunProp.ellTubeRel.scale(fGetScaleFactor,...
                    scaleFactorFieldList);
                %
                calcPrecision = crm.getParam('genericProps.calcPrecision');
                isOk = all(SRunProp.ellTubeProjRel.calcPrecision <=...
                    calcPrecision);
                mlunit.assert_equals(true,isOk);
                %
                AtCMat = self.crmSys.getParam('At');
                fAtMatCalc = @(t) ...
                    matOpObj.fromSymbMatrix(AtCMat).evaluate(t);
                BtCMat = self.crmSys.getParam('Bt');
                fBtMatCalc = @(t) ...
                    matOpObj.fromSymbMatrix(BtCMat).evaluate(t);
                PtCVec = self.crmSys.getParam('control_restriction.a');
                fPtVecCalc = @(t) ...
                    matOpObj.fromSymbMatrix(PtCVec).evaluate(t);
                PtCMat = self.crmSys.getParam('control_restriction.Q');
                fPtMatCalc = @(t) ...
                    matOpObj.fromSymbMatrix(PtCMat).evaluate(t);
                x0Vec = self.crmSys.getParam('initial_set.a');
                %
                timeCVec = SRunProp.ellTubeRel.timeVec;
                nTuples = SRunProp.ellTubeRel.getNTuples;
                %
                goodDirCMat = SRunProp.ellTubeRel.ltGoodDirMat;
                ellMatCArray = SRunProp.ellTubeRel.QArray;
                ellCenterCMat = SRunProp.ellTubeRel.aMat;
                %
                nElem = size(x0Vec, 1);
                OdeOptionsStruct = odeset(...
                    'RelTol', calcPrecision * self.REL_TOL_FACTOR,...
                    'AbsTol', calcPrecision * self.ABS_TOL_FACTOR);
                lsGoodDirMat = SRunProp.goodDirSetObj.getlsGoodDirMat();
                lsGoodDirCMat = SRunProp.ellTubeRel.lsGoodDirVec();
                for iTuple = 1 : nTuples
                    curTimeVec = timeCVec{iTuple};
                    curGoodDirMat = goodDirCMat{iTuple};
                    curEllMatArray = ellMatCArray{iTuple};
                    curEllCenterMat = ellCenterCMat{iTuple};
                    %
                    % good directions' indexes mapping
                    %
                    curGoodDirVec = lsGoodDirCMat{iTuple};
                    for iGoodDir = 1:size(lsGoodDirMat, 2)
                        isFound = norm(curGoodDirVec - ...
                            lsGoodDirMat(:, iGoodDir)) <= calcPrecision;
                        if isFound
                            break;
                        end
                    end
                    mlunit.assert_equals(true, isFound,...
                        'good dir vector not found');
                    %
                    curGoodDirDynamicsObj = ...
                        SRunProp.goodDirSetObj.getGoodDirOneCurveSpline(...
                        iGoodDir);
                    fCalcXMat = @(t) curGoodDirDynamicsObj.evaluate(t);
                    %
                    supFun0 =...
                        curGoodDirMat(:, 1).' * curEllCenterMat(:, 1) +...
                        sqrt(curGoodDirMat(:, 1).' *...
                        curEllMatArray(:, :, 1) * curGoodDirMat(:, 1));
                    %
                    [~, expResultMat] =...
                        ode45(@(t, x) self.derivativeSupportFunction(t,...
                        x, fCalcXMat, fAtMatCalc, fBtMatCalc, ...
                        fPtVecCalc, fPtMatCalc, nElem), curTimeVec,...
                        supFun0, OdeOptionsStruct);
                    %
                    supFunVec =...
                        sqrt(gras.gen.SquareMatVector.lrMultiplyByVec(...
                        curEllMatArray,curGoodDirMat)) +...
                        sum(curEllCenterMat .* curGoodDirMat, 1);
                    expNormResVec = expResultMat(:, end) ./...
                        norm(expResultMat(:, end));
                    normSupFunVec = supFunVec.' ./ norm(supFunVec);
                    errorSupFunMat =...
                        abs(expNormResVec - normSupFunVec);                    
                    errTol = max(errorSupFunMat(:));
                    isOk = errTol <= calcPrecision;
                    mlunit.assert_equals(true, isOk,...
                        sprintf('errTol=%g>calcPrecision=%g', errTol,...
                        calcPrecision));
                end
            end
        end
    end
end