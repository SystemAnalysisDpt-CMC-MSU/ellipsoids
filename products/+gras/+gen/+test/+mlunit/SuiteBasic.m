classdef SuiteBasic < mlunitext.test_case
    properties
    end
    
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function testSqrtPos(~)
            import gras.gen.sqrtpos;
            inpArr=rand(2,3,4,5,6);
            check();
            check(inpArr(100));
            inpArr=1;
            check();
            check(1);
            %
            function check(varargin)
                import gras.gen.sqrtpos;
                outArr=sqrtpos(inpArr,varargin{:});
                isOk=all(size(outArr)==size(inpArr));
                mlunitext.assert(isOk);
                resArr=sqrtpos(inpArr,varargin{:});
                expResArr=arrayfun(@(x)sqrtpos(x,varargin{:}),inpArr);
                mlunitext.assert(all(resArr(:)==expResArr(:)));
                isNotNegArr=arrayfun(@(x)isnotneg(x,varargin{:}),...
                    inpArr);
                isNotNeg=isnotneg(inpArr,varargin{:});
                isExpNotNeg=all(isNotNegArr(:));
                mlunitext.assert(isNotNeg==isExpNotNeg);
            end
            function isNotNeg=isnotneg(varargin)
                try
                    isNotNegArr=gras.gen.sqrtpos(varargin{:});
                    isNotNeg=all(isNotNegArr(:));
                catch meObj
                    isNeg=strcmp(meObj.identifier,...
                        'wrongInput:negativeInput');
                    if ~isNeg
                        rethrow(meObj);
                    end
                    isNotNeg=~isNeg;
                end
            end
        end
        %
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
            mlunitext.assert_equals(48,length(resStr));
            resStrFiltered=resStr(ismember(resStr,'.[]'));
            mlunitext.assert_equals(true,isequal(resStrFiltered,resExpStr));
        end
        function testRMultiplySimple(self)
            MAX_TOL=1e-11;
            aMat=rand(2,2);
            bMat=rand(2,2);
            cMat=rand(2,2);
            resMat=gras.gen.MatVector.rMultiply(aMat,bMat,cMat);
            etMat=aMat*bMat*cMat;
            maxTol=max(abs(resMat(:)-etMat(:)));
            mlunitext.assert_equals(true,maxTol<=MAX_TOL)
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
                mlunitext.assert_equals(true,isequal(resMat(indRevSortVec,:),...
                    inpMat));
                function checkint()
                    mlunitext.assert_equals(true,isequal(resMat,...
                        inpMat(indVec,:)));
                    mlunitext.assert_equals(true,isequal(indSortVec,...
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
                mlunitext.assert_equals(true,isequal(minArray,...
                    minExpArray));
                mlunitext.assert_equals(true,isequal(indMinSide,...
                    indExpMinSide));
            end
            
        end
        function testMatDot(self)
            import gras.gen.matdot;
            Amat = magic(4);
            Bmat = eye(4);
            Cmat = ones(4);
            % commutative
            check(matdot(Amat, Bmat), matdot(Bmat, Amat));
            % bilinear
            check(matdot(Amat, 2 * Bmat - 4 * Cmat), 2 * ...
                matdot(Amat, Bmat) - 4 * matdot(Amat, Cmat));
            check(matdot(Amat + 3 * Bmat, Cmat), matdot(Amat, Cmat) + ...
                3 * matdot(Bmat, Cmat));
            % scalar multiplication
            check(matdot(3 * Amat, -5 * Bmat), -15 * matdot(Amat, Bmat));
            %
            function check(leftArray,rightArray)
                mlunitext.assert_equals(true,isequal(leftArray,...
                    rightArray));
            end
        end
        function testAbsRelDiff(self)
            import gras.gen.absreldiff;
            % size error
            self.runAndCheckError(...
                'gras.gen.absreldiff([1 1], [1; 1], 0.1, @abs)', ...
                'wrongInput:wrongArgs');
            % absTol error #1
            self.runAndCheckError(...
                'gras.gen.absreldiff([1 1], [1 1], -0.1, @abs)', ...
                'wrongInput:wrongAbsTol');
            % absTol error #2
            self.runAndCheckError(...
                'gras.gen.absreldiff([1 1], [1 1], [0.1, -0.1], @abs)', ...
                'wrongInput:wrongAbsTol');
            % result tests
            xVec = [1 2]; yVec = [2 4];
            [zVec, isRelComp] = absreldiff(xVec, yVec, 0.5, @abs);
            check(zVec, [2/3, 2/3]);
            check(isRelComp, true([1 2]));
            %
            [zVec, isRelComp] = absreldiff(xVec, yVec, 1.5, @abs);
            check(zVec, [1, 2/3]);
            check(isRelComp, logical([0, 1]));
            %
            [zVec, isRelComp] = absreldiff(xVec, yVec, 3, @abs);
            check(zVec, [1, 2]);
            check(isRelComp, false([1, 2]));
            function check(leftArray,rightArray)
                mlunitext.assert_equals(true,isequal(leftArray,...
                    rightArray));
            end
        end
    end
end