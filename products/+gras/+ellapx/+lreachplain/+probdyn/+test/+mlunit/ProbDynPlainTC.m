classdef ProbDynPlainTC < mlunitext.test_case
	properties (Access=protected)
        readObj
        pDynObj
        tVec
        absTol
        relTol
    end
    
    methods
        function self = ProbDynPlainTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function set_up_param(self, fDynConstr, fReader, relTol, absTol)
            self.readObj = fReader();
            params = self.readObj.getPlainParams();
            self.pDynObj = fDynConstr(params, {relTol absTol});
            
            self.tVec = self.pDynObj.getTimeVec();
            self.relTol = relTol;
            self.absTol = absTol;
        end
        
        function testFlatGetters(self)
            [~] = self.pDynObj.getProblemDef();
            
            tLimsVec = self.pDynObj.getTimeLimsVec();
            mlunitext.assert_equals(self.readObj.tLims, tLimsVec);
            t0 = self.pDynObj.gett0();
            t1 = self.pDynObj.gett1();
            mlunitext.assert_equals(tLimsVec(1), t0);
            mlunitext.assert_equals(tLimsVec(2), t1);
            tVec = self.pDynObj.getTimeVec();
            mlunitext.assert_equals(tVec(1), t0);
            mlunitext.assert_equals(tVec(end), t1);
            
            mlunitext.assert_equals(self.readObj.x0Mat,...
                self.pDynObj.getX0Mat());
            mlunitext.assert_equals(self.readObj.x0Vec,...
                self.pDynObj.getx0Vec());
            
            mlunitext.assert_equals(size(self.readObj.aCMat, 2),...
                self.pDynObj.getDimensionality());
        end
        
        function testDynGetters(self)
            import gras.mat.MatrixOperationsFactory;
            matOpFactory = MatrixOperationsFactory.create(self.tVec);
            
            At = matOpFactory.fromSymbMatrix(self.readObj.aCMat);
            self.checkMatFun(At, self.pDynObj.getAtDynamics());
            
            BPBTrans = matOpFactory.rSymbMultiply(...
                self.readObj.bCMat,...
                self.readObj.pCMat,...
                self.readObj.bCMat');
            self.checkMatFun(BPBTrans, self.pDynObj.getBPBTransDynamics());
            
            Bpt = matOpFactory.rSymbMultiply(...
                self.readObj.bCMat,...
                self.readObj.pCVec);
            self.checkMatFun(Bpt, self.pDynObj.getBptDynamics());
        end
        
        function test_xtDynamics(self)
            import gras.ellapx.common.*;
            import gras.mat.interp.MatrixInterpolantFactory;
            import gras.ode.MatrixODESolver;
            
            sysDim = size(self.readObj.aCMat, 1);
            odeArgList=self.getOdePropList();
            solverObj=MatrixODESolver(sysDim,@ode45,odeArgList{:});
            
            XtDerivFunc = @(t,x)self.pDynObj.getAtDynamics().evaluate(t)*x...
            +self.pDynObj.getBptDynamics().evaluate(t);
        
            [timeXtVec,xtArray]=solverObj.solve(XtDerivFunc,...
                self.tVec,self.readObj.x0Vec);
            
            xt = MatrixInterpolantFactory.createInstance(...
                'column',xtArray,timeXtVec);
            
            self.checkMatFun(xt, self.pDynObj.getxtDynamics());
        end
        
        function checkMatFun(self, mat1Obj, mat2Obj)
           import modgen.common.absrelcompare;
           mlunitext.assert_equals(mat1Obj.getMatrixSize(),...
               mat2Obj.getMatrixSize());
           
           for iElem=1:3:numel(self.tVec)
               t = self.tVec(iElem);
               et1Mat = mat1Obj.evaluate(t);
               et2Mat = mat1Obj.evaluate(t);
               isEqual = absrelcompare(et1Mat, et2Mat,...
                   self.absTol, self.relTol, @norm);
               
               mlunitext.assert(isEqual,...
                   sprintf(['Equality test failed for matrix function'...
                   '%s at t=%f'], inputname(2), t));
           end
        end
        
        function odePropList=getOdePropList(self)
            ODE_NORM_CONTROL='on';
            REL_TOL_FACTOR = 0.001;
            ABS_TOL_FACTOR = 0.001;
        
            odePropList={'NormControl',ODE_NORM_CONTROL,'RelTol',...
                self.relTol*REL_TOL_FACTOR,...
                'AbsTol',self.absTol*ABS_TOL_FACTOR};
        end
    end
end