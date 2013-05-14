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
        %
        function testSupGeomDiff2dNegative(self)
            N_DIRS=200;
            import gras.geom.sup.supgeomdiff2d;
            lMat=gras.geom.circlepart(N_DIRS).';
            rho1Vec=ones(1,N_DIRS);
            rho2Vec=ones(1,N_DIRS)*0.5;
            %
            check(@()supgeomdiff2d(rho2Vec,rho1Vec,lMat));
            check(@()supgeomdiff2d(rho2Vec,rho1Vec,lMat.'));
            check(@()supgeomdiff2d(rho2Vec,rho1Vec.',lMat));
            check(@()supgeomdiff2d(rho2Vec.',rho1Vec.',lMat.'));
            function check(fFail)
                self.runAndCheckError(fFail,'wrongInput');
            end
            
        end
        function testSupGeomDiff2d(~)
            N_DIRS=200;
            EXP_TOL=1e-15;
            EXP_MAX=0.612493409916315;
            EXP_MIN=0.105572809000084;
            
            lMat=gras.geom.circlepart(N_DIRS).';
            import gras.geom.sup.supgeomdiff2d;
            import gras.geom.sup.sup2boundary2;
            q1Mat=diag([1 2]);
            q2Mat=diag([0.8 0.1]);
            rho1Vec=rho(q1Mat);
            rho2Vec=rho(q2Mat);
            rhoDiffVec=supgeomdiff2d(rho1Vec,rho2Vec,lMat);
            xBoundMat=sup2boundary2(lMat.',rhoDiffVec.');
            line(xBoundMat([1:end,1],1),...
                xBoundMat([1:end,1],2),'Color','g');
            nDirsShift=fix(N_DIRS*0.5);
            maxPeriodTol=max(abs(circshift(rhoDiffVec,[1 nDirsShift])...
                -rhoDiffVec));
            mlunitext.assert(maxPeriodTol<=EXP_TOL);
            mlunitext.assert(abs(EXP_MAX-max(rhoDiffVec))<=EXP_TOL);
            mlunitext.assert(abs(EXP_MIN-min(rhoDiffVec))<=EXP_TOL);
            %
            function rhoVec=rho(qMat)
                rhoVec=realsqrt(sum((qMat*lMat).*lMat,1));
            end
        end
        %
        function self=testSup2Boundary2(self)
            qMat=diag([1,2]);
            sMat=gras.la.orthtransl([1;0],[1;1]);
            %
            qMat=sMat.'*qMat*sMat;
            dirMat=gras.geom.circlepart(100);
            self.aux_testSupBoundary(@gras.geom.sup.sup2boundary2,...
                @(x,y)transpose(gras.geom.sup.test.sup2boundary2(x.',y.')),...
                qMat,dirMat);
        end
        %
        function self=testSup2Boundary3(self)
            qMat=diag([1,2,3]);
            sMat=gras.la.orthtransl([1;0;0;],[1;1;1]);
            %
            qMat=sMat.'*qMat*sMat;
            [dirMat,faceMat]=gras.geom.tri.spheretri(6);
            self.aux_testSupBoundary(@gras.geom.sup.sup2boundary3,...
                @gras.geom.sup.sup2boundary3,qMat,dirMat,faceMat);
        end
        %
        function aux_testSupBoundary(~,fBoundary,fCheckBoundary,...
                qMat,dirMat,varargin)
            MAX_NORM=1+1e-3;
            MIN_NORM=1;
            MAX_TOL=1e-14;
            supVec=realsqrt(sum((dirMat*qMat).*dirMat,2));
            % build boundary approximation
            xMat=fBoundary(dirMat,supVec,varargin{:});
            xExpMat=fCheckBoundary(dirMat,supVec,varargin{:});
            realTol=max(realsqrt(sum((xMat-xExpMat).*(xMat-xExpMat),2)));
            mlunitext.assert_equals(true,realTol<=MAX_TOL);
            % translate boundary back to unit sphere
            yMat=xMat/sqrtm(qMat);
            % see how good this translation approximates a unit sphere
            nVec=realsqrt(sum(yMat.*yMat,2));
            mlunitext.assert_equals(true,max(nVec)<=MAX_NORM);
            mlunitext.assert_equals(true,min(nVec)>=MIN_NORM);
        end
    end
end
