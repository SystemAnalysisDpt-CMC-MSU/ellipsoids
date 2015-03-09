classdef SuiteOde45Reg < gras.ode.test.mlunit.SuiteBasic
    methods
        function self = SuiteOde45Reg(varargin)
            self = self@gras.ode.test.mlunit.SuiteBasic(varargin{:});
        end
        %
        function self = set_up_param(self,varargin)
            self.odeSolver = varargin{1};
            self.odeSolverNonReg = varargin{2};
        end
        
        function self = testInterp(self)
            function [isStrictViolVec,yRegMat]=fRegDummy(~,yMat)
                isStrictViolVec=false(1,size(yMat,2));
                yRegMat=yMat;
            end
            check(7);
            check(20);
            check(100);
            function check(nPoints)
                initVec=[0 1 2 3];
                ABS_TOL=1e-8;
                odePropList={'NormControl','on','RelTol',ABS_TOL,...
                    'AbsTol',ABS_TOL};
                %%
                function compare(yMat,yyMat,yRegMat,yyRegMat)
                    COMPARE_TOL = 1e-14;
                    [isEqual,~,~,~,~] = modgen.common.absrelcompare(...
                        yMat,yyMat,COMPARE_TOL,COMPARE_TOL,@norm);
                    mlunitext.assert_equals(true,isEqual,...
                        'matrix yMat and yyMat are not equal')
                    [isEqual,~,~,~,~] = modgen.common.absrelcompare(...
                        yRegMat,yyRegMat,COMPARE_TOL,COMPARE_TOL,@norm);
                    mlunitext.assert_equals(true,isEqual,...
                        'matrix yRegMat and yyRegMat are not equal');
                end
                function interpObj = helpForComparision(tVaryVec,tspanVec)
                    [~,yMat,yRegMat,interpObj]=...
                     feval(self.odeSolver, @(t,y)cos(y),@fRegDummy,...
                     tVaryVec,initVec,odePropList{:});
                    [~,yyMat,yyRegMat] = interpObj.evaluate(tspanVec);
                end
                
                 tBeginVec = linspace(0,1,nPoints);
                 tBeginVec(2) = 1e-6;
                 interpObj = helpForComparision(tBeginVec,tBeginVec);
                 compare(yMat,yyMat,yRegMat,yyRegMat);
                 
                tVaryVec = tBeginVec.^2;
                tVaryVec(2) = tBeginVec(2);
                helpForComparision(tVaryVec,tVaryVec);
                compare(yMat,yyMat,yRegMat,yyRegMat);
                
                tVaryVec = 0:0.001:1;
                tVaryVec(2) = tBeginVec(2);
                threshold = 0.3333;
                tspan = tVaryVec(tVaryVec >= threshold);
                helpForComparision(tVaryVec,tspan);
                compare(yMat(tVaryVec >= threshold,:),yyMat,...
                    yRegMat(tVaryVec >= threshold,:),yyRegMat);
               
                tVaryVec = linspace(0,1,2*nPoints + 1);
                tVaryVec(2) = tBeginVec(2);
                helpForComparision(tVaryVec,tVaryVec);
                compare(yMat,yyMat,yRegMat,yyRegMat);
             
                tVaryVec = sin(pi*tBeginVec/2);
                tVaryVec(2) = tBeginVec(2);
                helpForComparision(tVaryVec,tVaryVec);
                compare(yMat,yyMat,yRegMat,yyRegMat);
                
                [tVaryVec,yMat,yRegMat,~]=...
                    feval(self.odeSolver, @(t,y)cos(y),@fRegDummy,...
                    [0 1],initVec,...
                    odePropList{:});
                [~,yyMat,yyRegMat] = interpObj.evaluate(tVaryVec');
                COMPARE_TOL = 1e-8;
                [isEqual,~,~,~,~] = modgen.common.absrelcompare(yMat,...
                    yyMat,COMPARE_TOL,COMPARE_TOL,@norm);
                mlunitext.assert_equals(true,isEqual,...
                    'matrix yMat and yyMat are not equal')
                [isEqual,~,~,~,~] = modgen.common.absrelcompare(yRegMat,...
                    yyRegMat,COMPARE_TOL,COMPARE_TOL,@norm);
                mlunitext.assert_equals(true,isEqual,...
                    'matrix yRegMat and yyRegMat are not equal');
                
            end
        end
        
        function self=testMatrixSysODERegInterpSolver(self)
            odePropList={'NormControl','on','RelTol',...
                0.001,'AbsTol',0.0001};
            sizeVecList={[3 3],[2 2],[2 4 1],[2 1]};
            nTimePoints=100;
            timeVec=linspace(0,1,nTimePoints);
            initValList=cellfun(@(x)prod(x).*ones(x),sizeVecList,...
                'UniformOutput',false);
            indEqNoDyn=2;
            indFuncEqNoDyn=1;
            fSolver=str2func(self.odeSolverNonReg);
            check(@fSimpleDerivFunc);
            fSolver=str2func(self.odeSolver);
            checkInterp({@fSimpleDerivFunc,@fAdvRegFunc},...
                'outArgStartIndVec',[1 2]);
            
            %
            function checkResults(resTimeVec,resList,nFuncs)
                import gras.ode.test.mlunit.SuiteBasic;
                nEqs=length(sizeVecList);                
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
            function checkInterpResults(resTimeVec,resList,...
                    resInterpTimeVec,resInterpList,nFuncs)
                import gras.ode.test.mlunit.SuiteBasic;
                nEqs=length(sizeVecList);                
                for iFunc=1:nFuncs
                    indShift=(iFunc-1)*nEqs;
                    for iEq=1:nEqs
                        mlunitext.assert_equals(true,...
                            isequal(resList(indShift + iEq),...
                            resInterpList(indShift + iEq)));
                    end
                end
                mlunitext.assert_equals(true,isequal(resTimeVec,...
                    resInterpTimeVec));

            end
            %
            function resList=check(fDerivFuncList,varargin)               
                nFuncs=length(fDerivFuncList);
                solveObj=gras.ode.MatrixSysODESolver(sizeVecList,...
                    @(varargin)fSolver(varargin{:},...
                    odeset(odePropList{:})),varargin{:});
                resList=cell(1,length(sizeVecList)*...
                    length(fDerivFuncList));
                [resTimeVec,resList{:}]=solveObj.solve(...
                    fDerivFuncList,timeVec,initValList{:});
                checkResults(resTimeVec,resList,nFuncs);                
            end
            %
            function resList=checkInterp(fDerivFuncList,varargin)
                nFuncs=length(fDerivFuncList);
                solveObj=gras.ode.MatrixSysODERegInterpSolver(...
                    sizeVecList,@(varargin)fSolver(varargin{:},...
                    odeset(odePropList{:})),varargin{:});
                resList=cell(1,length(sizeVecList)*...
                    length(fDerivFuncList));
                resInterpList = resList;
                [resTimeVec,resList{:},...
                    objMatrixSysReshapeOde45RegInterp]=solveObj.solve(...
                    fDerivFuncList,timeVec,initValList{:});
                checkResults(resTimeVec,resList,nFuncs);
                [resInterpTimeVec,resInterpList{:}] = ...
                    objMatrixSysReshapeOde45RegInterp.evaluate(timeVec);
                checkResults(resInterpTimeVec.',resInterpList,nFuncs);
                checkInterpResults(resTimeVec,resList,...
                    resInterpTimeVec.',resInterpList,nFuncs);

                
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
    end
end