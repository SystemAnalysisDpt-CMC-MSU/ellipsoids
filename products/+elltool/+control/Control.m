classdef Control
% Control - class allowing to construct control synthesis in specified
%   point (t,x) by appealing to its controlVectorFunct property and to
%   compute corresponding trajectory in the phase space
% 
% Properties:
%   properEllTube - gras.ellapx.smartdb.rels.EllTube object is an
%       ellipsoidal tube that is used for control synthesis constructing
%   
%   probDynamicsList - cellArray of gras.ellapx.lreachplain.probdyn.LReachProblemLTIDynamics
%       objects that provides information about system's dynamics
% 
%   goodDirSetList - cellArray of gras.ellapx.lreachplain.GoodDirsContinuousLTI
%       objects that provides information about so-called 'good directions'
% 
%   downScaleKoeff - coefficient of internal ellipsoid tube approximation scaling
% 
%   controlVectorFunct - an eltool.control.ControlVectorFunct object
%       allowing to get constructed control synthesis at any point (t,x)
% 
% Methods:
%   Control() - class constructor
% 
%   getTrajectory() - returns an array containing trajectory corresponding
%       to constructed control synthesis
% 
%   getITube() - returns index of ellipsoidal tube used for constructing
%       control synthesis
% 

    properties
        properEllTube
        probDynamicsList
        goodDirSetList
        downScaleKoeff
        controlVectorFunct
    end
    methods
        function self = Control(properEllTube,...
                probDynamicsList, goodDirSetList,indTube,inDownScaleKoeff)
            % CONTROL is a class constructor. Creates an instance of
            %   Control class defining required properties and constructing
            %   ControlVectorFunct object allowing to get control synthesis
            %   at any point (t,x)
            %
            % Input:
            %   properEllTube: gras.ellapx.smartdb.rels.EllTube object - an
            %       ellipsoidal tube that is used for control synthesis
            %       constructing 
            %
            %   probDynamicsList: cellArray of gras.ellapx.lreachplain.probdyn.LReachProblemLTIDynamics
            %       objects - provides information about system's
            %       dynamics 
            %
            %   goodDirSetList: cellArray of gras.ellapx.lreachplain.GoodDirsContinuousLTI
            %       objects - provides information about so-called 'good directions'
            %
            %   indTube: index of ellipsoidal tube used for constructing
            %       control synthesis 
            %
            %   inDownScaleKoeff: coefficient of internal ellipsoid tube approximation scaling
            
            self.properEllTube = properEllTube;
            self.probDynamicsList = probDynamicsList;
            self.goodDirSetList = goodDirSetList;
            self.downScaleKoeff = inDownScaleKoeff;
            self.controlVectorFunct = elltool.control.ControlVectorFunct(properEllTube,...
                self.probDynamicsList, self.goodDirSetList,indTube,inDownScaleKoeff);
        end


        function trajectory = getTrajectory(self,x0Vec,switchSysTimeVec,isX0inSet)
            % GETTRAJECTORY - returns an array containing trajectory
            %   corresponding to constructed control synthesis 
            %
            % Input:
            %   x0Vec - double[n,1], where n is a dimentionality of phase
            %       space - position from which the syntesis is to 
            %       be constructed
            %
            %   switchSysTimeVec: double[1,] - vector consisting of
            %       system's switch times
            %
            %   isX0inSet: bool expression showing whether given x0Vec is
            %       in the solvability set W[t_0]
            %
            % Output:
            %   trajectory: double[n,n_time] wheren is a dimentionality of
            %       the phase space and the n_time is a number of time
            %       moments the control synthesis is constructed in -
            %       trajectory, corresponding to constructed control
            %       synthesis

            import modgen.common.throwerror;
            ERR_TOL = 1e-4;
            REL_TOL = 1e-4;
            ABS_TOL = 1e-4;
            trajectory = [];
            switchTimeVecLenght = numel(switchSysTimeVec);
            SOptions = odeset('RelTol',REL_TOL,'AbsTol',ABS_TOL);
            properTube = self.controlVectorFunct.getITube();
            self.properEllTube.scale(@(x)1/sqrt(self.downScaleKoeff),'QArray'); 

            for iSwitch = 1:switchTimeVecLenght-1                 
                iTube = 1;
                iSwitchBack = switchTimeVecLenght - iSwitch;
                if (iSwitchBack > 1)
                    iTube = properTube;
                end
                tStart = switchSysTimeVec(iSwitch);
                tFin = switchSysTimeVec(iSwitch+1);
               
                indFin = find(self.properEllTube.timeVec{1}==tFin);
                AtMat = self.probDynamicsList{iSwitchBack}{iTube}.getAtDynamics();
                
                [~,odeResMat] = ode45(@(t,y)ode(t,y,AtMat,self.controlVectorFunct,tFin),[tStart tFin],x0Vec',SOptions);
             
                q1Vec = self.properEllTube.aMat{1}(:,indFin);
                q1Mat = self.properEllTube.QArray{1}(:,:,indFin);
                
                currentScalProd = dot(odeResMat(end,:)'-q1Vec,q1Mat\(odeResMat(end,:)'-q1Vec));
                
                if (isX0inSet)&&(currentScalProd > 1 + ERR_TOL)
                    throwerror('TestFails',...
                        'the result of test does not correspond with theory');
                end
                if (~isX0inSet)&&(currentScalProd < 1 - ERR_TOL)
                    throwerror('TestFails',...
                        'the result of test does not correspond with theory');
                end
                x0Vec = odeResMat(end,:);
                trajectory = cat(1,trajectory,odeResMat);
            end
            
            function dyMat = ode(time,yMat,AtMat,controlFuncVec,tFin)
               dyMat = -AtMat.evaluate(tFin-time)*yMat+controlFuncVec.evaluate(yMat,time);
            end
            
            
        end
        function indTube = getITube(self)
            % GETITUBE - returns index of ellipsoidal tube used for
            %   constructing control synthesis
            
            indTube = self.controlVectorFunct.getITube();
        end
    end
end