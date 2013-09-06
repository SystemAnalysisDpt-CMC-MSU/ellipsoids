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
        resTmpDir
    end
    properties (Constant, GetAccess = private)
        REL_TOL_FACTOR = 1e-3;
        ABS_TOL_FACTOR = 1e-3;
    end
    methods (Static)
        function dSFunc = derSolFunction(t, x, fGetGoodDirVec,...
                fTransRstMat, fAtMat, fPtVec, fPtMat)
            import gras.gen.matdot;
            %
            lVec=fGetGoodDirVec(t);
            % derivative Rtt0 function
            transMat = fTransRstMat(t)';
            cacheAMat = transMat * fAtMat(t);
            dSFunc = lVec.' * fPtVec(t) + ...
                realsqrt(lVec.' * fPtMat(t) * lVec) + ...
                x * matdot(transMat, cacheAMat);
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
        function self = set_up(self)
            self.resTmpDir = elltool.test.TmpDataManager.getDirByCallerKey;
        end
        function self = tear_down(self)
            rmdir(self.resTmpDir,'s');
        end
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
            import modgen.common.throwerror;
            %
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
                crm.setParam('customResultDir.dirName',self.resTmpDir,...
                    'writeDepth','cache');
                crm.setParam('customResultDir.isEnabled',true,...
                    'writeDepth','cache');
                crm.setParam('plottingProps.isEnabled',false,...
                    'writeDepth','cache');
                %
                [SRunProp, SRunAuxProp] = gras.ellapx.uncertcalc.run(confName,...
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
                mlunitext.assert_equals(true,isOk);
                %
                pDynObj=SRunAuxProp.pDynObj;
                %
                atMatDynObj=pDynObj.getAtDynamics();
                %
                fAtMatCalc = @(t)atMatDynObj.evaluate(t);
                %
                ptVecDynObj = pDynObj.getBptDynamics();
                fPtVecCalc = @(t)ptVecDynObj.evaluate(t);
                %
                ptMatDynObj=pDynObj.getBPBTransDynamics();
                fPtMatCalc = @(t)ptMatDynObj.evaluate(t);
                %
                x0Vec = pDynObj.getx0Vec;
                x0Mat=pDynObj.getX0Mat;
                %
                timeCVec = SRunProp.ellTubeRel.timeVec;
                nTuples = SRunProp.ellTubeRel.getNTuples;
                %
                ellMatCArray = SRunProp.ellTubeRel.QArray;
                ellCenterCMat = SRunProp.ellTubeRel.aMat;
                %
                OdeOptionsStruct = odeset(...
                    'RelTol', calcPrecision * self.REL_TOL_FACTOR,...
                    'AbsTol', calcPrecision * self.ABS_TOL_FACTOR);
                lsGoodDirMat = SRunAuxProp.goodDirSetObj.getlsGoodDirMat();
                for iGoodDir = 1:size(lsGoodDirMat, 2)
                    lsGoodDirMat(:, iGoodDir) = ...
                        lsGoodDirMat(:, iGoodDir) / ...
                        norm(lsGoodDirMat(:, iGoodDir));
                end
                lsGoodDirCMat = SRunProp.ellTubeRel.lsGoodDirVec();
                curGoodDirObj = SRunAuxProp.goodDirSetObj;
                curGoodDirTransMatObj = curGoodDirObj.getRstTransDynamics;
                fCalcTransMat = @(t) curGoodDirTransMatObj.evaluate(t);
                for iTuple = 1 : nTuples
                    curTimeVec = timeCVec{iTuple};
                    curEllMatArray = ellMatCArray{iTuple};
                    curEllCenterMat = ellCenterCMat{iTuple};
                    %
                    % good directions' indexes mapping
                    %
                    curGoodDirVec = lsGoodDirCMat{iTuple};
                    curGoodDirVec = curGoodDirVec / norm(curGoodDirVec);
                    %
                    for iGoodDir = 1:size(lsGoodDirMat, 2)
                        isFound = norm(curGoodDirVec - ...
                            lsGoodDirMat(:, iGoodDir)) <= calcPrecision;
                        if isFound
                            break;
                        end
                    end
                    mlunitext.assert_equals(true, isFound,...
                        'Vector mapping - good dir vector not found');
                    %
                    curGoodDirVecDynamicsObj = ...
                        curGoodDirObj.getRGoodDirOneCurveSpline(iGoodDir);
                    fCalclVec = @(t) curGoodDirVecDynamicsObj.evaluate(t);
                    %
                    currGoodDirVec = curGoodDirVecDynamicsObj.evaluate(...
                        curTimeVec(1));
                    supFun0 =...
                        currGoodDirVec.' * x0Vec +...
                        realsqrt(currGoodDirVec.' *...
                        x0Mat * currGoodDirVec);
                    %
                    [~, expResultMat] =...
                        ode45(@(t, x) self.derSolFunction(t,...
                        x, fCalclVec, fCalcTransMat, fAtMatCalc, ...
                        fPtVecCalc, fPtMatCalc), curTimeVec,...
                        supFun0, OdeOptionsStruct);
                    %
                    currGoodDirMat = squeeze(...
                        curGoodDirVecDynamicsObj.evaluate(curTimeVec));
                    supFunVec =...
                        realsqrt(gras.gen.SquareMatVector.lrMultiplyByVec(...
                        curEllMatArray,currGoodDirMat)) +...
                        sum(curEllCenterMat .* currGoodDirMat, 1);
                    %
                    [isOk, ~, ~, ~, ~, reportStr] = ...
                        modgen.common.absrelcompare(supFunVec(:), ...
                        expResultMat(:), calcPrecision, calcPrecision, ...
                        @abs);
                    if ~isOk
                        reportResStr = horzcat('Support function values ',...
                            reportStr);
                        throwerror('tol', reportResStr);
                    end
                end
            end
        end
    end
end