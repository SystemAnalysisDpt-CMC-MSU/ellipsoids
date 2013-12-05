classdef EllAuxTestCase < mlunitext.test_case
    properties (Access=private)
        ABS_TOL = 1e-8;
    end
    properties
        ellFactoryObj
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
            shMat = gras.la.regposdefmat(shMat, self.ABS_TOL);
            isOk=gras.la.ismatposdef(shMat,self.ABS_TOL,true);
            mlunitext.assert(isOk);
        end
        function self = set_up_param(self, ellFactoryObj)
            self.ellFactoryObj = ellFactoryObj;
        end
        %
        function testEllRegConsitent(self)
            absTol=self.ABS_TOL;
            CMP_TOL=1e-12;
            shMat = [4 4 14; 4 4 14; 14 14 78];
            %
            shRegMat=gras.la.regposdefmat(shMat,absTol);
            masterCheckIsPos(shRegMat);
            %
            ell=self.ellFactoryObj.create(shMat,'absTol',absTol);
                                 
            mlunitext.assert(modgen.common.absrelcompare(ell.getShapeMat(), shMat, absTol, absTol, @norm));
            
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
                mlunitext.assert(isOk);
            end
            %masterCheckIsPos(ellRegShapeMat);
            %
            function masterCheckIsPos(inpMat)
                epsVal=absTol*1e-5;
                checkIsPos(inpMat,false,0);
                checkIsPos(inpMat,true,0,true);
                checkIsPos(inpMat,false,epsVal);
                checkIsPos(inpMat,true,-epsVal);
            end
            %
            function checkIsPos(inpMat,isExpOk,delta,varargin)
                isOk=gras.la.ismatposdef(inpMat,absTol+delta,varargin{:});
                mlunitext.assert_equals(isOk,isExpOk);
                if (nargin>3)
                    isSemPosDef=varargin{1};
                else
                    isSemPosDef=false;
                end
                if ~isSemPosDef
                    ell=self.ellFactoryObj.create(inpMat,'absTol',absTol+delta);
                    isOk=~ell.isdegenerate();
                    mlunitext.assert_equals(isOk,isExpOk);
                end
            end
        end
    end
end