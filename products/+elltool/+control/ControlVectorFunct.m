classdef ControlVectorFunct < elltool.control.IControlVectFunction&...
        modgen.common.obj.HandleObjectCloner
    %
    properties (Access=private)
        properEllTube
        probDynamicsList
        goodDirSetList
        downScaleKoeff
        bigQInterpObj
        aInterpObj
    end
    %
    methods
        function self=ControlVectorFunct(properEllTube,...
                probDynamicsList,goodDirSetList,inDownScaleKoeff)
            % CONTROLVECTORFUNCT is a class providing evaluation of control
            % synthesis for predetermined position (t,x)
            %
            % Input:
            %   regular:
            %       properEllTube: gras.ellapx.smartdb.rels.EllTube[1,1]
            %           - an ellipsoidal tube object that is used for
            %           contol synthesis constructing
            %
            %       probDynamicsList:
            %           gras.ellapx.lreachplain.probdyn.LReachProblemLTIDynamics[1,]
            %           - cellArray providing information about system's
            %           dynamics
            %
            %       goodDirSetList:
            %           gras.ellapx.lreachplain.GoodDirsContinuousLTI[1,]
            %           - cellArray providing information about
            %           'good directions'
            %
            %       inDownScaleKoeff: scaling coefficient for internal
            %           ellipsoid tube approximation
            %
            % $Author: Komarov Yuri <ykomarov94@gmail.com> $
            % $Date: 2015-30-10 $
            %
            if properEllTube.getNTuples()~=1
                modgen.common.throwerror(['properEllTube must have'...
                    'only 1 tuple']);
            end
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.downScaleKoeff=inDownScaleKoeff;
            timeSpanVec=self.properEllTube.timeVec{1};
            bigQArray=self.properEllTube.QArray{1}(:,:,:);
            self.bigQInterpObj=...
                gras.mat.interp.MatrixInterpolantFactory.createInstance(...
                'posdef_chol',bigQArray,timeSpanVec);
            aMat=self.properEllTube.aMat{1};
            self.aInterpObj=...
                gras.mat.interp.MatrixInterpolantFactory.createInstance(...
                'column',aMat,timeSpanVec);
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
            indSwitch=getIndexOfSwitchTime(tVal);
            t0=getBeginOfSwitchTimeSpan(indSwitch);
            t1=getEndOfSwitchTimeSpan(indSwitch);
            curProbDynObj=self.probDynamicsList{indSwitch};
            curGoodDirSetObj=self.goodDirSetList{indSwitch};
            %
            ellTubeTimeVec=self.properEllTube.timeVec{1};
            indTime=sum(ellTubeTimeVec <= tVal);
            % TODO: check if indTime == 0
            if ellTubeTimeVec(indTime) < tVal
                qVec = self.aInterpObj.evaluate(tVal);
                qMat=self.bigQInterpObj.evaluate(tVal);
            else %ellTubeTimeVec(indTime) == curControlTime
                qVec=self.properEllTube.aMat{1}(:,indTime);
                qMat=self.properEllTube.QArray{1}(:,:,indTime);
            end
            %
            xstTransMat=curGoodDirSetObj.getXstTransDynamics();
            % X(t,t_0) =
            %   ( xstTransMat.evaluate(t)\xstTransMat.evaluate(t_0) ).'
            xt1tMat=transpose(xstTransMat.evaluate(t1)\...
                xstTransMat.evaluate(tVal));
            %
            [pVec,pMat]=getControlBounds(t0,t1,tVal,curProbDynObj,xt1tMat);
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
            function indSwitch=getIndexOfSwitchTime(tVal)
                % time is backward, so if t_0 < t_1 < ... < t_{n-1} < t_{n}
                % {1}->[t_{n-1},t_{n}], {2}->[t_{n_2},t_{n-1}, ... ,
                % {n}->[t_{0}, t_{1}], where {i} is index in probDynamicsList
                indSwitchesVec=length(self.probDynamicsList):-1:1;
                timeSwitchesVec=arrayfun(...     % timeSwitchesVec(i) = t_{n-i}
                    @getBeginOfSwitchTimeSpan,indSwitchesVec);
               % currently t_{n} is missing in partion - we have to append it:
                indSwitchesVec=horzcat(indSwitchesVec,1);
                timeSwitchesVec=...
                    horzcat(timeSwitchesVec,getEndOfSwitchTimeSpan(1));
                if ~issorted(timeSwitchesVec)
                    modgen.common.throwerror('tSwitchesVec should be sorted!');
                end
                if any(isnan(timeSwitchesVec))
                    modgen.common.throwerror('tVal should belong to timespan!');
                end
                indSwitch=interp1(timeSwitchesVec,indSwitchesVec,tVal,'prev');
            end
            %
            function tSwitch=getBeginOfSwitchTimeSpan(indSwitch)
                % probDynamicsList{indSwitch}{indTube} returns dynamics for
                %     indSwitch time period and indTube tube
                probTimeVec=self.probDynamicsList{indSwitch}.getTimeVec();
                tSwitch=probTimeVec(1);
            end
            %
            function tSwitch=getEndOfSwitchTimeSpan(indSwitch)
                probTimeVec=self.probDynamicsList{indSwitch}.getTimeVec();
                tSwitch=probTimeVec(end);
            end
            %
            function [pVec,pMat]=getControlBounds(t0,t1,...
                    curControlTime,curProbDynObj,xt1tMat)
                %
                evalTime=t1-curControlTime+t0;
                %
                bpVec=-curProbDynObj.getBptDynamics.evaluate(evalTime);
                bpbMat=...
                    curProbDynObj.getBPBTransDynamics.evaluate(evalTime);
                %
                pVec=xt1tMat*bpVec;
                pMat=xt1tMat*bpbMat*transpose(xt1tMat);
            end
        end
        %
    end
end