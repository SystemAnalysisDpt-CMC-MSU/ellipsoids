classdef ContinuousReachProjAdvTestCase < mlunitext.test_case
    properties (Access=private, Constant)
        FIELDS_NOT_TO_COMPARE={'LT_GOOD_DIR_NORM_ORIG_VEC';'PROJ_S_MAT';...
            'LS_GOOD_DIR_ORIG_VEC';'LS_GOOD_DIR_NORM_ORIG'};
        COMP_PRECISION = 5e-5;
        PROJECTION_DIM8_MAT =...
            [-0.1936    0.0434    0.1801    0.3372   -0.0717    0.7744   -0.4447    0.1091;
            -0.4176   -0.3222   -0.1170    0.2453   -0.7028   -0.2820   -0.0221    0.2718;
            -0.2262    0.3719   -0.0565    0.2184    0.4048   -0.4508   -0.4716    0.4125;
            -0.5929   -0.3479   -0.4257    0.1079    0.4623    0.0976    0.1567   -0.2946;
            -0.3082    0.3135    0.2163   -0.1362   -0.2346   -0.2003   -0.3407   -0.7281;
            -0.0575   -0.1476    0.7013    0.5397    0.1969   -0.1814    0.3316   -0.1005;
            -0.4258   -0.1585    0.4721   -0.6740    0.1083    0.0631    0.0201    0.3166;
            -0.3254    0.6998   -0.0886    0.0518   -0.1333    0.1760    0.5731    0.1293];
        PROJECTION_DIM8_BAD_PRECISION_MAT =...
            [-0.3451126   0.3091247   0.1022637  -0.4061281  -0.1599044  -0.1919095  -0.7003819   0.2387626;
            -0.4160338   0.0045913  -0.0077580  -0.4420995   0.0648344   0.4185748   0.1064638  -0.6638069;
            -0.1995329   0.3747356  -0.2621767  -0.1836413   0.3945015  -0.6320387   0.4004566  -0.0427675;
            -0.1471558   0.0758409  -0.4969488  -0.2412257  -0.5473035   0.2355905   0.3749963   0.4144622;
            -0.2648665   0.1989438   0.0693239   0.4947966  -0.6113108  -0.3088413   0.0247729  -0.4134487;
            -0.1902155  -0.7360569  -0.4950542  -0.0082436   0.0068319  -0.3165102  -0.2523365  -0.1139838;
            -0.4280734   0.2356341  -0.3608991   0.5476068   0.3722359   0.3669343  -0.1908691   0.1465494;
            -0.5972953  -0.3483677   0.5418988   0.0541199   0.0524137  -0.0527960   0.3105226   0.3511920];
        PROJECTION_DIM2_MAT = [-0.9442   -0.3293;
            -0.3293    0.9442];
        DIM2_SYS_IND_VEC = [1 2];
        DIM8_SYS_IND_VEC = [1 2 6];
    end
    properties (Access=private)
        etalonDataRootDir
        etalonDataBranchKey
        confName
        crm
        crmSys
        linSys
        reachObj
        timeVec
        calcPrecision
        mode
    end
    methods (Access = private, Static)
        function newCMat = multiplyCMat(cellMat, doubleMultMatLeft,...
                doubleMultMatRight)
            doubleMat = cellfun(@str2num,cellMat);
            if (nargin == 2)
                newDoubleMat = doubleMultMatLeft*doubleMat;
            elseif (nargin == 3)
                newDoubleMat = doubleMultMatLeft*doubleMat*...
                    doubleMultMatRight;
            end
            newCMat = arrayfun(@num2str,newDoubleMat,...
                'UniformOutput', false);
        end
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
        %
        function auxTestProjection(self,indVec,caseName,projMat)
            [atDefCMat, btDefCMat, ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec,...
                x0DefMat, x0DefVec, l0Mat] = self.getSysParams();
            if 	nargin < 4
                [projMat, ~] = qr(rand(size(atDefCMat)));
            end
            newAtCMat = self.multiplyCMat(atDefCMat,projMat,inv(projMat));
            newBtCMat = self.multiplyCMat(btDefCMat,projMat);
            newCtCMat = self.multiplyCMat(ctDefCMat,projMat);
            newPtCMat = ptDefCMat;
            newQtCMat = qtDefCMat;
            newPtCVec = ptDefCVec;
            newQtCVec = qtDefCVec;
            newX0Mat = projMat*x0DefMat*projMat';
            newX0Vec = projMat*x0DefVec;
            newL0Mat = projMat*l0Mat;
            ControlBounds = struct();
            ControlBounds.center = newPtCVec;
            ControlBounds.shape = newPtCMat;
            DistBounds = struct();
            DistBounds.center = newQtCVec;
            DistBounds.shape = newQtCMat;
            directionsMat = eye(size(atDefCMat));
            invProjMat=inv(projMat);
            %
            newLinSys = elltool.linsys.LinSysFactory.create(newAtCMat,...
                newBtCMat, ControlBounds, newCtCMat, DistBounds);
            newReachObj = elltool.reach.ReachContinuous(newLinSys,...
                ellipsoid(newX0Vec, newX0Mat), newL0Mat, self.timeVec);
            
            secondProjReachObj =...
                newReachObj.projection(invProjMat(indVec,:)');
            checkPlot(secondProjReachObj);
            %
            firstProjReachObj =...
                self.reachObj.projection(directionsMat(indVec,:)');
            checkPlot(firstProjReachObj);
            %
            [isEqual,reportStr] = secondProjReachObj.isEqual(...
                firstProjReachObj,self.FIELDS_NOT_TO_COMPARE);
            failMsg=sprintf('failure for case %s, %s',caseName,reportStr);
            mlunit.assert_equals(true,isEqual,failMsg);
            function checkPlot(reachObj)
                if numel(indVec)==2
                    reachObj.plot_ia();
                    reachObj.plot_ea();
                end
            end
        end
    end
    %
    methods
        function self = ContinuousReachProjAdvTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function tear_down(~)
            close all;
        end
        %
        function self = set_up_param(self, confName, crm, crmSys, inpMode)
            self.crm = crm;
            self.crmSys = crmSys;
            self.confName = confName;
            self.mode = inpMode;
            %
            self.crm.deployConfTemplate(self.confName);
            self.crm.selectConf(self.confName);
            sysDefConfName = self.crm.getParam('systemDefinitionConfName');
            self.crmSys.selectConf(sysDefConfName,...
                'reloadIfSelected', false);
            %
            [atDefCMat, btDefCMat, ctDefCMat, ptDefCMat,...
                ptDefCVec, qtDefCMat, qtDefCVec,...
                x0DefMat, x0DefVec, l0Mat] = self.getSysParams();
            %
            self.timeVec = [self.crmSys.getParam('time_interval.t0'),...
                self.crmSys.getParam('time_interval.t1')];
            self.calcPrecision =...
                self.crm.getParam('genericProps.calcPrecision');
            ControlBounds = struct();
            ControlBounds.center = ptDefCVec;
            ControlBounds.shape = ptDefCMat;
            DistBounds = struct();
            DistBounds.center = qtDefCVec;
            DistBounds.shape = qtDefCMat;
            
            self.linSys = elltool.linsys.LinSysFactory.create(atDefCMat,...
                btDefCMat, ControlBounds, ctDefCMat, DistBounds);
            self.reachObj = elltool.reach.ReachContinuous(self.linSys,...
                ellipsoid(x0DefVec, x0DefMat), l0Mat, self.timeVec);
        end
        %
        function self = testProjection(self)
            import modgen.common.throwerror;
            nDims = self.reachObj.dimension();
            caseName = self.mode;
            switch nDims
                case 2
                    projMat = self.PROJECTION_DIM2_MAT;
                    indVec = self.DIM2_SYS_IND_VEC;
                case 8
                    projMat = self.PROJECTION_DIM8_MAT;
                    indVec = self.DIM8_SYS_IND_VEC;
                otherwise
                    throwerror('wrongInput:badDimensionality',...
                        ['expected dimensionality is 8 or 2, ',...
                        'real dimensionality is %d'],nDims);
            end
            switch lower(caseName)
                case 'fix'
                    self.auxTestProjection(indVec,caseName,projMat);
                case 'rand'
                    self.auxTestProjection(indVec,caseName);
                otherwise
                    throwerror('wrongInput:badMode',...
                        'mode %s is not supported',caseName);
            end
        end
    end
end