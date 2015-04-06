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
   end
 
   methods (Abstract, Access = public)
       controlObj = getcontrolObj(self)
       %    
       
   end
   
    methods
        function self = SintTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName];
            
        end
        %
        function self = set_up_param(self, reachFactObj,inPointVecList,outPointVecList)
            self.reachFactoryObj=reachFactObj;
            self.reachObj = reachFactObj.createInstance();
            self.linSys = reachFactObj.getLinSys();
            self.expDim = reachFactObj.getDim();
            self.tVec = reachFactObj.getTVec();
            self.x0Ell = reachFactObj.getX0Ell();
            self.l0Mat = reachFactObj.getL0Mat();
            self.inPointList =inPointVecList;
            self.outPointList=outPointVecList;
        end
 
    end
    
    methods 
                 
        function isOk = testReachControl(self)
            isOk=1;
            TOL=10^(-5);
            ellTubeRel=self.reachObj.getEllTubeRel();
            switchSysTimeVec=self.reachObj.getSwitchTimeVec();                
            intEllTube=ellTubeRel.getTuplesFilteredBy('approxType', gras.ellapx.enums.EApproxType.Internal);
            
            nTuples = intEllTube.getNTuples();           
            x0Mat=self.inPointList;
            for iXCount=1:size(x0Mat,1)
                x0Vec=x0Mat(iXCount,:);
                x0Vec=transpose(x0Vec);
                isX0inSet=false;
  
                controlObj = self.getcontrolObj();
                controlFuncObj=controlObj.getControl(x0Vec);
                if (~all(size(x0Vec)==size(intEllTube.aMat{1}(:,1))))
                    self.runAndCheckError('controlObj.getControl(x0Vec)','wrongInput');
                    return; 
                end   
                for iTube=1:nTuples
                   

                    qVec=intEllTube.aMat{iTube}(:,1);  
                    qMat=intEllTube.QArray{iTube}(:,:,1); 
                    if (dot(x0Vec-qVec,qMat\(x0Vec-qVec))<=1+TOL)
                        isX0inSet=true;
                    end
                end
                isCurrentEqual=true;
                properTube=controlFuncObj.getITube();   
                trajectory=controlFuncObj.getTrajectory(x0Vec,switchSysTimeVec,isX0inSet);
                
                Y=trajectory(end,:);
                q1Vec=ellTubeRel.aMat{properTube}(:,end);
                q1Mat=ellTubeRel.QArray{properTube}(:,:,end);
                if (isX0inSet)&&(dot(Y(end,:)'-q1Vec,q1Mat\(Y(end,:)'-q1Vec))>1+TOL)
                    isCurrentEqual=false;
                end
                if (~isX0inSet)&&(dot(Y(end,:)'-q1Vec,q1Mat\(Y(end,:)'-q1Vec))<1-TOL)
                    isCurrentEqual=false;
                end
                isOk=isOk&&isCurrentEqual;
                
            end
            mlunitext.assert_equals(true, isOk);

        end
    end
end