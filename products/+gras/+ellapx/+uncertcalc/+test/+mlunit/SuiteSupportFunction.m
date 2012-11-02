classdef SuiteSupportFunction < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
        confNameList
        crm
        crmSys
    end
    properties (Constant, GetAccess = private)
        rel_tol = 1e-6;
        abs_tol = 1e-7;
    end
    methods (Static)
        function dif = derivativeSupportFunction(t, x, aMat, bMat,...
                pVec, pMat, nElem)
            y = x(1 : nElem);
            %
            dif = zeros(nElem + 1, 1);
            dif(1 : nElem) = -(aMat(t).') * y;
            dif(nElem + 1) =...
                (y.') * bMat(t) * pVec(t) +...
                sqrt((y.') * bMat(t) * pMat(t) * (bMat(t).') * y);
        end
        %
        function fMatCalc = getHandleFromCellMat(inputCMat)
            localCMat = inputCMat;
            [nRows, nColumn] = size(localCMat);
            for iRow = 1 : nRows
                for jColumn = 1 : nColumn
                    if jColumn == nColumn
                        localCMat(iRow, jColumn) =...
                            strcat(localCMat(iRow, jColumn), ';');
                    else
                        localCMat(iRow, jColumn) =...
                            strcat(localCMat(iRow, jColumn), ',');
                    end
                end
            end
            localCMat = localCMat.';
            helpStr = strcat('fRes = @(t) [', localCMat{:}, '];');
            eval(helpStr);
            fMatCalc = fRes;
        end
    end
    methods
        function self = SuiteSupportFunction(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',filesep,shortClassName];
        end
        %
        function self = set_up_param(self,varargin)
            if nargin>2
                self.crm=varargin{2};
            else
                self.crm=gras.ellapx.uncertcalc.test.conf.ConfRepoMgr();
            end
            if nargin>3
                self.crmSys=varargin{3};
            else
                self.crmSys=...
                    gras.ellapx.uncertcalc.test.conf.sysdef.ConfRepoMgr();
            end
            confNameList=varargin{1};
            if strcmp(confNameList,'*')
                self.crm.deployConfTemplate('*');
                confNameList=self.crm.getConfNameList();
            end
            if ischar(confNameList)
                confNameList={confNameList};
            end
            self.confNameList=confNameList;
        end
        function testSupportCompare(self)
            crm=self.crm;
            crmSys=self.crmSys;
            confNameList=self.confNameList;
            nConfs=length(confNameList);
            for iConf=1:nConfs
                crm.deployConfTemplate(confNameList{iConf});
            end
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
                %SRunProp.ellTubeRel
                %
                calcPrecision = crm.getParam('genericProps.calcPrecision');
                isOk = all(SRunProp.ellTubeProjRel.calcPrecision <=...
                    calcPrecision);
                mlunit.assert_equals(true,isOk);
                
                AtCMat = self.crmSys.getParam('At');
                fAtMatCalc = self.getHandleFromCellMat(AtCMat);
                BtCMat = self.crmSys.getParam('Bt');
                fBtMatCalc = self.getHandleFromCellMat(BtCMat);
                PtCVec = self.crmSys.getParam('control_restriction.a');
                fPtVecCalc = self.getHandleFromCellMat(PtCVec);
                PtCMat = self.crmSys.getParam('control_restriction.Q');
                fPtMatCalc = self.getHandleFromCellMat(PtCMat);
                % X0 and x0 are double:
                X0Mat = self.crmSys.getParam('initial_set.Q');
                x0Vec = self.crmSys.getParam('initial_set.a');
                %
                timeCVec = SRunProp.ellTubeRel.timeVec;
                nTuples = SRunProp.ellTubeRel.getNTuples;
                %
                goodDirCMat = SRunProp.ellTubeRel.ltGoodDirMat;
                ellMatCArray = SRunProp.ellTubeRel.QArray;
                ellCenterCArray = SRunProp.ellTubeRel.aMat;
                %
                nElem = size(x0Vec, 1);
                odeOptionsVec = odeset('RelTol', self.rel_tol,...
                    'AbsTol', self.abs_tol * ones(nElem + 1, 1));
                for iTuple = 1 : nTuples
                    curTimeVec = timeCVec{iTuple};
                    curGoodDirMat = goodDirCMat{iTuple};
                    curEllMatArray = ellMatCArray{iTuple};
                    curEllCenterArray = ellCenterCArray{iTuple};
                    supFun0 =...
                        curGoodDirMat(:, 1).' * x0Vec +...
                        sqrt(curGoodDirMat(:, 1).' *...
                        X0Mat * curGoodDirMat(:, 1));
                    %
                    [~, expResultVec] =...
                        ode45(@(t, x) self.derivativeSupportFunction(t,...
                        x, fAtMatCalc, fBtMatCalc, fPtVecCalc,...
                        fPtMatCalc, nElem), curTimeVec,...
                        [curGoodDirMat(:, 1).', supFun0], odeOptionsVec);
                    %
                    expSupFuncMat = expResultVec(:, 1 : nElem);
                    supFuncMat = curGoodDirMat(:, :);
                    errorMat = abs(expSupFuncMat - supFuncMat.');
                    isOk = max(errorMat(:)) <= calcPrecision;
                    %
                    isOkCurrent = true;
                    for iTime = 1 : numel(curTimeVec)
                        supFun = curGoodDirMat(:, iTime).' *...
                            curEllCenterArray(:, iTime) +...
                            sqrt(curGoodDirMat(:, iTime).' *...
                            curEllMatArray(:, :, iTime) *...
                            curGoodDirMat(:, iTime));
                        isOkCurrent = isOkCurrent &&...
                            abs(supFun - expResultVec(iTime, end)) <=...
                            calcPrecision;
                        %if ~isOkCurrent
                        %    supFun
                        %	expResultVec(iTime, end)
                        %end
                    end
                    %isOkCurrent;
                    isOk = isOk && isOkCurrent;
                    mlunit.assert_equals(true, isOk);
                end
            end
        end
    end
end