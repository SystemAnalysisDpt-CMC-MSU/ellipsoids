classdef ControlVectorFunct < elltool.control.IControlVectFunction&...
        modgen.common.obj.HandleObjectCloner
    %
    properties (Access=private)
        properEllTube
        probDynamicsObj
        goodDirSetObj
        downScaleKoeff
        ellTubeTimeVec
        bigQInterpObj
        aInterpObj
        t0
        t1
    end
    %
    methods
        function self=ControlVectorFunct(properEllTube,...
                probDynamicsObj,goodDirSetObj,inDownScaleKoeff,t0,t1)
            % CONTROLVECTORFUNCT is a class providing evaluation of control
            % synthesis for predetermined position (t,x)
            %
            % Input:
            %   regular:
            %       properEllTube: gras.ellapx.smartdb.rels.EllTube[1,1]
            %           - an ellipsoidal tube object that is used for
            %           contol synthesis constructing
            %
            %       probDynamicsObj:
            %           gras.ellapx.lreachplain.probdyn.LReachProblemLTIDynamics[1,1]
            %           object providing information about system's
            %           dynamics
            %
            %       goodDirSetObj:
            %           gras.ellapx.lreachplain.GoodDirsContinuousLTI[1,1]
            %           object providing information about
            %           'good directions'
            %
            %       inDownScaleKoeff: scaling coefficient for internal
            %           ellipsoid tube approximation
            %
            % $Author: Komarov Yuri <ykomarov94@gmail.com> $
            % $Date: 2015-30-10 $
            %
            if properEllTube.getNTuples()~=1
                modgen.common.throwerror('wrongInput',...
                    'properEllTube must have only 1 tuple');
            end
            self.properEllTube=properEllTube;
            self.probDynamicsObj=probDynamicsObj;
            self.goodDirSetObj=goodDirSetObj;
            self.downScaleKoeff=inDownScaleKoeff;
            self.t0=t0;
            self.t1=t1;
            self.ellTubeTimeVec=self.properEllTube.timeVec{1};
            bigQArray=self.properEllTube.QArray{1}(:,:,:);
            self.bigQInterpObj=...
                gras.mat.interp.MatrixInterpolantFactory.createInstance(...
                'posdef_chol',bigQArray,self.ellTubeTimeVec);
            aMat=self.properEllTube.aMat{1};
            self.aInterpObj=...
                gras.mat.interp.MatrixInterpolantFactory.createInstance(...
                'column',aMat,self.ellTubeTimeVec);
        end
        %
        function resVec=evaluate(self,xVec,tVal)
            % EVALUATE evaluates control synthesis for predetermined
            % position (t,x)
            %
            % Input:
            %   regular:
            %       xVec: double[nDim,1] where n is dimentionality
            %           of the phase space - x coordinate for control
            %           synthesis evaluation
            %
            %       tVal: double[1,1] - scalar time moment for control
            %           synthesis evaluation
            % Output:
            %   resMat: double[nDim,timeVecLength] - control synthesis
            %      values evaluated for specified positions (xVec,tVal)
            %
            % $Author: Komarov Yuri <ykomarov94@gmail.com> $
            % $Date: 2015-30-10 $
            %
            indTime=sum(self.ellTubeTimeVec <= tVal);
            if self.ellTubeTimeVec(indTime) < tVal
                qVec = self.aInterpObj.evaluate(tVal);
                qMat=self.bigQInterpObj.evaluate(tVal);
            else %ellTubeTimeVec(indTime) == curControlTime
                qVec=self.properEllTube.aMat{1}(:,indTime);
                qMat=self.properEllTube.QArray{1}(:,:,indTime);
            end
            %
            xstTransMat=self.goodDirSetObj.getXstTransDynamics();
            % X(t,t_0) =
            %   ( xstTransMat.evaluate(t)\xstTransMat.evaluate(t_0) ).'
            xt1tMat=transpose(xstTransMat.evaluate(self.t1)\...
                xstTransMat.evaluate(tVal));
            %
            [pVec,pMat]=getControlBounds(tVal,xt1tMat);
            %
            qVec=xt1tMat*qVec;
            qMat=xt1tMat*qMat*transpose(xt1tMat);
            xVec=xt1tMat*xVec;
            %
            ml1Vec = sqrt(dot(xVec-qVec, qMat \ (xVec-qVec)));
            l0Vec = (qMat \ (xVec-qVec)) / ml1Vec;
            if (dot(-l0Vec,xVec) - dot(-l0Vec,qVec) > ...
                    dot(l0Vec,xVec) - dot(l0Vec,qVec))
                l0Vec=-l0Vec;
            end
            l0Vec = l0Vec / norm(l0Vec);
            %
            resVec = pVec - (pMat*l0Vec) / sqrt(l0Vec'*pMat*l0Vec);
            resVec = xt1tMat \ resVec;
            %
            function [pVec,pMat]=getControlBounds(curControlTime,xt1tMat)
                %
                evalTime=self.t1-curControlTime+self.t0;
                %
                bpVec=-self.probDynamicsObj.getBptDynamics.evaluate(evalTime);
                bpbMat=...
                    self.probDynamicsObj.getBPBTransDynamics.evaluate(evalTime);
                %
                pVec=xt1tMat*bpVec;
                pMat=xt1tMat*bpbMat*transpose(xt1tMat);
            end
        end
        %
    end
end