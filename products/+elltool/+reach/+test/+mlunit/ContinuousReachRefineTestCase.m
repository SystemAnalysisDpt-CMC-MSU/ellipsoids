classdef ContinuousReachRefineTestCase < mlunitext.test_case
    properties (Access = private, Constant)
        SIZE_LIST = {[2 2], [10 9 8], [0 0 1 0 1]};
        ARRAY_METHODS_LIST = {'dimension', 'iscut', 'isprojection',...
            'isempty'};
    end    
    properties (Access=private)
        linSys
        tVec
        x0Ell
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
            self.linSys = inpReachFactObj.getLinSys();
            self.tVec = inpReachFactObj.getTVec();
            l0Mat = inpReachFactObj.getL0Mat();
            [~, mSize]=size(l0Mat);
            nPart1=floor(mSize/2);
            self.x0Ell = inpReachFactObj.getX0Ell();
            self.l0P1Mat=l0Mat(:,1:nPart1);
            self.l0P2Mat=l0Mat(:,nPart1+1:end);
        end
        %
        function self = testRefine(self)
            import gras.ellapx.smartdb.F;
            %
            reachWholeObj=elltool.reach.ReachContinuous(self.linSys,...
                self.x0Ell,self.l0P1Mat,self.tVec);
            %
            reachWholeObj.refine(self.l0P2Mat);
            isEqual = self.reachObj.isEqual(reachWholeObj);
            mlunit.assert_equals(true,isEqual);
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
            lSys=buildLS();
            %Check Evolve after Refine
            checkEvRef(1);
            checkEvRef(2);
            %
            setDir(1);
            %Check Refine direct time
            timeVec=[0 0.5];
            reachSetObj=buildRS(l1DirMat);
            checkRefine();
            %
            %Check refine reverse time
            timeVec=[0.5 0];
            reachSetObj=buildRS(l1DirMat);
            checkRefine();
            %
            % Check after evolve
            newEndTime=1;
            timeVec=[0 0.5];
            reachSetObj=buildRS(l1DirMat);
            reachSetObj.evolve(newEndTime);
            checkRefine();
            %
            % Check after evolve, reverse time
            newEndTime=0;
            timeVec=[1 0.5];
            reachSetObj=buildRS(l1DirMat);
            reachSetObj.evolve(newEndTime);
            checkRefine();
            %
            % Check projection
            timeVec=[0 0.5];
            reachSetObj=buildRS(l1DirMat);
            %
            projMat=[1,0;0,1];
            projSet=reachSetObj.projection(projMat);
            %
            projSetNew=projSet;
            projSetNew.refine(l2DirMat);
            %
            reachSetObj=buildRS(lDirMat);
            projReachSetObj=reachSetObj.projection(projMat);
            isEqual = projSetNew.isEqual(projReachSetObj);
            mlunit.assert_equals(true,isEqual);   
            %
            function checkRefine()
                reachObjNew=reachSetObj;
                reachObjNew.refine(l2DirMat);
                reachSetObj=buildRS(lDirMat);
                checkRes(reachObjNew);
            end
            function checkRes(reachObjNew)
                isEqual = reachSetObj.isEqual(reachObjNew);
                mlunit.assert_equals(true,isEqual);
            end
            function setDir(typeVal)
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
            function checkEvRef(typeVal)
                setDir(typeVal);              
                timeVec=[0 0.5];
                reachObjNew=buildRS(l1DirMat);
                reachObjNew.refine(l2DirMat);
                timeVec=[0 1];
                reachObjNew.evolve(timeVec(end));
                reachSetObj=buildRS(lDirMat);
            end            
            function reachSet = buildRS(lDirMat)
                x0EllObj=ellipsoid(eye(2));
                reachSet=elltool.reach.ReachContinuous(...
                    lSys,x0EllObj,lDirMat,timeVec);
            end
            function linSys = buildLS()
                aMat=[1 2; 2 1];
                bMat=[1 2;0 1];
                uEll=ellipsoid(eye(2));
                linSys=elltool.linsys.LinSysContinuous(aMat,bMat,uEll);
            end
        end
    end
end
function checkEq(initMat,compMat,methodName)
    import modgen.common.throwerror;
    import modgen.cell.cellstr2expression;
    %
    NON_OBJ_OUT_METHOD_LIST = {'dimension','iscut','isprojection','isempty'};
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
    mlunit.assert_equals(true,isEq,failMsg);
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