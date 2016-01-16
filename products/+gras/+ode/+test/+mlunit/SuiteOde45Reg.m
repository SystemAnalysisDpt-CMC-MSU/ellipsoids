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
        
        function self = testInverseTspan(self)
            %TODO: common compare and fRegDummy function for both test
            
            function [isStrictViolVec,yRegMat] = fRegDummy(~,yMat)
            	isStrictViolVec=false(1,size(yMat,2));
                yRegMat=yMat;
            end
            
            function compare(yMat,yyMat,yRegMat,yyRegMat, t1, t2, COMPARE_TOL)
                if ~exist('COMPARE_TOL', 'var')
                    COMPARE_TOL = 1e-8;
                end
                
                [isEqual,~,~,~,~] = modgen.common.absrelcompare(...
                    yMat,yyMat,COMPARE_TOL,COMPARE_TOL,@norm);
                mlunitext.assert_equals(true,isEqual,...
                    'matrix yMat and yyMat are not equal')
                [isEqual,~,~,~,~] = modgen.common.absrelcompare(...
                    yRegMat,yyRegMat,COMPARE_TOL,COMPARE_TOL,@norm);
                mlunitext.assert_equals(true,isEqual,...
                    'matrix yRegMat and yyRegMat are not equal');
                [isEqual,~,~,~,~] = modgen.common.absrelcompare(...
                    t1,t2,COMPARE_TOL,COMPARE_TOL,@norm);
                mlunitext.assert_equals(true,isEqual,...
                    'time vectors t1 and t2 are not equal');
            end
            
            ABS_TOL=1e-8;
            odePropList={'NormControl','on','RelTol',ABS_TOL,...
                    'AbsTol',ABS_TOL};
            
            function check(fOdeDeriv1, tspan1, y0Vec)
                [t1, y1, yr1, int1] = feval(self.odeSolver, fOdeDeriv1,...
                                     @fRegDummy, tspan1, y0Vec,...
                                     odePropList{:});
                
                t0 = tspan1(end);
                fOdeDeriv2 = @(t, y) -fOdeDeriv1(t0 - t, y);
                tspan2 = t0 - tspan1;
                [t2, y2, yr2, int2] = feval(self.odeSolver, fOdeDeriv2,...
                                     @fRegDummy, tspan2, y0Vec,...
                                     odePropList{:});
                
                %check output
                compare(y1, y2, yr1, yr2, t1, t0 - t2);
                
                %check interpolator
                if numel(tspan1) <= 2
                    tspan1 = linspace(tspan1(1), tspan1(end), 9);
                    tspan2 = t0 - tspan1;
                end
                [t1, y1, yr1] = int1.evaluate(tspan1);
                [t2, y2, yr2] = int2.evaluate(tspan2);
                compare(y1, y2, yr1, yr2, t1, t0 - t2);
            end
            
            check(@(t,y) cos(y), [0 1], 0);
            check(@(t,y) sin(y), linspace(0, 1, 9), 0);
            check(@(t, y) t*cos(y), [0, 1], zeros(1, 10));
            check(@(t, y) t*sin(y), linspace(0, 1, 7), ones(1, 10));
        end
    end
end