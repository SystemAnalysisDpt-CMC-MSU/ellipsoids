classdef ContinuousReachProjTestCase < ...
        elltool.reach.test.mlunit.AReachProjTestCase
    properties (Access=protected)
        etalonDataRootDir
        etalonDataBranchKey        
    end
    methods (Access = private)
        function isEqual = isEqualApprox(self, expRel, approxType)
            import modgen.common.throwerror;
            import gras.ellapx.enums.EApproxType;
            import gras.ellapx.smartdb.F;
            APPROX_TYPE = F.APPROX_TYPE;
            %
            SData = expRel.getTuplesFilteredBy(APPROX_TYPE, approxType);
            if approxType == EApproxType.External
                approxEllMat = self.reachObj.get_ea();
            else
                approxEllMat = self.reachObj.get_ia();
            end
            %
            nTuples = SData.getNTuples();
            isEqual = true;
            if nTuples > 0
                nTimes = numel(SData.timeVec{1});
                SData.timeVec
                for iTuple = nTuples : -1 : 1
                    tupleCentMat = SData.aMat{iTuple};
                    tupleMatArray = SData.QArray{iTuple};
                    for jTime = nTimes : -1 : 1
                        approxEllMat(iTuple, jTime)
                        [centerVec shapeMat] =...
                            approxEllMat(iTuple, jTime).parameters;
                        tupleCentMat(:, jTime)
                        tupleMatArray(:, :, jTime)
                        isEqual = isEqual &&...
                            (norm(centerVec - tupleCentMat(:, jTime)) <=...
                            self.COMP_PRECISION) &&...
                            (norm(shapeMat - tupleMatArray(:, :, jTime)) <=...
                            self.COMP_PRECISION);
                    end
                end
            else
                throwerror('WrongInput', 'No tuple is found.');
            end
        end        
    end
    methods
        function self = ContinuousReachProjTestCase(varargin)
            self = self@elltool.reach.test.mlunit.AReachProjTestCase(...
                elltool.linsys.LinSysContinuousFactory(), ...
                elltool.reach.ReachContinuousFactory(), ...
                varargin{:});
            %
            regrClassName =...
                'gras.ellapx.uncertcalc.test.regr.mlunit.SuiteRegression';
            shortRegrClassName = 'SuiteRegression';
            self.etalonDataRootDir = [fileparts(which(regrClassName)),...
                filesep, 'TestData', filesep, shortRegrClassName];
            self.etalonDataBranchKey = 'testRegression_out';            
        end
        function self = testGetEllTubeRel(self)
            mlunitext.assert(all(self.reachObj.get_ia() == ...
                self.reachObj.getEllTubeRel().getEllArray(...
                gras.ellapx.enums.EApproxType.Internal))); 
            mlunitext.assert(all(self.reachObj.get_ea() == ...
                self.reachObj.getEllTubeRel().getEllArray(...
                gras.ellapx.enums.EApproxType.External))); 
            l0CMat = self.crm.getParam(...
                'goodDirSelection.methodProps.manual.lsGoodDirSets.set1');
            l0Mat = cell2mat(l0CMat.').';
            projMat = l0Mat(:,1);
            projReachObj = self.reachObj.projection(projMat);
            projReachObj.getEllTubeRel();

        end
        function self = testGetEllTubeUnionRel(self)
            NOT_COMPARE_FIELD_LIST={'isLsTouch','isLtTouchVec'...
                'xTouchCurveMat','xTouchOpCurveMat','xsTouchOpVec',...
                'xsTouchVec'};
            ellTubeRel = self.reachObj.getEllTubeRel();
            ellTubeUnionRel = self.reachObj.getEllTubeUnionRel();
            compFieldList = setdiff(fieldnames(ellTubeRel()),...
                NOT_COMPARE_FIELD_LIST);
            %
            [isOk, reportStr] = ...
                ellTubeUnionRel.getFieldProjection(compFieldList). ...
                isEqual(ellTubeRel.getFieldProjection(compFieldList));
            mlunitext.assert(isOk,reportStr);
            l0CMat = self.crm.getParam(...
                'goodDirSelection.methodProps.manual.lsGoodDirSets.set1');
            l0Mat = cell2mat(l0CMat.').';
            projMat = l0Mat(:,1);
            projReachObj = self.reachObj.projection(projMat);
            projReachObj.getEllTubeUnionRel();
        end
        function self = testSystem(self)
            import modgen.common.throwerror;
            import gras.ellapx.enums.EApproxType;
            %
            ELL_TUBE_REL = 'ellTubeRel';
            resMap = modgen.containers.ondisk.HashMapMatXML(...
                'storageLocationRoot', self.etalonDataRootDir,...
                'storageBranchKey', self.etalonDataBranchKey,...
                'storageFormat', 'mat', 'useHashedPath', false,...
                'useHashedKeys', true);
            %
            if resMap.isKey(self.confName);
                SExpRes = resMap.get(self.confName);
                expRel = SExpRes.(ELL_TUBE_REL);
                isExt = self.isEqualApprox(expRel, EApproxType.External);
                isInt = self.isEqualApprox(expRel, EApproxType.Internal);
                isOk = isExt && isInt;
                mlunitext.assert_equals(true, isOk);
            else
                throwerror('WrongInput', 'Do not exist config mat file.');
            end
        end
    end
end