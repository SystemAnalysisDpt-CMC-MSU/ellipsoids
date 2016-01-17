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
        
        function [tVec,yMat,dyRegMat,interpObj] = odeSolve(self, varargin)
            [tVec,yMat,dyRegMat,interpObj] = feval(...
                self.odeSolver, varargin{:});
        end
        
        function self = testInverseTspan(self)            
            ABS_TOL=1e-8;
            odePropList={'NormControl','on', 'RelTol',ABS_TOL,...
                    'AbsTol',ABS_TOL};
            
            check(@(t,y) cos(y), [0 1], 0);
            check(@(t,y) sin(y), linspace(0, 1, 9), 0);
            check(@(t, y) t*cos(y), [0, 1], zeros(1, 10));
            check(@(t, y) t*sin(y), linspace(0, 1, 7), ones(1, 10));
            
            function [isStrictViolVec,yRegMat] = fRegDummy(~,yMat)
                isStrictViolVec=false(1,size(yMat,2));
            	yRegMat=yMat;
            end
                
            function check(fOdeDeriv1, t1Vec, initVec)            
                [tOut1Vec, y1Mat, yr1Mat, int1Obj] = self.odeSolve(...
                    fOdeDeriv1, @fRegDummy, t1Vec, initVec,odePropList{:});
                
                t0 = t1Vec(end);
                fOdeDeriv2 = @(t, y) -fOdeDeriv1(t0 - t, y);
                t2Vec = t0 - t1Vec;
                [tOut2Vec, y2Mat, yr2Mat, int2Obj] = self.odeSolve(...
                    fOdeDeriv2, @fRegDummy, t2Vec, initVec,odePropList{:});
                
                %check output
                checkSolution(y1Mat, y2Mat, yr1Mat, yr2Mat,...
                    tOut1Vec, t0 - tOut2Vec);
                
                %check interpolator
                if numel(t1Vec) <= 2
                    t1Vec = linspace(t1Vec(1), t1Vec(end), 9);
                    t2Vec = t0 - t1Vec;
                end
                [tOut1Vec, y1Mat, yr1Mat] = int1Obj.evaluate(t1Vec);
                [tOut2Vec, y2Mat, yr2Mat] = int2Obj.evaluate(t2Vec);
                checkSolution(y1Mat, y2Mat, yr1Mat, yr2Mat,...
                    tOut1Vec, t0 - tOut2Vec);
            end
            
            function checkSolution(y1Mat, y2Mat,...
                    y1RegMat, y2RegMat, t1Vec, t2Vec, CMP_TOL)
                
                if nargin < 7
                    CMP_TOL = 1e-8;
                end
                
                checkMat(y1Mat, y2Mat, CMP_TOL,...
                    'matrix y1Mat and y2Mat are not equal');
                checkMat(y1RegMat, y2RegMat, CMP_TOL,...
                    'matrix y1RegMat and y2RegMat are not equal');
                checkMat(t1Vec, t2Vec, CMP_TOL,...
                    'time vectors t1Vec and t2Vec are not equal');
            end
            
            function checkMat(srcMat, refMat, CMP_TOL, msg)
                mlunitext.assert_equals(size(srcMat), size(refMat), msg);
                [isEqual,~,~,~,~] = modgen.common.absrelcompare(...
                    srcMat, refMat, CMP_TOL, CMP_TOL, @norm);
                mlunitext.assert_equals(true, isEqual, msg);
            end
        end
    end
end