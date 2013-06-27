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
            expVol=realsqrt(prod(eVec))*pi*4/3;
            isOk=abs(expVol-resVol)<MAX_TOL;
            mlunitext.assert_equals(true,isOk);
        end
        function testRhoMat(~)
            MAX_TOL = 1e-14;
            ABS_TOL = 1e-7;
            qMat = [49 4;4 1];
            cVec = [1 0]';
            dirsMat = [1 0; 0 1]';
            [supArr, bpMat] = gras.geom.ell.rhomat(qMat,dirsMat,...
                ABS_TOL,cVec);
            isOk = (abs(supArr-[8 1])<MAX_TOL)' & (abs(bpMat(:,2)-...
                [5;1])<MAX_TOL);
            mlunitext.assert_equals([true true]',isOk);
            q2Mat = eye(3);
            c2Vec = [1 0 0]';
            dirsMat = [1 0 0]';
            [supArr, bpMat] = gras.geom.ell.rhomat(q2Mat,dirsMat,...
                ABS_TOL,c2Vec);
            isOk = (abs(supArr-2)<MAX_TOL)' & (abs(bpMat(1)-...
                2)<MAX_TOL);
            mlunitext.assert_equals(true,isOk);
        end
    end
end
