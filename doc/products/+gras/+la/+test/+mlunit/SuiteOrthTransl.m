classdef SuiteOrthTransl < mlunitext.test_case
    properties (Access=private)
        srcTlMat=[[0;1;0.3;-2],[3;1;-4;1]];
        dstTlMat=[[-1;2;3;4],[-5;2;1;5]];
        %
        MAX_TOL=1e-8;
    end
    %
    methods
        function self = SuiteOrthTransl(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self,varargin)
        end
        %
        function testOrthTransl(self)
            import gras.la.orthtransl;
            srcVec=[0 0];
            dstVec=[1 0];
            check('wrongInput:srcZero');
            srcVec=[1 0];
            dstVec=[0 0];
            check('wrongInput:dstZero');
            srcVec=[1 0]+1i*[1 0];
            check('wrongInput:srcComplex');
            srcVec=[1 0];
            dstVec=[1 0]+1i*[1 0];
            check('wrongInput:dstComplex');
            %
            function check(expErrorTag)
            self.runAndCheckError('gras.la.orthtransl(srcVec,dstVec)',...
                expErrorTag);
            self.runAndCheckError('gras.la.orthtranslqr(srcVec,dstVec)',...
                expErrorTag);
            end
        end
        function testOrthTranslQr(self)
            CALC_PRECISION = 1e-10;
            %
            check(1, -1);
            check(10, 2);
            check([1;0], [0;1]);
            check(self.srcTlMat(:,1), self.dstTlMat(:,1));
            check(self.srcTlMat(:,2), self.dstTlMat(:,2));
            %
            function check(srcVec,dstVec)
                ind = find(dstVec, 1, 'first');
                oMat = gras.la.orthtranslqr(srcVec,dstVec);
                gotVec = oMat*srcVec;
                diffVec = abs(dstVec/dstVec(ind) - gotVec/gotVec(ind));
                mlunitext.assert(all(diffVec < CALC_PRECISION));
            end
        end
        function testMatOrth(self)
            inpMat=self.srcTlMat;
            nCols=size(inpMat,2);
            for iCol=1:nCols
                check(inpMat(:,1:iCol));
            end
            function check(inpMat)
                %
                oMat=gras.la.matorth(inpMat);
                oRedMat=gras.la.matorthcol(inpMat);
                mlunitext.assert(isequal(oMat(:,1:size(inpMat,2)),oRedMat));
                self.aux_checkOrthPlain(oMat,'matorth');
            end
        end
        function test_orthtranslmax(self)
            %
            N_RANDOM_CASES=10;
            DIM_VEC=[1 2 3 5];
            %
            ALT_TOL=1e-10;
            %
            masterCheck(self.srcTlMat,self.dstTlMat);
            %
            for nDims=DIM_VEC
                for iTest=1:N_RANDOM_CASES
                    srcMat=rand(nDims,2);
                    dstMat=rand(nDims,2);
                    masterCheck(srcMat,dstMat);
                    %
                    masterCheck(srcMat,srcMat);
                    %
                    dstAltMat=srcMat+rand(size(srcMat))*ALT_TOL;
                    masterCheck(srcMat,dstAltMat);
                end
            end
            %
            function masterCheck(srcMat,dstMat)
                srcVec=srcMat(:,1);
                %
                dstVec=dstMat(:,1);
                %
                %% Test Hausholder function
                oMat=gras.la.orthtranslhaus(srcVec,dstVec);
                aux_checkOrth(self,oMat,srcVec,dstVec,...
                    'gras.la.orthtranslhaus');
                %% Test MAX Trace functions
                %
                aSqrtMat=rand(length(srcVec));
                aMat=aSqrtMat*transpose(aSqrtMat);
                %
                oMaxTrMat=check(@gras.la.orthtranslmaxtr,...
                    @gras.la.orthtranslmaxtr,@calcTrace,...
                    srcVec,dstVec,aMat);
                %
                %% Test MAX Dir functions
                %
                srcMaxVec=srcMat(:,2);
                dstMaxVec=dstMat(:,2);
                oMaxDirMat=check(@gras.la.orthtranslmaxdir,...
                    @gras.la.orthtranslmaxdir,@calcDir,...
                    srcVec,dstVec,srcMaxVec,dstMaxVec);
                %
                oPlainMat=gras.la.orthtransl(srcVec,dstVec);
                %
                checkMetric(@calcTrace,oMaxTrMat,oMaxDirMat);
                checkMetric(@calcDir,oMaxDirMat,oMaxTrMat);
                checkMetric(@calcDir,oMaxDirMat,oPlainMat);
                checkMetric(@calcTrace,oMaxTrMat,oPlainMat);
                %
                function checkMetric(fCalc,oMaxMat,oCompMat)
                    MAX_METRIC_COMP_TOL=1e-13;
                    maxVal=fCalc(oMaxMat);
                    compVal=fCalc(oCompMat);
                    isPos=maxVal+MAX_METRIC_COMP_TOL>=compVal;
                    %
                    mlunitext.assert_equals(true,isPos,...
                        sprintf(['%s maximization doesn''t work, maxVal %f ',...
                        '< compVal %f'],func2str(fCalc),maxVal,compVal));
                end
                %
                function oMat=check(fProdHandle,fTestHandle,...
                        fCompHandle,varargin)
                    oMat=fProdHandle(varargin{:});
                    self.aux_checkOrth(oMat,srcVec,dstVec,func2str(fProdHandle));
                    %
                    oExpMat=fTestHandle(varargin{:});
                    self.aux_checkOrth(oExpMat,srcVec,dstVec,func2str(fTestHandle));
                    compVal=fCompHandle(oMat);
                    compExpVal=fCompHandle(oExpMat);
                    realTol=max(abs(compVal-compExpVal));
                    isPos=realTol<=self.MAX_TOL;
                    mlunitext.assert_equals(true,isPos,...
                        sprintf('when comparing %s and %s real tol %e>%e',...
                        func2str(fProdHandle),func2str(fTestHandle),...
                        realTol,self.MAX_TOL));
                end
                %
                function trVal=calcTrace(oMat)
                    trVal=trace(oMat*aMat);
                end
                %
                function trVal=calcDir(oMat)
                    trVal=dstMaxVec.'*oMat*srcMaxVec;
                end
            end
        end
        %
        function test_mlorthtransl(self)
            self.aux_test_qorth(@gras.la.mlorthtransl,...
                @gras.la.orthtransl);
        end
        function tElapsed=aux_test_qorth(self,fHandle,fHandleSingle)
            N_ELEMS=1000;
            %
            srcMat=self.srcTlMat;
            %
            dstMat=self.dstTlMat;
            dstArray=repmat(dstMat,[1,1,N_ELEMS]);
            %
            nVecs=size(srcMat,2);
            tStart=tic;
            oArray=fHandle(srcMat,dstArray);
            tElapsed=toc(tStart);
            for iElem=1:N_ELEMS
                for iVec=1:nVecs
                    check(oArray(:,:,iElem,iVec),srcMat(:,iVec),dstArray(:,iVec,iElem));
                end
            end
            function check(oMat,srcVec,dstExpVec)
                self.aux_checkOrth(oMat,srcVec,dstExpVec,...
                    func2str(fHandle));
                %
                oExpMat=fHandleSingle(srcVec,dstExpVec);
                %
                realTol=max(max(abs(oMat-oExpMat)));
                isPos=realTol<=self.MAX_TOL;
                mlunitext.assert_equals(true,isPos,...
                    sprintf('when comparing %s and %s real tol %e>%e',...
                    func2str(fHandle),func2str(fHandleSingle),...
                    realTol,self.MAX_TOL));
                %
            end
        end
        function aux_checkOrthPlain(self,oMat,funcName)
            mlunitext.assert_equals(true,ndims(oMat)==2);
            mlunitext.assert_equals(true,size(oMat,1)==size(oMat,2));
            %
            self.aux_checkEye(oMat.'*oMat,'oMat.''*oMat',funcName);
            self.aux_checkEye(oMat*oMat.','oMat*oMat.''',funcName);
            %
        end
        function aux_checkEye(self,eMat,msgStr,funcName)
            nDims=size(eMat,1);
            realTol=max(max(abs(eMat-eye(nDims))));
            isPos=realTol<=self.MAX_TOL;
            mlunitext.assert_equals(true,isPos,...
                sprintf('real tol for %s=I check of %s is %e>%e',...
                msgStr,funcName,realTol,self.MAX_TOL));
        end
        function aux_checkOrth(self,oMat,srcVec,dstExpVec,funcName)
            self.aux_checkOrthPlain(oMat,funcName);
            %
            dstVec=oMat*srcVec;
            %
            dstVec=dstVec./norm(dstVec);
            dstExpVec=dstExpVec./norm(dstExpVec);
            %
            realTol=max(abs(dstVec-dstExpVec));
            isPos=realTol<=self.MAX_TOL;
            mlunitext.assert_equals(true,isPos,...
                sprintf(['dstVec for %s is not close enough to ',...
                'expDestVec, is %e>%e'],...
                funcName,realTol,self.MAX_TOL));
        end
    end
end