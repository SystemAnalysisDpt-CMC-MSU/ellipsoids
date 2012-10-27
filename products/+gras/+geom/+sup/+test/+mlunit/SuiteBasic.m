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
            supVec=sqrt(sum((dirMat*qMat).*dirMat,2));
            % build boundary approximation
            xMat=fBoundary(dirMat,supVec,varargin{:});
            xExpMat=fCheckBoundary(dirMat,supVec,varargin{:});
            realTol=max(sqrt(sum((xMat-xExpMat).*(xMat-xExpMat),2)));
            mlunit.assert_equals(true,realTol<=MAX_TOL);
            % translate boundary back to unit sphere
            yMat=xMat/sqrtm(qMat);
            % see how good this translation approximates a unit sphere
            nVec=sqrt(sum(yMat.*yMat,2));
            mlunit.assert_equals(true,max(nVec)<=MAX_NORM);
            mlunit.assert_equals(true,min(nVec)>=MIN_NORM);
        end        
    end
end