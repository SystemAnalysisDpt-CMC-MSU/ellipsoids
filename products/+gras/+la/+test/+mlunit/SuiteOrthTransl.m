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
        function test_matorth(self)
            inpMat=self.srcTlMat;
            nVecs=size(inpMat,2);
            %
            oMat=gras.la.matorth(inpMat);
            o2Mat=gras.la.test.adv_qorth(inpMat);
            self.aux_checkOrthPlain(oMat,'matorth');
            o2RedMat=o2Mat(:,1:nVecs);
            self.aux_checkEye(o2RedMat.'*o2RedMat,...
                'o2RedMat.''*o2RedMat','test.adv_qorth');
            isOk=max(max(abs(oMat(:,1:nVecs)-o2RedMat)))<=self.MAX_TOL;
            mlunit.assert_equals(true,isOk);
            %
            self.aux_checkEye(gras.la.matorth([1 -eps;0 1]),...
                'matorth([1 -eps;0 1])','test.adv_qorth');
            self.aux_checkEye(gras.la.matorth([1 -eps;eps 1]),...
                'matorth([1 -eps;eps 1])','test.adv_qorth');
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
                    @gras.la.test.orthtranslmaxtr,@calcTrace,...
                    srcVec,dstVec,aMat);
                %
                %% Test MAX Dir functions
                %
                srcMaxVec=srcMat(:,2);
                dstMaxVec=dstMat(:,2);
                oMaxDirMat=check(@gras.la.orthtranslmaxdir,...
                    @gras.la.test.orthtranslmaxdir,@calcDir,...
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
                    MAX_METRIC_COMP_TOL=1e-14;
                    maxVal=fCalc(oMaxMat);
                    compVal=fCalc(oCompMat);
                    isPos=maxVal+MAX_METRIC_COMP_TOL>=compVal;
                    %
                    mlunit.assert_equals(true,isPos,...
                        sprintf(['%s maximization does work, maxVal %e ',...
                        '< compVal %e'],func2str(fCalc),maxVal,compVal));
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
                    mlunit.assert_equals(true,isPos,...
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
            MAX_TIME_DIFF=0.01;
            tTest=self.aux_test_qorth(@gras.la.test.mlorthtransl,...
                @gras.la.test.mlorthtransl);
            tProd=self.aux_test_qorth(@gras.la.mlorthtransl,...
                @gras.la.orthtransl);
            tDiff=tProd-tTest;
            tAvg=(tProd+tTest)*0.5;
            tRatio=tDiff./tAvg;
            isPos=tRatio<=MAX_TIME_DIFF;
            mlunit.assert_equals(true,isPos,...
                sprintf('Production version is slower by %2.1f%% > %2.1e',...
                tRatio*100,MAX_TIME_DIFF*100));
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
                mlunit.assert_equals(true,isPos,...
                    sprintf('when comparing %s and %s real tol %e>%e',...
                    func2str(fHandle),func2str(fHandleSingle),...
                    realTol,self.MAX_TOL));
                %
            end
        end
        function aux_checkOrthPlain(self,oMat,funcName)
            mlunit.assert_equals(true,ndims(oMat)==2);
            mlunit.assert_equals(true,size(oMat,1)==size(oMat,2));
            %
            self.aux_checkEye(oMat.'*oMat,'oMat.''*oMat',funcName);
            self.aux_checkEye(oMat*oMat.','oMat*oMat.''',funcName);
            %
        end
        function aux_checkEye(self,eMat,msgStr,funcName)
            nDims=size(eMat,1);
            realTol=max(max(abs(eMat-eye(nDims))));
            isPos=realTol<=self.MAX_TOL;
            mlunit.assert_equals(true,isPos,...
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
            mlunit.assert_equals(true,isPos,...
                sprintf(['dstVec for %s is not close enough to ',...
                'expDestVec, is %e>%e'],...
                funcName,realTol,self.MAX_TOL));
        end
    end
end