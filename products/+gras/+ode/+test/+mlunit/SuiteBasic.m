classdef SuiteBasic < mlunitext.test_case
    properties (Access=private)
        odeSolver;
        odeSolverNonReg;
    end
    methods (Static,Access=private)
        function y=fDeriv(t,y)
            aMat=[sin(t),cos(t),0;cos(t),0,1;0,0,1];
            y=aMat*y;
        end
    end
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self,varargin)
            self.odeSolver = varargin{1};
            self.odeSolverNonReg = varargin{2};
        end
        function self=testStrict(self)
            tStart=0;
            aTol=0.00001;
            regAbsTol=1e-8;
            regMaxStepTol=0.05;
            relTol=0.0001;
            nMaxRegSteps=10;
            tEnd=4*pi;
            initVec=[0.5 1 2 3];
            odePropList={'NormControl','on','RelTol',relTol,'AbsTol',aTol};
            odeRegPropList={'regAbsTol',regAbsTol,'regMaxStepTol',regMaxStepTol,...
                'nMaxRegSteps',nMaxRegSteps};
            %
            fOdeDerivReg=@fOdeDerivCpl;
            fReg=@fRegPos;
            self.runAndCheckError(@run,'IntegrationTolNotMet');
            function run()
            s=warning('off','MATLAB:ode45:IntegrationTolNotMet');
            try
                [tVec,yMat,dyRegMat]=...
                    feval(self.odeSolver,...
                    @(t,y)fOdeDerivReg(t,y,fReg),...
                    @(t,y)fReg(y),...
                    [tStart,tEnd],initVec,odeset(odePropList{:}),...
                    odeRegPropList{:});
            catch meObj;
                warning(s);
                rethrow(meObj);
            end
            %
            warning(s);
            end
            %
            function [isStrict,y]=fRegPos(y)
                isStrict=y(1,:)<0;
                if any(isStrict)
                    y=nan(size(y));
                end
            end
            function yp=fOdeDerivCpl(t,y,fReg)
                import modgen.common.throwerror;
                isStrict=fReg(y);
                if isStrict
                    throwerror('wrongState','strict constraint is violated');
                end
                yp=-ones(size(y));
            end
        end
        function self=testPosSame(self)
            import modgen.common.throwerror;
            import gras.ode.ode45reg;
            import gras.ode.ode113reg;
            %
            tStart=0;
            tEnd=0.65;
            aTol=0.00001;
            regAbsTol=1e-8;
            regMaxStepTol=0.05;
            relTol=0.0001;
            nMaxRegSteps=10;
            %
            checkMaster();
            tEnd=4*pi;
            checkMaster();
            %
            regMaxStepTol=0.005;
            aTol=0.0001;
            relTol=0.0001;
            regAbsTol=1e-6;
            checkMaster(0.025);
            %
            function checkMaster(maxTol)
                if nargin==0
                    maxTol=regMaxStepTol;
                end
                odePropList={'NormControl','on','RelTol',relTol,'AbsTol',aTol};
                odeRegPropList={'regAbsTol',regAbsTol,'regMaxStepTol',regMaxStepTol,...
                    'nMaxRegSteps',nMaxRegSteps};
                %fOdeDeriv=@(t,y)sin(y+1)*cos(t)*cos(2.5*(t));
                fOdeDerivReg=@fOdeDerivCpl;
                fOdeDeriv=@(t,y)fOdeDerivReg(t,y,@fRegDummy);
                check(20);
                %
                %fOdeDeriv=@(t,y)cos(t).*[1;1;1;1];
                fOdeDerivReg=@fOdeDerivSimple;
                fOdeDeriv=@(t,y)fOdeDerivReg(t,y,@fRegDummy);
                check(20);
                function [isStrict,y]=fRegDummy(y)
                    isStrict=false;
                end
                function yp=fOdeDerivSimple(t,y,fReg)
                    import modgen.common.throwerror;
                    isStrict=fReg(y);
                    if isStrict
                        throwerror('wrongState','strict constraint is violated');
                    end
                    yp=cos(t).*[1;1;1;1];
                end
                function yp=fOdeDerivCpl(t,y,fReg)
                    import modgen.common.throwerror;
                    isStrict=fReg(y);
                    if isStrict
                        throwerror('wrongState','strict constraint is violated');
                    end
                    yp=sin(y+1)*cos(t)*cos(2.5*(t));
                end
                function check(nPoints)
                    tsVec=transpose(linspace(tStart,tEnd,nPoints));
                    tsSpanVec=[tStart,tEnd];
                    initVec=[0 1 2 3];
                    checkInt(tsSpanVec,'Refine',3);
                    tsUniqVec=unique([checkInt(tsSpanVec);tsVec]);
                    checkInt(tsUniqVec);
                    checkInt(tsUniqVec,'Refine',1);
                    %
                    checkInt(tsSpanVec,'Refine',1);
                    %
                    function tUniqVec=checkInt(tsVec,varargin)
                        odePropList=[odePropList,varargin{:}];
                        %
                        [~,yNotRegMat]=ode113(fOdeDeriv,tsVec,initVec,...
                            odeset(odePropList{:}));
                        %
                        fReg=@(y)fOdeRegPos(y,1);
                        [ttVec,yyMat]=ode45(fOdeDeriv,tsVec,initVec,...
                            odeset(odePropList{:},'nonNegative',1));
                        [tVec,yMat,dyRegMat]=...
                            feval(self.odeSolver, @(t,y)fOdeDerivReg(t,y,fReg),...
                            @(t,y)fReg(y),...
                            tsVec,initVec,odeset(odePropList{:}),...
                            odeRegPropList{:});
                        
                        mlunitext.assert_equals(true,all(yMat(:,1)>=0));
                        
                        tPosVec=tVec;
                        ttPosVec=ttVec;
                        isCheckReg=any(yNotRegMat(:,1)<0);
                        cmp();
                        %
                        fReg=@(y)fOdeRegNeg(y,1);
                        fOdeRevDeriv=@(t,y)-fOdeDeriv(t,-y);
                        [ttVec,yyMat]=feval(self.odeSolverNonReg, fOdeRevDeriv,tsVec,-initVec,...
                            odeset(odePropList{:},'nonNegative',1));
                        yyMat=-yyMat;
                        [tVec,yMat,dyRegMat]=...
                            feval(self.odeSolver, @(t,y)fOdeDerivReg(t,y,fReg),...
                            @(t,y)fReg(y),...
                            tsVec,initVec,odeset(odePropList{:}),...
                            odeRegPropList{:});
                        mlunitext.assert_equals(true,all(yMat(:,1)<=0));
                        tNegVec=tVec;
                        ttNegVec=ttVec;
                        isCheckReg=any(yNotRegMat(:,1)>0);
                        cmp();
                        tUniqVec=unique([tPosVec;ttPosVec;tNegVec;ttNegVec]);
                        %
                        function cmp()
                            mlunitext.assert_equals(true,...
                                all(all(dyRegMat(:,2:end)==0)));
                            isOk=any(any(abs(dyRegMat(:,1))>0));
                            mlunitext.assert_equals(isCheckReg,isOk);
                            if length(tsVec)>2
                                actualTol=max(abs(yMat(:)-yyMat(:)));
                                isOk=actualTol<=maxTol;
                                mlunitext.assert_equals(true,isOk);
                                mlunitext.assert_equals(true,isequal(tVec,ttVec));
                            end
                        end
                    end
                end
            end
            function [isStrictViolVec,yRegMat]=fOdeRegNeg(yMat,indNonPositive)
                isStrictViolVec=any(yMat(indNonPositive,:)>0.01,1);
                yRegMat=yMat;
                yRegMat(indNonPositive,:)=min(yRegMat(indNonPositive,:),0);
            end
            function [isStrictViolVec,yRegMat]=fOdeRegPos(yMat,indNonNegative)
                isStrictViolVec=any(yMat(indNonNegative,:)<-0.01,1);
                yRegMat=yMat;
                yRegMat(indNonNegative,:)=max(yRegMat(indNonNegative,:),0);
            end
        end
        function self=testReg(self)
            function f=fDeriv(t,y)
                f=zeros(size(y));
            end
            function [isStrictViolVec,yRegMat]=fReg(~,yMat)
                isStrictViolVec=false(1,size(yMat,2));
                yRegMat=max(yMat,0);
            end
            function [isStrictViolVec,yRegMat]=fRegDummy(~,yMat)
                isStrictViolVec=false(1,size(yMat,2));
                yRegMat=yMat;
            end
            check(7);
            check(20);
            check(100);
            function check(nPoints)
                tStart=0;
                tEnd=4*pi;
                tVec=transpose(linspace(tStart,tEnd,nPoints));
                tSpanVec=[tStart,tEnd];
                nTimePoints=length(tVec);
                initVec=[0 1 2 3];
                nEqs=length(initVec);
                regMaxStepTol=0.001;
                absTol=0.001;
                odeRegPropList={'regMaxStepTol',regMaxStepTol};
                odePropList={'NormControl','on','RelTol',absTol,'AbsTol',absTol};
                %%
                %
                %check that for the positive solution ode113reg works in the same
                %way as plain ode45
                [~,yMat,mMat]=...
                    feval(self.odeSolver, @(t,y)cos(y),@fRegDummy,tVec,initVec,...
                    odePropList{:});
                [~,yyMat]=feval(self.odeSolverNonReg, @(t,y)cos(y),tVec,initVec,...
                    odeset(odePropList{:}));
                mlunitext.assert_equals(true,isequal(yMat,yyMat));
                mlunitext.assert_equals(true,all(mMat(:)==0));
                %% check that zero derivative doesn't change initial value
                [ttVec,yMat,mMat]=...
                    feval(self.odeSolver, @fDeriv,@fReg,tVec,initVec,...
                    odePropList{:});
                [~,yyMat]=feval(self.odeSolverNonReg, @(t,y)cos(y),tVec,initVec,...
                    odeset(odePropList{:}));
                isOk=isequal(yMat,repmat(initVec,nTimePoints,1));
                mlunitext.assert_equals(true,isOk);
                isOk=all(mMat(:)==0);
                mlunitext.assert_equals(true,isOk);
                mlunitext.assert_equals(true,all(tVec==ttVec));
                %
                checkReg(tSpanVec);
                checkReg(tVec);
                function checkReg(tSpanVec)
                    fDeriv=@(t,y)cos(t).*[1;1;1;1];
                    %% check the way regularization works correctly when tVec is specified
                    tRegVec=feval(self.odeSolver, fDeriv,...
                        @fReg,tSpanVec,initVec,odePropList{:},'Refine',1,...
                        odeRegPropList{:});
                    %
                    [tNotRegVec,~]=feval(self.odeSolverNonReg, fDeriv,...
                        tSpanVec,initVec,odeset(odePropList{:},'Refine',1));
                    %
                    tVec=union(tRegVec,tNotRegVec).';
                    %
                    [tRegVec,yRegMat,mMat]=...
                        feval(self.odeSolver, fDeriv,...
                        @fReg,tVec,initVec,odePropList{:},...
                        odeRegPropList{:});
                    %
                    [tNotRegVec,ynRegMat]=...
                        ode45(fDeriv,...
                        tVec,initVec,odeset(odePropList{:}));
                    mlunitext.assert_equals(true,isequal(tRegVec,tNotRegVec));
                    muVec=[0;cumsum(diff(tRegVec).*mMat(2:end,1))];
                    yNotRegVec=ynRegMat(:,1);
                    yRegRestoredVec=muVec+yNotRegVec;
                    yRegVec=yRegMat(:,1);
                    isOk=max(abs(yRegRestoredVec-yRegVec))<=1.2*absTol;
                    mlunitext.assert_equals(true,isOk);
                end
            end
            
        end
        function self=testMatrixSysODESolver(self)
            odePropList={'NormControl','on','RelTol',0.001,'AbsTol',0.0001};
            sizeVecList={[3 3],[2 2],[2 4 1],[2 1]};
            nTimePoints=100;
            timeVec=linspace(0,1,nTimePoints);
            initValList=cellfun(@(x)prod(x).*ones(x),sizeVecList,...
                'UniformOutput',false);
            indEqNoDyn=2;
            indFuncEqNoDyn=1;
            fSolver=str2func(self.odeSolver);
            check({@fSimpleDerivFunc,@fAdvRegFunc},'outArgStartIndVec',[1 2]);
            fSolver=str2func(self.odeSolverNonReg);
            check(@fSimpleDerivFunc);
            %
            function resList=check(fDerivFuncList,varargin)
                import gras.ode.test.mlunit.SuiteBasic;
                solveObj=gras.ode.MatrixSysODESolver(sizeVecList,...
                    @(varargin)fSolver(varargin{:},odeset(odePropList{:})),...
                    varargin{:});
                resList=cell(1,length(sizeVecList)*...
                    length(fDerivFuncList));
                %
                nEqs=length(sizeVecList);
                [resTimeVec,resList{:}]=solveObj.solve(...
                    fDerivFuncList,timeVec,initValList{:});
                nFuncs=length(fDerivFuncList);
                for iFunc=1:nFuncs
                    indShift=(iFunc-1)*nEqs;
                    for iEq=1:nEqs
                        indEq=indShift+iEq;
                        mlunitext.assert_equals(true,...
                            isequal(size(resList{iEq}),...
                            [sizeVecList{iEq},nTimePoints]));
                        if iEq==indEqNoDyn&&iFunc==indFuncEqNoDyn
                            isOk=isequal(resList{indEq},...
                                repmat(initValList{iEq},...
                                [ones(1,ndims(resList{indEq})-1),...
                                nTimePoints]));
                            mlunitext.assert_equals(true,isOk);
                        end
                    end
                end
                mlunitext.assert_equals(true,isequal(resTimeVec,timeVec));
            end
            %
            function varargout=fAdvRegFunc(~,varargin)
                nEqs=length(varargin);
                varargout{1}=false;
                for iEq=1:nEqs
                    varargout{iEq+1}=max(varargin{iEq},0);
                end
            end
            %
            function varargout=fSimpleDerivFunc(t,varargin)
                nEqs=length(varargin);
                for iEq=1:nEqs
                    if iEq==indEqNoDyn
                        varargout{iEq}=zeros(size(varargin{iEq}));
                    else
                        varargout{iEq}=sin(t).*cos(varargin{iEq}).*iEq;
                    end
                end
            end
        end
        %
        function self=testMatrixODESolver(self)
            
            odePropList = {@ode45, 'NormControl', 'on', 'RelTol', ...
                0.001, 'AbsTol', 0.0001};
            %
            nTimePoints = 1;
            timeVec = 0;
            sizeVec = [3 3];
            initVal = eye(sizeVec);
            check();
            timeVec = 1;
            check();
            %
            timeVec = 0;
            sizeVec = 3;
            initVal = ones(3, 1);
            check();
            timeVec = 1;
            check();
            %
            nTimePoints = 2;
            timeVec = [1 1];
            sizeVec = [3 3];
            initVal = eye(sizeVec);
            check();
            sizeVec = 3;
            initVal = ones(3, 1);
            check();
            %
            nTimePoints = 100;
            timeVec = linspace(0, 1, nTimePoints);
            sizeVec = [3 3];
            initVal = eye(sizeVec);
            check();
            sizeVec = 3;
            initVal = ones(3, 1);
            check();
            function check()
                import gras.ode.test.mlunit.SuiteBasic;
                solveObj = gras.ode.MatrixODESolver(sizeVec, ...
                    odePropList{:});
                [resTimeVec, resArray] = solveObj.solve(...
                    @SuiteBasic.fDeriv, timeVec, initVal);
                if (nTimePoints > 1) && (timeVec(1) ~= timeVec(end))
                    mlunitext.assert_equals(true, isequal(resTimeVec, ...
                        timeVec));
                    mlunitext.assert_equals(true, isequal(size(resArray), ...
                        [sizeVec, nTimePoints]));
                else
                    mlunitext.assert_equals(true, isequal(resTimeVec, ...
                        timeVec(1)));
                    mlunitext.assert_equals(true, isequal(resArray, initVal));
                end
            end
        end
    end
end