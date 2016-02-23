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
        
        function testDynBasicGetters(self)
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
            fXtFunc = @(t)self.pDynObj.getxtDynamics().evaluate(t);
            
            fXtDeriv = @(t)...
                self.pDynObj.getAtDynamics().evaluate(t)*fXtFunc(t)+...
                self.pDynObj.getBptDynamics().evaluate(t);
            
            self.checkDerivFun(fXtDeriv, fXtFunc);
        end
        
        function checkDerivFun(self, fXtDeriv, fXtFunc)
            import modgen.common.absrelcompare;
            TOL_MULT = 10e1;
            
            tVec = self.tVec;
            for iElem=1:numel(tVec)-1
                t0 = tVec(iElem);
                t1 = tVec(iElem+1);
                t = 0.5*(t0+t1);
                
                dxVec = (fXtFunc(t1) - fXtFunc(t0)) / (t1 - t0);
                dxRefVec = fXtDeriv(t);
                
                [isEqual,absDif,~,relDif] = absrelcompare(dxRefVec,dxVec,...
                    TOL_MULT*self.absTol, TOL_MULT*self.relTol, @norm);
                
                mlunitext.assert(isEqual,...
                    sprintf(['xtDynamics check failed at '...
                    't=%f: absDif=%f, relDif=%f'], t0, absDif, relDif));
            end
        end
        
        function checkMatFun(self, mat1Obj, mat2Obj)
           import modgen.common.absrelcompare;
           mlunitext.assert_equals(mat1Obj.getMatrixSize(),...
               mat2Obj.getMatrixSize());
           
           for iElem=1:numel(self.tVec)
               t = self.tVec(iElem);
               et1Mat = mat1Obj.evaluate(t);
               et2Mat = mat1Obj.evaluate(t);
               isEqual = absrelcompare(et1Mat, et2Mat,...
                   self.absTol, self.relTol, @norm);
               
               mlunitext.assert(isEqual,...
                   sprintf(['%s matrix function check failed '...
                   'at t=%f'], inputname(2), t));
           end
        end
    end
    
    methods(Static)
        function multiplyMatrixSamples(m1Array, m2Array)
            m1Array = reshape(shiftdim(m1Array, 2), [], size(m1Array, 2));
            m2Array = reshape(shiftdim(m2Array, 2), [], size(m2Array, 2));
        end
    end
end