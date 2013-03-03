classdef SuiteBasic < mlunitext.test_case
    properties
    end
    
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self,varargin)
            
        end
        function testEllVolume(~)
            MAX_TOL=1e-14;
            eVec=[1,2,3];
            QMat=diag(eVec);
            resVol=gras.geom.ell.ellvolume(QMat);
            expVol=sqrt(prod(eVec))*pi*4/3;
            isOk=abs(expVol-resVol)<MAX_TOL;
            mlunit.assert_equals(true,isOk);
        end
    end
end