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
        function testAbsRelCompare(self)
            import gras.gen.absrelcompare;
            % size error
            self.runAndCheckError(...
                'gras.gen.absrelcompare([1 1], [1; 1], 0.1, [], @abs)', ...
                'wrongInput:wrongArgs');
            % absTol error #1
            self.runAndCheckError(...
                'gras.gen.absrelcompare([1 1], [1 1], -0.1, [], @abs)', ...
                'wrongInput:wrongAbsTol');
            % absTol error #2
            self.runAndCheckError([...
                'gras.gen.absrelcompare([1 1], [1 1], [0.1, 0.1], [],', ...
                ' @abs)'], 'wrongInput:wrongAbsTol');
            % absTol error #3
            self.runAndCheckError([...
                'gras.gen.absrelcompare([1 1], [1 1], [], [],', ...
                ' @abs)'], 'wrongInput:wrongAbsTol');
            % relTol error #1
            self.runAndCheckError(...
                'gras.gen.absrelcompare([1 1], [1 1], 0.1, -0.1, @abs)',...
                'wrongInput:wrongRelTol');
            % relTol error #2
            self.runAndCheckError([...
                'gras.gen.absrelcompare([1 1], [1 1], 0.1, [0.1, 0.1],',...
                ' @abs)'], 'wrongInput:wrongRelTol');
            % fNormOp error
            self.runAndCheckError(...
                'gras.gen.absrelcompare([1 1], [1 1], 0.1, [], 100)', ...
                'wrongInput:wrongNormOp');
            % result tests
            [SRes.isEqual, SRes.absDiff, SRes.isRel, SRes.relDiff, ...
                SRes.relMDiff, SRes.diffMat, SRes.isRelCompMat] = ...
                absrelcompare([], [], 0.5, [], @abs);
            SExpRes = struct('isEqual', true, 'absDiff', [], 'isRel', ...
                false, 'relDiff', [], 'relMDiff', [], 'diffMat', [], ...
                'isRelCompMat', []);
            check(SExpRes, SRes);
            %
            xVec = [1 2]; yVec = [2 4];
            SRes = calc(xVec, yVec, 2, [], @abs);
            SExpRes.isEqual = true;
            SExpRes.absDiff = 2;
            SExpRes.diffMat = [1, 2];
            SExpRes.isRelCompMat = false([1 2]);
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 1, [], @abs);
            SExpRes.isEqual = false;
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 2, 2/3, @abs);
            SExpRes.isEqual = true;
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 1, 2/3, @abs);
            SExpRes.isRel = true;
            SExpRes.relDiff = 2/3;
            SExpRes.relMDiff = 2;
            SExpRes.diffMat = [1, 2/3];
            SExpRes.isRelCompMat = logical([0, 1]);
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 1, 0.5, @abs);
            SExpRes.isEqual = false;
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 0.5, 0.5, @abs);
            SExpRes.diffMat = [2/3, 2/3];
            SExpRes.isRelCompMat = true([1, 2]);
            check(SExpRes, SRes);
            function SRes = calc(varargin)
                [SRes.isEqual, SRes.absDiff, SRes.isRel, SRes.relDiff, ...
                SRes.relMDiff, SRes.diffMat, SRes.isRelCompMat] = ...
                gras.gen.absrelcompare(varargin{:}); 
            end
            function check(leftArray,rightArray)
                mlunitext.assert_equals(true,isequal(leftArray,...
                    rightArray));
            end
        end
        function testSymmetricOp(self)
            import gras.gen.SymmetricMatVector;
            %
            MAX_TOL=1e-10;
            aArray = zeros(2, 2, 2);
            bArray = zeros(2, 3, 2);
            aArray(:,:,1) = [0 1; 1 0];
            aArray(:,:,2) = [5 2; 2 1];
            bArray(:,:,1) = [4 6 1; -6 2 4];
            bArray(:,:,2) = [8 3 8; 4 3 7];
            %
            resArray = SymmetricMatVector.lrSvdMultiply(aArray, bArray);
            check(@(x)x, aArray, bArray, resArray, true, false);
            %
            cMat = repmat([1; 0], [1 2]);
            resArray = SymmetricMatVector.rSvdMultiplyByVec(aArray, ...
                cMat);
            check(@(x)x, aArray, cMat, resArray, false, true);
            %
            resArray = SymmetricMatVector.lrSvdMultiplyByVec(aArray, ...
                cMat);
            check(@(x)x, aArray, cMat, resArray, true, true);
            %
            resArray = SymmetricMatVector.lrSvdDivideVec(aArray, ...
                cMat);
            check(@inv, aArray, cMat, resArray, true, true);
            %
            function check(fOpFunc, inp1Array, inp2Array, resArray, ...
                    isLrOp, isVec)
                sizeVec = size(resArray);
                nPoints = sizeVec(end);
                expArray = zeros(size(resArray));
                for i = 1:nPoints
                    [uMat, sMat] = eig(inp1Array(:,:,i));
                    if isVec
                        arg2Mat = inp2Array(:,i);
                    else
                        arg2Mat = inp2Array(:,:,i);
                    end
                    %
                    if isLrOp
                        tempMat = uMat * arg2Mat;
                        resMat = tempMat' * fOpFunc(sMat) * tempMat;
                    else
                        resMat = uMat' * fOpFunc(sMat) * uMat * arg2Mat;
                    end
                    %
                    if isVec
                        expArray(:,i) = resMat;
                    else
                        expArray(:,:,i) = resMat;
                    end
                end
                maxTol = max(abs(expArray(:) - resArray(:)));
                mlunitext.assert_equals(true, maxTol<=MAX_TOL)
            end
        end
    end
end