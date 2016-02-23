classdef SintTC < mlunitext.test_case
    properties (Access=protected)
        testDataRootDir
        linSys
        reachObj
        tVec
        x0Ell
        l0Mat
        expDim
        reachFactoryObj
        inPointList
        outPointList
        isReCache
        timeoutInSeconds
    end
    %
    methods (Abstract,Access=public)
        controlObj=getControlBuilder(self,timeout)
    end
    %
    methods (Access=protected)
        function self=setUpReachObj(self)
            %
            methodName=modgen.common.getcallernameext(1);
            resMap=modgen.containers.ondisk.HashMapMatXML(...
                'storageLocationRoot',self.testDataRootDir,...
                'storageBranchKey',[methodName,'_out'],...
                'storageFormat','mat',...
                'useHashedPath',false,'useHashedKeys',false);
            inpKey=self.marker;
            if self.isReCache||~resMap.isKey(inpKey);
                self.reachObj=self.reachFactoryObj.createInstance();
                resMap.put(inpKey,self.reachObj);
            else
                self.reachObj=resMap.get(inpKey);
            end
        end
    end
    %
    methods
        function self=SintTC(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',filesep,shortClassName];
        end
        %
        function self=set_up_param(self,reachFactObj,inPointVecList,...
                outPointVecList,varargin)
            [~,~,self.isReCache,self.timeoutInSeconds]=...
                modgen.common.parseparext(varargin,...
                    {'reCache','timeout';...
                    false,0;...
                    'islogical(x)','isscalar(x)'},0);
            %
            self.reachFactoryObj=reachFactObj;
            self.setUpReachObj();
            self.linSys=reachFactObj.getLinSys();
            self.expDim=reachFactObj.getDim();
            self.tVec=reachFactObj.getTVec();
            self.x0Ell=reachFactObj.getX0Ell();
            self.l0Mat=reachFactObj.getL0Mat();
            self.inPointList=inPointVecList;
            self.outPointList=outPointVecList;
        end
    end
    %
    methods
        function isOk=testReachControl(self)
            isOk=true;
            TOL=1e-5;
            ellTubeRel=self.reachObj.getEllTubeRel();
            intEllTube=ellTubeRel.getTuplesFilteredBy('approxType',...
                gras.ellapx.enums.EApproxType.Internal);
            %
            nTuples=intEllTube.getNTuples();
            x0Mat=[self.inPointList;self.outPointList];
            %
            for iXCount=1:size(x0Mat,1)
                x0Vec=x0Mat(iXCount,:);
                x0Vec=transpose(x0Vec);
                isX0inSet=false;
                %
                if self.timeoutInSeconds == 0
                    controlBuilderObj=...
                        self.getControlBuilder();
                else
                    controlBuilderObj=...
                        self.getControlBuilder(self.timeoutInSeconds);
                end
                controlObj=controlBuilderObj.getControlObj(x0Vec);
                if ~all(size(x0Vec)==size(intEllTube.aMat{1}(:,1)))
                    self.runAndCheckError('controlObj.getControl(x0Vec)',...
                        'wrongInput');
                    return;
                end
                for iTube=1:nTuples
                    qVec=intEllTube.aMat{iTube}(:,1);
                    qMat=intEllTube.QArray{iTube}(:,:,1);
                    if (dot(x0Vec-qVec,qMat\(x0Vec-qVec))<=1+TOL)
                        isX0inSet=true;
                        break;
                    end
                end
                isCurrentEqual=true;
                %
                properTube=controlObj.getProperEllTube();
                [isMemberTube,properTubeInd] =...
                    properTube.isMemberTuples(ellTubeRel,'lsGoodDirVec');
                %
                if (isMemberTube)
                    [~,trajectory]=controlObj.getTrajectory(x0Vec);
                    trajEnd=trajectory(end,:);
                    %
                    q1Vec=ellTubeRel.aMat{properTubeInd}(:,end);
                    q1Mat=ellTubeRel.QArray{properTubeInd}(:,:,end);
                    currentScalProd=dot(trajEnd(end,:)'-q1Vec, ...
                        q1Mat\(trajEnd(end,:)'-q1Vec));
                    if (isX0inSet)&&(currentScalProd > 1+TOL)
                        isCurrentEqual=false;
                    end
                    if (~isX0inSet)&&(currentScalProd < 1-TOL)
                        isCurrentEqual=false;
                    end
                    isOk=isOk&&isCurrentEqual;
                else
                    isOk=false;
                end
            end
            mlunitext.assert_equals(true,isOk);
        end
    end
end