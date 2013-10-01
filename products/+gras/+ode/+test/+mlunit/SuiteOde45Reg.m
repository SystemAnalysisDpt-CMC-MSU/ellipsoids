classdef SuiteOde45Reg < mlunitext.test_case
    properties (Access=private)
        odeSolver;
    end
    methods
        function self = SuiteOde45Reg(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self,varargin)
            self.odeSolver = varargin{1};
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
                absTol=1e-8;
                odePropList={'NormControl','on','RelTol',absTol,'AbsTol',absTol};
                %%
                abstol = 1e-14;
                function compare(yMat,yyMat,yRegMat,yyRegMat,abstol)
                    [isEqual,~,~,~,~] = modgen.common.absrelcompare(yMat,yyMat,abstol,abstol,@norm);
                    mlunitext.assert_equals(true,isEqual,'matrix yMat and yyMat are not equal')
                    [isEqual,~,~,~,~] = modgen.common.absrelcompare(yRegMat,yyRegMat,abstol,abstol,@norm);
                    mlunitext.assert_equals(true,isEqual,'matrix yRegMat and yyRegMat are not equal');
                end
                %
                %check that for the positive solution ode113reg works in the same
                %way as plain ode45
                 tBeginVec = linspace(0,1,nPoints);
                 tBeginVec(2) = 1e-6;
                 [~,yMat,yRegMat,interpObj]=...
                     feval(self.odeSolver, @(t,y)cos(y),@fRegDummy,tBeginVec,initVec,...
                     odePropList{:});
                 [~,yyMat,yyRegMat] = interpObj.evaluate(tBeginVec);
                 compare(yMat,yyMat,yRegMat,yyRegMat,abstol);
                 
                tVaryVec = tBeginVec.^2;
                tVaryVec(2) = tBeginVec(2);
                [~,yMat,yRegMat,~]=...
                    feval(self.odeSolver, @(t,y)cos(y),@fRegDummy,tVaryVec,initVec,...
                    odePropList{:});
                [~,yyMat,yyRegMat] = interpObj.evaluate(tVaryVec);
                compare(yMat,yyMat,yRegMat,yyRegMat,abstol);
                
                tVaryVec = 0:0.001:1;
                tVaryVec(2) = tBeginVec(2);
                threshold = 0.333;
                [~,yMat,yRegMat,~]=...
                    feval(self.odeSolver, @(t,y)cos(y),@fRegDummy,tVaryVec,initVec,...
                    odePropList{:});
                tspan = tVaryVec(tVaryVec >= threshold);
                [~,yyMat,yyRegMat] = interpObj.evaluate(tspan);
                compare(yMat(tVaryVec >= threshold,:),yyMat,yRegMat(tVaryVec >= threshold,:),yyRegMat,abstol);
               
                tVaryVec = linspace(0,1,2*nPoints + 1);
                tVaryVec(2) = tBeginVec(2);
                [~,yMat,yRegMat,~]=...
                    feval(self.odeSolver, @(t,y)cos(y),@fRegDummy,tVaryVec,initVec,...
                    odePropList{:});
                [~,yyMat,yyRegMat] = interpObj.evaluate(tVaryVec);
                compare(yMat,yyMat,yRegMat,yyRegMat,abstol);
             
                tVaryVec = sin(pi*tBeginVec/2);
                tVaryVec(2) = tBeginVec(2);
                [~,yMat,yRegMat,~]=...
                    feval(self.odeSolver, @(t,y)cos(y),@fRegDummy,tVaryVec,initVec,...
                    odePropList{:});
                [~,yyMat,yyRegMat] = interpObj.evaluate(tVaryVec);
                compare(yMat,yyMat,yRegMat,yyRegMat,abstol);
                
                [tVaryVec,yMat,yRegMat,~]=...
                    feval(self.odeSolver, @(t,y)cos(y),@fRegDummy,[0 1],initVec,...
                    odePropList{:});
                [~,yyMat,yyRegMat] = interpObj.evaluate(tVaryVec');
                abstol = 1e-8;
                compare(yMat,yyMat,yRegMat,yyRegMat,abstol);
            end
        end
    end
end