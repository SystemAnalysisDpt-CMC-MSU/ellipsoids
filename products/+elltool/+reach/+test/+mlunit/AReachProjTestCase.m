classdef AReachProjTestCase < mlunitext.test_case
    properties (Access = protected, Constant)
        FIELDS_NOT_TO_COMPARE={'LT_GOOD_DIR_MAT';'LT_GOOD_DIR_NORM_VEC';...
            'LS_GOOD_DIR_NORM';'LS_GOOD_DIR_VEC'};
        COMP_PRECISION = 5e-5;
    end
    properties (Access = protected)
        confName
        crm
        crmSys
        linSys
        reachObj
        timeVec
        calcPrecision
        linSysFactory
        reachObfFactory
        addArgList
    end
    methods (Access = private)
        function [atDefCMat, btDefCMat, ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec, x0DefMat,...
                x0DefVec, l0Mat] = getSysParams(self)
            atDefCMat = self.crmSys.getParam('At');
            btDefCMat = self.crmSys.getParam('Bt');
            ctDefCMat = self.crmSys.getParam('Ct');
            ptDefCMat = self.crmSys.getParam('control_restriction.Q');
            ptDefCVec = self.crmSys.getParam('control_restriction.a');
            qtDefCMat = self.crmSys.getParam('disturbance_restriction.Q');
            qtDefCVec = self.crmSys.getParam('disturbance_restriction.a');
            x0DefMat = self.crmSys.getParam('initial_set.Q');
            x0DefVec = self.crmSys.getParam('initial_set.a');
            l0CMat = self.crm.getParam(...
                'goodDirSelection.methodProps.manual.lsGoodDirSets.set1');
            l0Mat = cell2mat(l0CMat.').';
        end
    end
    methods
        function self = AReachProjTestCase(linSysFactory, ...
                reachObfFactory, varargin)
            self = self@mlunitext.test_case(varargin{:});
            %
            self.linSysFactory = linSysFactory;
            self.reachObfFactory = reachObfFactory;
        end
        %
        function self = set_up_param(self, confName, crm, crmSys)
            self.crm = crm;
            self.crmSys = crmSys;
            self.confName = confName;
            %
            self.crm.deployConfTemplate(self.confName);
            self.crm.selectConf(self.confName);
            sysDefConfName = self.crm.getParam('systemDefinitionConfName');
            self.crmSys.selectConf(sysDefConfName, 'reloadIfSelected', false);
            %
            [atDefCMat, btDefCMat, ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec,...
                x0DefMat, x0DefVec, l0Mat] = self.getSysParams();
            %
            self.timeVec = [self.crmSys.getParam('time_interval.t0'),...
                self.crmSys.getParam('time_interval.t1')];
            self.calcPrecision =...
                self.crm.getParam('genericProps.calcPrecision');
            isRegEnabled = crm.getParam('regularizationProps.isEnabled');
            isJustCheck = crm.getParam('regularizationProps.isJustCheck');
            regTol = crm.getParam('regularizationProps.regTol');
            ControlBounds = struct();
            ControlBounds.center = ptDefCVec;
            ControlBounds.shape = ptDefCMat;
            DistBounds = struct();
            DistBounds.center = qtDefCVec;
            DistBounds.shape = qtDefCMat;
            self.addArgList={...
                'isRegEnabled', isRegEnabled,...
                'isJustCheck', isJustCheck,...
                'regTol', regTol};
            %
            self.linSys = self.linSysFactory.create(atDefCMat, btDefCMat,...
                ControlBounds, ctDefCMat, DistBounds);
            self.reachObj = self.reachObfFactory.create(self.linSys,...
                ellipsoid(x0DefVec, x0DefMat), l0Mat, self.timeVec,...
                self.addArgList{:});
        end
        %
        function self = testProjection(self)
            [atDefCMat, btDefCMat, ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec,...
                x0DefMat, x0DefVec, l0Mat] = self.getSysParams();
            zeroASizeCMat = arrayfun(@num2str, zeros(size(atDefCMat)),...
                'UniformOutput', false);
            newAtCMat = [atDefCMat zeroASizeCMat; zeroASizeCMat atDefCMat];
            zeroBSizeCMat = arrayfun(@num2str, zeros(size(btDefCMat)),...
                'UniformOutput', false);
            newBtCMat = [btDefCMat zeroBSizeCMat; zeroBSizeCMat btDefCMat];
            zeroCSizeCMat = arrayfun(@num2str, zeros(size(ctDefCMat)),...
                'UniformOutput', false);
            newCtCMat = [ctDefCMat zeroCSizeCMat; zeroCSizeCMat ctDefCMat];
            zeroPSizeCMat = arrayfun(@num2str, zeros(size(ptDefCMat)),...
                'UniformOutput', false);
            newPtCMat = [ptDefCMat zeroPSizeCMat; zeroPSizeCMat ptDefCMat];
            newPtCVec = [ptDefCVec; ptDefCVec];
            zeroQSizeCMat = arrayfun(@num2str, zeros(size(qtDefCMat)),...
                'UniformOutput', false);
            newQtCMat = [qtDefCMat zeroQSizeCMat; zeroQSizeCMat qtDefCMat];
            newQtCVec = [qtDefCVec; qtDefCVec];
            newX0Mat = [x0DefMat zeros(size(x0DefMat));...
                zeros(size(x0DefMat)) x0DefMat];
            newX0Vec = [x0DefVec; x0DefVec];
            new1L0Mat = [l0Mat; zeros(size(l0Mat))];
            new2L0Mat = [zeros(size(l0Mat));l0Mat];
            ControlBounds = struct();
            ControlBounds.center = newPtCVec;
            ControlBounds.shape = newPtCMat;
            DistBounds = struct();
            DistBounds.center = newQtCVec;
            DistBounds.shape = newQtCMat;
            %
            reachClassName=class(self.reachObj);
            oldDim = self.reachObj.dimension();
            x0Ell=ellipsoid(newX0Vec, newX0Mat);
            timeVec=self.timeVec;
            %
            newLinSys = self.linSysFactory.create(newAtCMat, ...
                newBtCMat, ControlBounds, newCtCMat, DistBounds);
            %
            firstNewReachObj = feval(reachClassName, newLinSys,...
                x0Ell, new1L0Mat, timeVec,self.addArgList{:});
            secondNewReachObj = feval(reachClassName, newLinSys,...
                x0Ell, new2L0Mat, timeVec,self.addArgList{:});
            firstProjReachObj =...
                firstNewReachObj.projection([eye(oldDim); zeros(oldDim)]);
            secondProjReachObj =...
                secondNewReachObj.projection([zeros(oldDim); eye(oldDim)]);
            [isEqual,reportStr] = self.reachObj.isEqual(firstProjReachObj);
            mlunitext.assert(isEqual,reportStr);
            %
            [isEqual,reportStr] = self.reachObj.isEqual(secondProjReachObj);
            mlunitext.assert(isEqual,reportStr);
        end
    end
end