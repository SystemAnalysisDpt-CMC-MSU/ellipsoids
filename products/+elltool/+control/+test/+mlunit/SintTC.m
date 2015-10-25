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
   end
 
   methods (Abstract, Access = public)
       controlObj = getControlBuilder(self)
       % GETCONTROLLOBJ() - returns a ControlBuilder object

   end
   
   methods (Access = protected)
       function self = setUpReachObj(self)
            methodName = modgen.common.getcallernameext(1);
            resMap = modgen.containers.ondisk.HashMapMatXML(...
                'storageLocationRoot',self.testDataRootDir,...
                'storageBranchKey',[methodName,'_out'],...
                'storageFormat','mat',...
                'useHashedPath',false,'useHashedKeys',false);
            inpKey = self.marker;
            if self.isReCache||~resMap.isKey(inpKey);
                self.reachObj = self.reachFactoryObj.createInstance();
                resMap.put(inpKey,self.reachObj);
            else
                self.reachObj = resMap.get(inpKey);
            end
        end
   end
   
    methods
        function self = SintTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~, className] = modgen.common.getcallernameext(1);
            shortClassName = mfilename('classname');
            self.testDataRootDir = [fileparts(which(className)),...
                filesep, 'TestData', filesep, shortClassName];
        end
        
        
        function self = set_up_param(self, reachFactObj,inPointVecList,outPointVecList,isReCache)
            self.isReCache = isReCache;
            self.reachFactoryObj = reachFactObj;
            self.setUpReachObj();
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
            intEllTube=ellTubeRel.getTuplesFilteredBy('approxType',...
                        gras.ellapx.enums.EApproxType.Internal);
            
            nTuples = intEllTube.getNTuples();           
            x0Mat = self.inPointList;
            for iXCount=1:size(x0Mat,1)
                x0Vec=x0Mat(iXCount,:);
                x0Vec=transpose(x0Vec);
                isX0inSet=false;
  
                controlBuilderObj = self.getControlBuilder();
                controlObj = controlBuilderObj.getControlObj(x0Vec);
                if (~all(size(x0Vec)==size(intEllTube.aMat{1}(:,1))))
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
                
                properTube = controlObj.getProperEllTube();
                [isMemberTube, properTubeInd] = properTube.isMemberTuples(ellTubeRel,'lsGoodDirVec');
                
                if (isMemberTube)
                    traj_struct = controlObj.getTrajectory(x0Vec,switchSysTimeVec,isX0inSet);
                    trajectory = traj_struct.trajectory;
                    Y = trajectory(end,:);
                    
%                     %----------------
%                     tmp_obj = self.reachObj;
%                     tmp_obj.plotByIa;
%                     hold on;
%                     plot3(traj_struct.trajectory_time,traj_struct.trajectory(:,1),traj_struct.trajectory(:,2));               
%                     %----------------
                    
                    q1Vec=ellTubeRel.aMat{properTubeInd}(:,end);
                    q1Mat=ellTubeRel.QArray{properTubeInd}(:,:,end);
                    currentScalProd = dot(Y(end,:)'-q1Vec,q1Mat\(Y(end,:)'-q1Vec));
                    if (isX0inSet)&&(currentScalProd > 1+TOL)
                        isCurrentEqual=false;
                    end
                    if (~isX0inSet)&&(currentScalProd < 1-TOL)
                        isCurrentEqual=false;
                    end
                    isOk=isOk&&isCurrentEqual;
                else
                    isOk = false;
                end
%              x0Vec
%              isOk
            
            end
            mlunitext.assert_equals(true, isOk);

        end
    end
end