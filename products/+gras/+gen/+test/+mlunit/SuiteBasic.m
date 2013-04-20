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
        function testProgressCmdDisplayer(self)
            tStart=1;
            tEnd=16;
            nDots=5;
            obj=gras.gen.ProgressCmdDisplayer(tStart,tEnd,nDots);
            iCur=1;
            res{iCur}=evalc('obj.start()');
            for t=tStart:0.4:tEnd-1
                iCur=iCur+1;
                res{iCur}=evalc('obj.progress(t)');
            end
            iCur=iCur+1;
            res{iCur}=evalc('obj.finish');
            resStr=[res{:}];
            resExpStr='[].].].].].]';
            mlunit.assert_equals(48,length(resStr));
            resStrFiltered=resStr(ismember(resStr,'.[]'));
            mlunit.assert_equals(true,isequal(resStrFiltered,resExpStr));
        end
        function testRMultiplySimple(self)
            MAX_TOL=1e-11;
            aMat=rand(2,2);
            bMat=rand(2,2);
            cMat=rand(2,2);
            resMat=gras.gen.MatVector.rMultiply(aMat,bMat,cMat);
            etMat=aMat*bMat*cMat;
            maxTol=max(abs(resMat(:)-etMat(:)));
            mlunit.assert_equals(true,maxTol<=MAX_TOL)
        end
        %
        function testSortrowstol(self)
            inpMat=[1 2;1+1e-14 1];
            check([1;2],1e-16);
            %
            inpMat=[1 2;1+1e-14 1];
            check([2;1],1e-14);
            %
            inpMat=[1 2;1+1e-14 1;1-1e-14 0];
            check([3;2;1],1e-13);
            check([3;1;2],1e-15);
            %
            function check(indVec,tol)
                import gras.gen.*;                
                [resMat,indSortVec]=sortrowstol(inpMat,tol);
                checkint();
                [resMat,indSortVec,indRevSortVec]=sortrowstol(inpMat,tol);
                checkint();
                mlunit.assert_equals(true,isequal(resMat(indRevSortVec,:),...
                    inpMat));
                function checkint()
                    mlunit.assert_equals(true,isequal(resMat,...
                        inpMat(indVec,:)));
                    mlunit.assert_equals(true,isequal(indSortVec,...
                        indVec));
                end
            end
        end
        function testMinAdv(self)
            check([1 1],[2 2]);
            check([2 1],[1 2]);
            check([2 2],[1 1]);
            %
            check([2 2;1 1],[1 1;2 2]);
            check([2 2;2 2],[1 1;1 1]);
            check([1 1;1 1],[2 2;2 2]);
            check(rand(10,1,10),rand(10,1,10));
            for iCase=1:2
                check(rand(10,10,10),rand(10,10,10));
            end
            %
            function check(leftArray,rightArray)
                [minArray,indMinSide]=gras.gen.minadv(leftArray,rightArray);
                [minExpArray,indExpMinSide]=gras.gen.test.minadv(...
                    leftArray,rightArray);
                minArray=reshape(minArray,size(minArray,1),[]);
                    mlunit.assert_equals(true,isequal(minArray,...
                        minExpArray));
                    mlunit.assert_equals(true,isequal(indMinSide,...
                        indExpMinSide));
            end
                
        end
        %
        function testCompareMatVectorMultiply(self)
            import gras.gen.MatVector;
            %
            absTol = elltool.conf.Properties.getAbsTol();
            SData = load(['TestData', filesep, 'matvector_data.mat']);
            aArray = SData.aArray;
            bMat = squeeze(aArray(1,:,:));
            %
            cArray = MatVector.rMultiply(aArray,aArray,false);
            dArray = MatVector.rMultiply(aArray,aArray,true);
            check(cArray, dArray);
            %
            cArray = MatVector.rMultiply(aArray(1:5,1:6,:),...
                aArray(1:6,1:7,:),aArray(1:7,1:8,:),false);
            dArray = MatVector.rMultiply(aArray(1:5,1:6,:),...
                aArray(1:6,1:7,:),aArray(1:7,1:8,:),true);
            check(cArray, dArray);
            %
            cMat = MatVector.rMultiplyByVec(aArray,bMat,false);
            dMat = MatVector.rMultiplyByVec(aArray,bMat,true);
            check(cMat, dMat);
            %
            cMat = MatVector.rMultiplyByVec(aArray(1:7,1:10,1:100),...
                bMat(1:10,1:100),false);
            dMat = MatVector.rMultiplyByVec(aArray(1:7,1:10,1:100),...
                bMat(1:10,1:100),true);
            check(cMat, dMat);
            %
            function check(aArray, bArray)
                rArray = aArray - bArray;
                mlunit.assert(max(abs(rArray(:))) < absTol);
            end
        end
    end
end