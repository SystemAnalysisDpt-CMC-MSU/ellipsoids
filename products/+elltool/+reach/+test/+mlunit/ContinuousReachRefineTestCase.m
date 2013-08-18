classdef ContinuousReachRefineTestCase < mlunitext.test_case
    properties (Access = private, Constant)
        SIZE_LIST = {[2 2], [2 2 3], [0 0 1 0 1]};
        ARRAY_METHODS_LIST = {'dimension', 'iscut', 'isprojection',...
            'isEmpty'};
    end
    properties (Access=private)
        l0P1Mat
        l0P2Mat
        reachFactObj
    end
    methods
        function self = ContinuousReachRefineTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self, inpReachFactObj)
            self.reachFactObj = inpReachFactObj;
            l0Mat = inpReachFactObj.getL0Mat();
            [~, mSize]=size(l0Mat);
            nPart1=floor(mSize/2);
            self.l0P1Mat=l0Mat(:,1:nPart1);
            self.l0P2Mat=l0Mat(:,nPart1+1:end);
        end
        %
        function self = testRefine(self)
            import gras.ellapx.smartdb.F;
            %
            reachObj = self.reachFactObj.createInstance();
            reachWholeObj = self.reachFactObj.createInstance(...
                'l0Mat',self.l0P1Mat);
            %
            reachWholeObj = reachWholeObj.refine(self.l0P2Mat);
            isEqual = reachObj.isEqual(reachWholeObj);
            mlunitext.assert_equals(true,isEqual);
        end
        function self = testArrayMethods(self)
            cellfun(@(x) checkArrayMethods(self,x), self.SIZE_LIST);
            function checkArrayMethods(self, sizeVec)
                reachSingleObj=self.reachFactObj.createInstance();
                cellfun(@(x) checkSingleMethod(reachSingleObj,x,sizeVec),...
                    self.ARRAY_METHODS_LIST);
            end
        end
        function self = testGetCopyMethod(self)
            cellfun(@(x) checkGetCopy(self,x), self.SIZE_LIST);
            %
            function checkGetCopy(self,sizeVec)
                reachSingleObj=self.reachFactObj.createInstance();
                reachArr = repmat(reachSingleObj,sizeVec);
                compReachArr = reachArr.getCopy();
                checkEq(reachArr,compReachArr,'getCopy');
            end
        end
        function self = testRepMatMethod(self)
            cellfun(@(x) checkRepMat(self,x), self.SIZE_LIST);
            function checkRepMat(self,sizeVec)
                reachSingleObj=self.reachFactObj.createInstance();
                reachArr = repmat(reachSingleObj,sizeVec);
                compReachArr = reachSingleObj.repMat(sizeVec);
                checkEq(reachArr,compReachArr,'repMat');
            end
        end
        function self = testRefMisc(self)
            %Check Evolve after Refine
            checkEvRef(1);
            checkEvRef(2);
            %
            [lDirMat l1DirMat l2DirMat] = setDir(1);
            %Check Refine direct time
            timeVec=[0 1];
            reachSetObj=buildRS(l1DirMat,timeVec);
            checkRefine(reachSetObj,l2DirMat,lDirMat);
            %
            %Check refine reverse time
            timeVec=[1 0];
            reachSetObj=buildRS(l1DirMat,timeVec);
            checkRefine(reachSetObj,l2DirMat,lDirMat);
            %
            % Check after evolve
            newEndTime=2;
            timeVec=[0 1];
            reachSetObj=buildRS(l1DirMat,timeVec);
            reachSetObj = reachSetObj.evolve(newEndTime);
            timeVec=[0 2];
            checkRefine(reachSetObj,l2DirMat,lDirMat);
            %
            % Check after evolve, reverse time
            newEndTime=0;
            timeVec=[2 1];
            reachSetObj=buildRS(l1DirMat,timeVec);
            reachSetObj = reachSetObj.evolve(newEndTime);
            timeVec = [2 0];
            checkRefine(reachSetObj,l2DirMat,lDirMat);
            %
            % Check projection
            timeVec=[0 1];
            reachSetObj=buildRS(l1DirMat,timeVec);
            %
            projMat=[1,0;0,1];
            ellTubeProjRel=reachSetObj.projection(projMat);
            %
            ellTubeProjRelNew=ellTubeProjRel;
            ellTubeProjRelNew = ellTubeProjRelNew.refine(l2DirMat);
            %
            reachSetObj=buildRS(lDirMat,timeVec);
            projReachSetObj=reachSetObj.projection(projMat);
            checkRes(ellTubeProjRelNew,projReachSetObj);
            %
            function [lDirMat l1DirMat l2DirMat] = setDir(typeVal)
                switch typeVal
                    case 1
                        lDirMat=[1,-1,0,1;
                            0,1,1,-2];
                        nN=2;
                        l1DirMat=lDirMat(:,1:nN);
                        l2DirMat=lDirMat(:,nN+1:end);
                    case 2
                        lDirMat=[1,-1,1,10,0,1;
                            0,2,5,1,1,-1];
                        nN=3;
                        l1DirMat=lDirMat(:,1:nN);
                        l2DirMat=lDirMat(:,nN+1:end);
                end
            end
            function checkRefine(reachSetObj,l2DirMat,lDirMat)
                reachObjNew=reachSetObj;
                reachObjNew = reachObjNew.refine(l2DirMat);
                reachSetObj=buildRS(lDirMat,timeVec);
                checkRes(reachObjNew,reachSetObj);
            end
            function checkEvRef(typeVal)
                [lDirMat l1DirMat l2DirMat] = setDir(typeVal);
                timeVec=[0 1];
                reachObjNew=buildRS(l1DirMat,timeVec);
                reachObjNew = reachObjNew.refine(l2DirMat);
                timeVec=[0 2];
                reachObjNew = reachObjNew.evolve(timeVec(end));
                reachSetObj=buildRS(lDirMat,timeVec);
                checkRes(reachObjNew,reachSetObj);
            end
            function reachObj = buildRS(lDirMat,timeVec)
                aMat=[1 2; 2 1];
                bMat=[1 2;0 1];
                uEllMat=eye(2);
                x0EllMat=eye(2);
                reachObj = self.reachFactObj.createInstance('At',aMat,...
                    'Bt',bMat,'controlMat',uEllMat,'x0EllMat',x0EllMat,...
                    'l0Mat',lDirMat,'tVec',timeVec);
            end
        end
        function self = testEvRefDiffSyst(self)
            lDirMat=[1,-1,0,1;
                0,1,1,-2;
                0,0,0,1];
            l1DirMat=lDirMat(:,1:2);
            l2DirMat=lDirMat(:,3:end);
            %
            pMat=eye(3);
            %
            a1Mat=[1 2 0; 2 1 0; 0 0 1];
            b1Mat=[1 2 0;0 1 0; 0 0 1];
            %
            a2Mat=eye(3);
            b2Mat=[1 0 0; 0 1 0; 0 0 1];
            sys2 = self.reachFactObj.createSysInstance(a2Mat,...
                b2Mat, pMat);
            %
            a3Mat=[2 1 -1; 1 2 0; 1 0 1];
            b3Mat=[1 0 -1; 0 1 0; -1 0 2];
            sys3 = self.reachFactObj.createSysInstance(a3Mat,...
                b3Mat, pMat);
            %
            %Straightforward time
            timeVec = [0 1 2 3];
            checkEvRef(timeVec);
            %
            %Reverse time
            timeVec = [3 2 1 0];
            checkEvRef(timeVec);
            
            function reachObj = buildReachObj(aMat, bMat, lDirMat,timeVec)
                uEllMat = eye(3);
                uEllVec = [0 0 0]';
                x0EllMat=eye(3);
                x0EllVec = [0 0 0]';
                reachObj = self.reachFactObj.createInstance('At',aMat,...
                    'Bt',bMat,'controlMat',uEllMat,'controlVec',uEllVec,...
                    'x0EllMat',x0EllMat,'x0EllVec',x0EllVec,...
                    'l0Mat',lDirMat,'tVec',[timeVec(1) timeVec(2)]);
            end
            function reachSetObj = evolveReachObj(reachSetObj,timeVec)
                reachSetObj = reachSetObj.evolve(timeVec(3),sys2);
                reachSetObj = reachSetObj.evolve(timeVec(4),sys3);
            end
            function checkEvRef(timeVec)
                reachSetObj = buildReachObj(a1Mat, b1Mat, ...
                    l1DirMat,timeVec);
                reachSetObj = evolveReachObj(reachSetObj,timeVec);
                reachSetObjWhole = buildReachObj(a1Mat, b1Mat, ...
                    lDirMat,timeVec);
                reachSetObjWhole = evolveReachObj(reachSetObjWhole,timeVec);
                %
                %Check projection
                reachSetObjProj = reachSetObj;
                projMat = [1,0;0,1;0,0];
                projReachSet = reachSetObjProj.projection(projMat);
                projReachSet = projReachSet.refine(l2DirMat);
                projReachSetObjWhole = reachSetObjWhole.projection(projMat);
                checkRes(projReachSet,projReachSetObjWhole);
                %
                %Check not a projection
                reachSetObj = reachSetObj.refine(l2DirMat);
                checkRes(reachSetObj,reachSetObjWhole);
            end
        end
    end
end
function checkEq(initMat,compMat,methodName)
import modgen.common.throwerror;
import modgen.cell.cellstr2expression;
%
NON_OBJ_OUT_METHOD_LIST = {'dimension','iscut','isprojection','isEmpty'};
OBJ_OUT_METHOD_LIST = {'getCopy','repMat'};
switch methodName
    case NON_OBJ_OUT_METHOD_LIST
        [isEq failMsg] = checkSimpleEq(initMat,compMat,methodName);
    case OBJ_OUT_METHOD_LIST
        [isEq failMsg] = checkObjEq(initMat,compMat,methodName);
    otherwise
        throwerror('wrongInput:unknownMethod',...
            'Unexpected method: %s. Allowed methods: %s,%s',...
            methodName,...
            cellstr2expression({NON_OBJ_OUT_METHOD_LIST{:}, OBJ_OUT_METHOD_LIST{:}}));
end
mlunitext.assert_equals(true,isEq,failMsg);
%
    function [isEq failMsg] = checkSimpleEq(initMat,compMat,methodName)
        failMsg = [];
        isEq = isequal(initMat, compMat.(methodName));
        if ~isEq
            failMsg = sprintf('failure for %s() method;',methodName);
        end
    end
%
    function [isEq failMsg] = checkObjEq(initMat,compMat,methodName)
        isEq = arrayfun(@(x,y) x.isEqual(y), initMat, compMat);
        if ~isEq
            failMsg = sprintf('failure for %s() method;',methodName);
            isEq = false;
        else
            failMsg = [];
            isEq = true;
        end
    end
end
function checkSingleMethod(reachObj,methodName,sizeVec)
reachObjMat = reachObj.repMat(sizeVec);
dimMat = repmat(reachObj.(methodName),sizeVec);
checkEq(dimMat,reachObjMat,methodName);
end
function checkRes(reachObjNew,reachSetObj)
[isEqual,reportStr] = reachSetObj.isEqual(reachObjNew);
mlunitext.assert_equals(true,isEqual,reportStr);
end