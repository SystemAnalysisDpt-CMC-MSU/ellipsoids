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
        function testInvMat(~)
            import gras.geom.ell.invmat;
            DIM_VEC=2:11;
            normDiffVec=arrayfun(@(x)(norm(invhilb(x)-...
                invmat(hilb(x)))-norm(invhilb(x)-...
                inv(hilb(x)))),DIM_VEC);
            isOk = prod(normDiffVec)==0;
            mlunitext.assert_equals(true,isOk);
        end
        function testQuadMat(~)
            MAX_TOL = 1e-10;
            qMat = [2,5,7;6,3,4;5,-2,-3];
            xVec = [7,8,9].';
            cVec = [1,0,1];
            calcMode = 'plain';
            ANALYTICAL_RESULT_1 = 1304;
            ANALYTICAL_RESULT_2 = 1563;
            ANALYTICAL_RESULT_3 = -364;
            check(ANALYTICAL_RESULT_1);
            cVec = 0;
            check(ANALYTICAL_RESULT_2);
            calcMode = 'InvAdv';
            cVec = [1,0,1];
            check(ANALYTICAL_RESULT_3);
            calcMode = 'INV';
            check(ANALYTICAL_RESULT_3);
            function check(ANALYTICAL_RESULT)
                import gras.geom.ell.quadmat;
                quadRes = quadmat(qMat,xVec,cVec,calcMode);
                isOk = (abs(quadRes-ANALYTICAL_RESULT)<MAX_TOL);
                mlunitext.assert_equals(true,isOk);
            end
        end
        function testQuadMatNegative(self)
            import gras.geom.ell.quadmat;
            qMatSquare = [1,0;0,1];
            qMatNotSquare = [1,0];
            xVecGoodDim = [3,2];
            xVecBadDim = [1,5,10];
            cVecGoodDim = [1,1];
            cVecBadDim = [1,3,7];
            mode = 'plain';
            %
            check(@()quadmat(qMatNotSquare, xVecGoodDim,...
                cVecGoodDim, mode));
            %check(@()quadmat(qMatSquare, xVecGoodDim.',...
            %    cVecGoodDim, mode));
            check(@()quadmat(qMatSquare, xVecBadDim,...
                cVecGoodDim, mode));
            %check(@()quadmat(qMatSquare, xVecGoodDim,...
            %    cVecGoodDim.', mode));
            check(@()quadmat(qMatSquare, xVecGoodDim,...
                cVecBadDim, mode));
            function check(fFail)
                self.runAndCheckError(fFail,'wrongInput');
            end
        end
    end
end
