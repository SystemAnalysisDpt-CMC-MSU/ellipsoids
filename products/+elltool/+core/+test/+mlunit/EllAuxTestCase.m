classdef EllAuxTestCase < mlunitext.test_case
    properties (Access=private)
        ABS_TOL = 1e-8;
     end
     methods
         function self=EllAuxTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
         end
         %
         function testEllRegularize(self)
             import modgen.common.checkmultvar;
             shMat = [4 4 14; 4 4 14; 14 14 78];
             isOk=gras.la.ismatposdef(shMat,self.ABS_TOL);
             mlunitext.assert(~isOk);
             shMat = ell_regularize(shMat, self.ABS_TOL);
             isOk=gras.la.ismatposdef(shMat,self.ABS_TOL,true);
             mlunitext.assert(isOk);
         end
         %
         function testEllRegConsitent(self)
             absTol=self.ABS_TOL;
             CMP_TOL=1e-12;
             shMat = [4 4 14; 4 4 14; 14 14 78];
             %
             shRegMat=ell_regularize(shMat,absTol);
             masterCheckIsPos(shRegMat);             
             %
             ell=ellipsoid(shMat,'absTol',absTol);    
             mlunit.assert(isequal(ell.getShapeMat(),shMat));
             %
             checkApxReg(@minksum_ia);
             checkApxReg(@minksum_ea);
             %
             %
             function checkApxReg(fApxMethod)
             ellArr=[ell,ell.getCopy()];
             apxEll=fApxMethod(ellArr,[1;0;0]);
             ellRegShapeMat=apxEll.getShapeMat();
             maxDiff=max(abs(ellRegShapeMat(:)*0.25-shRegMat(:)));
             isOk=maxDiff<=CMP_TOL;
             mlunit.assert(isOk);
             end
             %masterCheckIsPos(ellRegShapeMat);
             %
             function masterCheckIsPos(inpMat)
                 checkIsPos(inpMat,false,0);
                 checkIsPos(inpMat,true,0,true);
                 checkIsPos(inpMat,false,eps);
                 checkIsPos(inpMat,true,-eps);
             end
             %
             function checkIsPos(inpMat,isExpOk,delta,varargin)
                 isOk=gras.la.ismatposdef(inpMat,absTol+delta,varargin{:});
                 mlunit.assert_equals(isOk,isExpOk);
                 if (nargin>3)
                     isSemPosDef=varargin{1};
                 else
                     isSemPosDef=false;
                 end
                 if ~isSemPosDef
                    ell=ellipsoid(inpMat,'absTol',absTol+delta);
                    isOk=~ell.isdegenerate();
                    mlunit.assert_equals(isOk,isExpOk);
                 end
             end
         end
     end
end