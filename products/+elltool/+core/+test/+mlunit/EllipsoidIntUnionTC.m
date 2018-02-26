classdef EllipsoidIntUnionTC < mlunitext.test_case
    %$Author: Vadim Kaushanskiy <vkaushanskiy@gmail.com>$
    %$Date: 2012-12-24 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2012 $
    %#ok<*NODEF>
    %#ok<*NASGU>
    properties (Access=private)
        testDataRootDir
        ellFactoryObj;
    end
    %
    methods
        function set_up_param(self)
            self.ellFactoryObj = elltool.core.test.mlunit.TEllipsoidFactory();
        end
    end
    methods
        function ellObj = ellipsoid(self, varargin)
            ellObj = self.ellFactoryObj.createInstance('ellipsoid', ...
                varargin{:});
        end
        function ellObj = ell_unitball(self, varargin)
            ellObj = elltool.core.test.mlunit.tell_unitball(...
                self.ellFactoryObj, varargin{:});
        end
        function ellObj = ell_enclose(self, varargin)
            ellObj = elltool.core.test.mlunit.tell_enclose(...
                self.ellFactoryObj, varargin{:});
        end
        function hpObj = hyperplane(self, varargin)
            hpObj = self.ellFactoryObj.createInstance('hyperplane', ...
                varargin{:});
        end
    end
    %
    methods
        function self = EllipsoidIntUnionTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,...
                'TestData',...
                filesep,shortClassName];

        end
        function setUpCheckSettings(self) %#ok<MANU>
            import elltool.conf.Properties;
            Properties.checkSettings();
        end
        function flexAssert(varargin)
            IS_ASSERTION_ON = true;
            if (IS_ASSERTION_ON)
                mlunitext.assert_equals(varargin{2:end});
            end
        end

        function self = testEllUnionEaSensitivity(self)
            import elltool.conf.Properties;
            self.setUpCheckSettings();
            relTol = Properties.getAbsTol();
            sensEPS = 0.000000001*relTol;
            load(strcat(self.testDataRootDir, strcat(filesep,...
                'testEllunionEa_inp.mat')), 'testEllCenterVec', ...
                'testEllMat', 'testEllCenter2Vec', 'testEll2Mat');
            testEllVec(2) = self.ellipsoid;
            testEllVec(1) = self.ellipsoid(testEllCenterVec, testEllMat);
            testEllVec(2) = self.ellipsoid(testEllCenter2Vec, testEll2Mat);
            resEllVec = ellunion_ea(testEllVec);

            testEllCenterVec = testEllCenterVec + sensEPS;
            testEllMat = testEllMat + sensEPS;
            testEllCenter2Vec = testEllCenter2Vec + sensEPS;
            testEll2Mat = testEll2Mat + sensEPS;

            testEllVec(1) = self.ellipsoid(testEllCenterVec, testEllMat);
            testEllVec(2) = self.ellipsoid(testEllCenter2Vec, testEll2Mat);

            resSensEllVec = ellunion_ea(testEllVec);

            [isEq, reportStr] = isEqual(resEllVec, resSensEllVec);
            mlunitext.assert_equals(true, isEq, reportStr);
        end

        function self = testEllIntersectionIaSensitivity(self)
            import elltool.conf.Properties;
            self.setUpCheckSettings();
            relTol = Properties.getAbsTol();
            sensEPS = relTol;

            load(strcat(self.testDataRootDir, strcat(filesep,...
                'testEllintersectionIa_inp.mat')), 'testEllCenterVec', ...
                'testEllMat', 'testEllCenter2Vec', 'testEll2Mat');
            testEllVec(2) = self.ellipsoid;
            testEllVec(1) = self.ellipsoid(testEllCenterVec, testEllMat);
            testEllVec(2) = self.ellipsoid(testEllCenter2Vec, testEll2Mat);
            resEllVec = ellintersection_ia(testEllVec);

            testEllCenterVec = testEllCenterVec + sensEPS;
            testEllMat = testEllMat + sensEPS;
            testEllCenter2Vec = testEllCenter2Vec + sensEPS;
            testEll2Mat = testEll2Mat + sensEPS;

            testEllVec(1) = self.ellipsoid(testEllCenterVec, testEllMat);
            testEllVec(2) = self.ellipsoid(testEllCenter2Vec, testEll2Mat);

            resSensEllVec = ellintersection_ia(testEllVec);

            [isEq, reportStr] = isEqual(resEllVec, resSensEllVec);
            mlunitext.assert_equals(true, isEq, reportStr);
        end

        function self = testDoesContain(self)
            self.setUpCheckSettings();
            testEll1Vec = self.ellipsoid(eye(3));
            testEll2Vec = self.ellipsoid([10, 0, 5]',...
                [1, 0, 0; 0, 0, 0; 0, 0, 1]);
            isTestResVec = doesContain(testEll1Vec, testEll2Vec);
            mlunitext.assert_equals(false, isTestResVec);

            %testEll1Vec = self.ellipsoid(eye(3));
            %testEll2Vec = self.ellipsoid([1, 0, 0; 0, 0, 0; 0, 0, 1]);
            %testResVec = doesContain(testEll1Vec, testEll2Vec);
            %mlunitext.assert_equals(true, testResVec);

            testEll1Vec = self.ellipsoid(eye(3));
            testEll2Vec = self.ellipsoid(eye(3));
            isTestResVec = doesContain(testEll1Vec, testEll2Vec);
            mlunitext.assert_equals(true, isTestResVec);

            testEll1Vec = self.ellipsoid(eye(3));
            testEll2Vec = self.ellipsoid([1e-4, 1e-4, 0]', eye(3));
            isTestResVec = doesContain(testEll1Vec, testEll2Vec);
            mlunitext.assert_equals(false, isTestResVec);

            testEll1Vec = self.ellipsoid(4*eye(2));
            testEll2Vec = self.ellipsoid([1, 0]', eye(2));
            isTestResVec = doesContain(testEll1Vec, testEll2Vec);
            mlunitext.assert_equals(true, isTestResVec);


            testEll1Vec = self.ellipsoid(eye(2));
            testEll2Vec = self.ellipsoid(zeros(2));
            isTestResVec = doesContain(testEll1Vec, testEll2Vec);
            mlunitext.assert_equals(true, isTestResVec);

            testEll1Vec = self.ellipsoid(eye(2));
            testEll2Vec = self.ellipsoid([1, 0; 0, 0]);
            isTestResVec = doesContain(testEll1Vec, testEll2Vec);
            mlunitext.assert_equals(true, isTestResVec);

            testEll1Vec = self.ellipsoid([1, 0, 0; 0, 0, 0; 0, 0, 1]);
            testEll2Vec = self.ellipsoid([1, 0, 0; 0, 0, 0; 0, 0, 0]);
            isTestResVec = doesContain(testEll1Vec, testEll2Vec);
            mlunitext.assert_equals(true, isTestResVec);
        end

        function self = testSqrtm(self)
            import elltool.conf.Properties;
            MAX_TOL = Properties.getAbsTol();
            test1Mat = eye(2);
            test2SqrtMat = eye(2) + 1.01*MAX_TOL;
            test2Mat = test2SqrtMat*test2SqrtMat.';
            [isEq, reportStr] = isEqual(self.ellipsoid(test1Mat), ...
                self.ellipsoid(test2Mat));
            mlunitext.assert_equals(false, isEq);
            ansStr = ...
                '\(1).QSqrt-->.*\(2).*tolerance.\(1.000000.*e\-05).*';
            ansAltStr=ansStr;
            checkRep();
            %
            test1Mat = eye(2);
            test2SqrtMat = eye(2) + 0.5*MAX_TOL;
            test2Mat = test2SqrtMat*test2SqrtMat.';
            [isEq, reportStr] = isEqual(self.ellipsoid(test1Mat),...
                self.ellipsoid(test2Mat));
            mlunitext.assert_equals(true, isEq);
            ansStr = '';
            checkRep();
            %
            test1Mat = eye(2);
            test2SqrtMat = eye(2) + MAX_TOL;
            test2Mat = test2SqrtMat*test2SqrtMat.';
            [isEq, reportStr] = isEqual(self.ellipsoid(test1Mat),...
                self.ellipsoid(test2Mat));
            mlunitext.assert_equals(false, isEq);
            mlunitext.assert_equals(false, isEq);
            ansStr = ...
                '\(1).QSqrt-->.*\(2).*tolerance.\(1.000000.*e\-05).*';
            ansAltStr=ansStr;
            %
            checkRep();
            function checkRep()
                isRepEq = isequal(reportStr, ansStr);
                if ~isRepEq
                    isRepEq = ~isempty(regexp(reportStr, ansStr, 'once'))||...
                        ~isempty(regexp(reportStr, ansAltStr, 'once'));
                end
                mlunitext.assert_equals(isRepEq, true);
            end
        end

        function testIsInternalCenter(self, ~)
            my1EllVec(2) = self.ellipsoid([5; 5; 5; 5], ...
                [4, 1, 1, 1; 1, 2, 1, 1; 1, 1, 5, 1; 1, 1, 1, 6], 2);
            my1EllVec(1) = self.ellipsoid([5; 5; 5; 5], ...
                [4, 1, 1, 1; 1, 2, 1, 1; 1, 1, 5, 1; 1, 1, 1, 6], 2);
            my2EllVec(2) = self.ell_unitball(4);
            my2EllVec(1) = self.ell_unitball(4);
            isOk = doesIntersectionContain(my2EllVec, my1EllVec, 'i');
            mlunitext.assert_equals(isOk,false);
        end

        function self = testIsInternal(self)
            nDim = 100;
            testEllVec = self.ellipsoid(zeros(nDim, 1), eye(nDim));
            testPointVec = zeros(nDim, 1);
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(1, testResVec);

            testPointVec(nDim) = 1;
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(1, testResVec);

            for iDim = 1:nDim
                testPointVec(iDim) = 1 / realsqrt(nDim);
            end
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(1, testResVec);

            testPointVec = ones(nDim, 1);
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(0, testResVec);

            for iDim = 1:nDim
                testPointVec(iDim) = 1 / realsqrt(nDim);
            end
            testPointVec(1) = testPointVec(1) + 1e-4;
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(0, testResVec);



            nDim = 3;
            testEllVec = self.ellipsoid(zeros(nDim, 1),...
                [1, 0, 0; 0, 2, 0; 0, 0, 0]);
            testPointVec = [0.3, -0.8, 0].';
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(1, testResVec);

            testPointVec = [0.3, -0.8, 1e-3].';
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(0, testResVec);

            nDim = 2;

            testEllVec(1) = self.ellipsoid(zeros(nDim, 1), eye(nDim));
            testEllVec(2) = self.ellipsoid([2, 0].', eye(nDim));
            testPointVec = [1, 0; 2, 0].';
            testResVec = isinternal(testEllVec, testPointVec, 'u');
            self.flexAssert([1, 1], testResVec);
            testResVec = isinternal(testEllVec, testPointVec, 'i');
            self.flexAssert([1, 0], testResVec);

            for iNum = 1:1000
                testEllVec(iNum) = self.ellipsoid(eye(2));
            end
            testPointVec = [0, 0].';
            testResVec = isinternal(testEllVec, testPointVec, 'i');
            self.flexAssert(1, testResVec);
            testResVec = isinternal(testEllVec, testPointVec, 'u');
            self.flexAssert(1, testResVec);
        end
        function self = testPolar(self)

            nDim = 100;
            testEllVec = self.ellipsoid(zeros(nDim, 1), eye(nDim));
            polarEllipsoid = polar(testEllVec);
            self.flexAssert(true, eq(testEllVec, polarEllipsoid));

            nDim = 100;
            testSingEllVec = self.ellipsoid(zeros(nDim, 1), zeros(nDim));
            self.runAndCheckError...
                ('polar(testSingEllVec)','degenerateEllipsoid');

            nDim = 3;
            testSingEllVec = self.ellipsoid(zeros(nDim, 1),...
                [1, 0, 0; 0, 2, 0; 0, 0, 0]);
            self.runAndCheckError...
                ('polar(testSingEllVec)','degenerateEllipsoid');

            nDim = 2;
            testEllVec = self.ellipsoid(zeros(nDim, 1), [2, 0; 0, 1]);
            polarEllVec = polar(testEllVec);
            ansEllVec = self.ellipsoid(zeros(nDim, 1), [0.5, 0; 0, 1]);
            self.flexAssert(true, eq(polarEllVec, ansEllVec));


            nDim = 2;
            testEllVec = self.ellipsoid([0, 0.5].', eye(2));
            polarEllVec = polar(testEllVec);
            ansEllVec = self.ellipsoid([0, -2/3].', [4/3, 0; 0, 16/9]);
            self.flexAssert(true, eq(polarEllVec, ansEllVec));
        end
        function self = testIntersect(self)
            %problem is infeasible
            nDim = 2;
            testEllVec(1) = self.ellipsoid(eye(nDim));
            testEllVec(2) = self.ellipsoid([2, 2].', eye(nDim));
            testHyperplane = self.hyperplane([1, 0].', 10);
            testResVec = intersect(testEllVec, testHyperplane, 'i');
            self.flexAssert(-1, testResVec);

            testEllVec_2 = self.ellipsoid(eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2, 'i');
            self.flexAssert(-1, testResVec);


            %empty intersection

            %with ellipsoid
            nDim = 2;
            testEllVec = self.ellipsoid(eye(nDim));
            testEllVec_2 = self.ellipsoid([1000, -1000].', eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2, 'i');
            self.flexAssert(0, testResVec);

            %degenerate ellipsoid
            nDim = 3;
            testEllVec = self.ellipsoid(eye(nDim));
            testEllVec_2 = self.ellipsoid([1, 0, 0; 0, 0, 0; 0, 0, 1]);
            testResVec = intersect(testEllVec, testEllVec_2);
            self.flexAssert(1, testResVec);

            nDim = 3;
            testEllVec = self.ellipsoid(eye(nDim));
            testEllVec_2 = self.ellipsoid([10, 0, 0].',...
                [1, 0, 0; 0, 0, 0; 0, 0, 1]);
            testResVec = intersect(testEllVec, testEllVec_2);
            self.flexAssert(0, testResVec);
            %with hyperplane

            nDim = 2;
            testEllVec = self.ellipsoid([1000, -1000].', eye(nDim));
            testHyperPlane = self.hyperplane([1, 0].', 10);
            testResVec = intersect(testEllVec, testHyperPlane);
            self.flexAssert(0, testResVec);

            %two ellipsoids
            nDim = 2;
            testEllVec(1) = self.ellipsoid(eye(nDim));
            testEllVec(2) = self.ellipsoid([1, 0].', eye(nDim));
            testEllVec_2 = self.ellipsoid([100, -100].', eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2, 'i');
            self.flexAssert(0, testResVec);
            %intersection is not empty

            nDim = 2;
            testEllVec = self.ellipsoid(eye(nDim));
            testResVec = intersect(testEllVec, testEllVec);
            self.flexAssert(1, testResVec);

            nDim = 2;
            testEllVec = self.ellipsoid(eye(nDim));
            testEllVec_2 = self.ellipsoid([2, 0].', eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2);
            self.flexAssert(1, testResVec);


            nDim = 2;
            testEllVec = self.ellipsoid(eye(nDim));
            testEllVec_2 = self.ellipsoid([1, 0].', eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2);
            self.flexAssert(1, testResVec);

            nDim = 2;
            testEllVec(1) = self.ellipsoid(eye(nDim));
            testEllVec(2) = self.ellipsoid([1, 0].', eye(nDim));
            testEllVec_2 = self.ellipsoid([0, 1].', eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2, 'i');
            self.flexAssert(1, testResVec);

            nDim = 2;
            testEllVec(1) = self.ellipsoid(eye(nDim));
            testEllVec(2) = self.ellipsoid([2, 0].', eye(nDim));
            testEllVec_2 = self.ellipsoid([1, 1].', eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2, 'u');
            self.flexAssert(1, testResVec);

            %hyperplane
            nDim = 2;
            testEllVec(1) = self.ellipsoid(eye(nDim));
            testEllVec(2) = self.ellipsoid([2, 0].', eye(nDim));
            testHp = self.hyperplane([1, 0].', 1);
            testResVec = intersect(testEllVec, testHp, 'i');
            self.flexAssert(1, testResVec);
            testResVec = intersect(testEllVec, testHp, 'u');
            self.flexAssert(1, testResVec);
            %test intersect(ell1Arr,ell2Arr), where ell1Arr and ell2Arr have
            %same sizes, and non-scalar
            for iEll = 12:-1:1
                testEllArr(iEll) = self.ellipsoid(eye(3));
            end
            testEllArr = reshape(testEllArr,2,3,2);
            testIntResArr = ones(size(testEllArr));
            intResArr = intersect(testEllArr,testEllArr);
            isOkArr = testIntResArr == intResArr;
            mlunitext.assert(all(isOkArr(:)));

        end

        function self = testEllintersectionIa(self)
            self.setUpCheckSettings()
            nDim = 10;
            nArr = 15;
            eyeEllipsoid = self.ellipsoid(eye(nDim));
            testEllCVec = cell(nArr,1);
            for iArr = 1:nArr
                testEllCVec{iArr} = eyeEllipsoid;
            end
            testEllVec = vertcat(testEllCVec{:});
            resEllVec = ellintersection_ia(testEllVec);
            ansEllVec = eyeEllipsoid;
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            self.flexAssert(true, isEq, reportStr);

            clear testEllVec;

            nDim = 2;
            testEllVec(1) = self.ellipsoid(eye(nDim));
            testEllVec(2) = self.ellipsoid([1, 0].', eye(nDim));
            resEllVec = ellintersection_ia(testEllVec);

            ansEllVec = self.ellipsoid([0.5, 0]', [0.235394505823186,...
                0; 0, 0.578464829541428]);
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            self.flexAssert(true, isEq, reportStr);
            self.flexAssert(true, doesContain(testEllVec(1), resEllVec));
            self.flexAssert(true, doesContain(testEllVec(2), resEllVec));

            clear testEllVec;
            nDim = 2;
            testEllVec(1) = self.ellipsoid(eye(nDim));
            testEllVec(2) = self.ellipsoid([1, 0].', eye(nDim));
            testEllVec(3) = self.ellipsoid([0, 1].', eye(nDim));
            resEllVec = ellintersection_ia(testEllVec);
            ansEllCenterVec =  [0.407334113249147, 0.407334108829435].';
            ansEllMat = [0.125814744141070, 0.053912566043053;...
                0.053912566043053, 0.125814738841440];
            ansEllVec = self.ellipsoid(ansEllCenterVec, ansEllMat);
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            self.flexAssert(true, isEq, reportStr);
            self.flexAssert(true, doesContain(testEllVec(1), resEllVec));
            self.flexAssert(true, doesContain(testEllVec(2), resEllVec));
            self.flexAssert(true, doesContain(testEllVec(3), resEllVec));


            clear testEllVec;
            nDim = 3;
            testEllVec(1) = self.ellipsoid(eye(nDim));
            testEllVec(2) = self.ellipsoid([1, 0.5, -0.5].', ...
                [2, 0, 0; 0, 1, 0; 0, 0, 0.5]);
            testEllVec(3) = self.ellipsoid([0.5, 0.3, 1].', ...
                [0.5, 0, 0; 0, 0.5, 0; 0, 0, 2]);
            resEllVec = ellintersection_ia(testEllVec);

            ansEllCenterVec = [0.513846517075189, ...
                0.321868721330990, -0.100393450228106].';
            ansEllMat = [0.156739727326948, -0.005159338786834,...
                0.011041318375176; -0.005159338786834, 0.161491682085078,...
                0.014052111019755; 0.011041318375176,...
                0.014052111019755, 0.062235791525665];
            ansEllVec = self.ellipsoid(ansEllCenterVec, ansEllMat);
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            self.flexAssert(true, isEq, reportStr);
            self.flexAssert(true, doesContain(testEllVec(1), resEllVec));
            self.flexAssert(true, doesContain(testEllVec(2), resEllVec));
            self.flexAssert(true, doesContain(testEllVec(3), resEllVec));

            clear testEllVec;
            load(strcat(self.testDataRootDir, strcat(filesep,...
                'testEllintersection_inpSimple.mat')), 'testEllCenterVec',...
                'testEllMat', 'testEllCenter2Vec', 'testEll2Mat');
            testEllVec(1) = self.ellipsoid(testEllCenterVec, testEllMat);
            testEllVec(2) = self.ellipsoid(testEllCenter2Vec, testEll2Mat);
            resEllVec = ellintersection_ia(testEllVec);
            load(strcat(self.testDataRootDir, strcat(filesep,...
                'testEllintersection_outSimple.mat')), ...
                'ansEllCenterVec', 'ansEllMat');
            ansEllVec = self.ellipsoid(ansEllCenterVec, ansEllMat);
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            self.flexAssert(true, isEq, reportStr);
            self.flexAssert(true, doesContain(testEllVec(1), resEllVec));
            self.flexAssert(true, doesContain(testEllVec(2), resEllVec));

            clear testEllVec;
            load(strcat(self.testDataRootDir, strcat(filesep,...
                'testEllintersectionIa_inp.mat')), 'testEllCenterVec', ...
                'testEllMat', 'testEllCenter2Vec', 'testEll2Mat');
            testEllVec(1) = self.ellipsoid(testEllCenterVec, testEllMat);
            testEllVec(2) = self.ellipsoid(testEllCenter2Vec, testEll2Mat);
            resEllVec = ellintersection_ia(testEllVec);
            load(strcat(self.testDataRootDir, strcat(filesep, ...
                'testEllintersectionIa_out.mat')),...
                'ansEllCenterVec', 'ansEllMat');
            ansEllVec = self.ellipsoid(ansEllCenterVec, ansEllMat);
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            self.flexAssert(1, isEq, reportStr);
            self.flexAssert(1, doesContain(testEllVec(1), resEllVec));
            self.flexAssert(1, doesContain(testEllVec(2), resEllVec));

            clear testEllVec;
            nDim = 2;
            testEllVec(1) = self.ellipsoid(eye(nDim));
            testEllVec(2) = self.ellipsoid([100, 0]', eye(nDim));

            self.runAndCheckError('testEllVec.ellintersection_ia()',...
                'ELLIPSOID:ELLINTERSECTION_IA:cvxError');
            nDim = 3;
            checkIfSameCentersEll(eye(nDim),...
                [2, 0.7, 0;...
                0.7, 1, 0.3;...
                0, 0.3, 0.5]);

            checkIfSameCentersEll(...
                [4, 0.5, 0.8;...
                0.5, 1, -1;...
                0.8, -1, 3],...
                ...
                [3, 0.5, -0.8;...
                0.5, 2, 1;...
                -0.8, 1, 1]);

            function checkIfSameCentersEll(firstEllShMat,secEllShMat)

                firstTestEllVec(1) = self.ellipsoid(firstEllShMat);
                firstTestEllVec(2) = self.ellipsoid(secEllShMat);

                secTestEllVec = [firstTestEllVec firstTestEllVec(2)];

                firstResEllVec = ellintersection_ia(firstTestEllVec);
                secResEllVec = ellintersection_ia(secTestEllVec);

                [isEq, reportStr] = isEqual(firstResEllVec, secResEllVec);
                self.flexAssert(true, isEq, reportStr);
            end

        end
        function self = testEllunionEa(self)
            self.setUpCheckSettings();
            nDim = 10;

            nArr = 15;
            eyeEllipsoid = self.ellipsoid(eye(nDim));
            testEllCVec = cell(nArr,1);
            for iArr = 1:nArr
                testEllCVec{iArr} = eyeEllipsoid;
            end
            testEllVec = vertcat(testEllCVec{:});
            resEllVec = ellunion_ea(testEllVec);
            ansEllVec = eyeEllipsoid;
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            self.flexAssert(true, isEq, reportStr);

            clear testEllVec;
            nDim = 2;
            testEllVec(1) = self.ellipsoid(eye(nDim));
            testEllVec(2) = self.ellipsoid([1, 0].', eye(nDim));
            resEllVec = ellunion_ea(testEllVec);

            ansEllVec = self.ellipsoid([0.5, 0].', [2.389605510164642, ...
                0; 0, 1.296535157845836]);
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            self.flexAssert(true, isEq, reportStr);
            self.flexAssert(true, doesContain(resEllVec, testEllVec(1)));
            self.flexAssert(true, doesContain(resEllVec, testEllVec(2)));

            clear testEllVec;
            nDim = 2;
            testEllVec(1) = self.ellipsoid(eye(nDim));
            testEllVec(2) = self.ellipsoid([1, 0].', eye(nDim));
            testEllVec(3) = self.ellipsoid([0, 1].', eye(nDim));
            resEllVec = ellunion_ea(testEllVec);
            ansEllVec = self.ellipsoid([0.361900110249858, ...
                0.361900133569072].', [2.713989398757731, ...
                -0.428437874833322;-0.428437874833322, 2.713989515632939]);
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            self.flexAssert(true, isEq, reportStr);
            self.flexAssert(true, doesContain(resEllVec, testEllVec(1)));
            self.flexAssert(true, doesContain(resEllVec, testEllVec(2)));
            self.flexAssert(true, doesContain(resEllVec, testEllVec(3)));


            nDim = 3;
            testEllVec(1) = self.ellipsoid(eye(nDim));
            testEllVec(2) = self.ellipsoid([1, 0.5, -0.5].', ...
                [2, 0, 0; 0, 1, 0; 0, 0, 0.5]);
            testEllVec(3) = self.ellipsoid([0.5, 0.3, 1].', ...
                [0.5, 0, 0; 0, 0.5, 0; 0, 0, 2]);
            resEllVec = ellunion_ea(testEllVec);

            ansEllShape = [3.214279075152898 0.597782711155458 ...
                -0.610826375241159; 0.597782711155458 1.826390617268878 ...
                -0.135640717373030;-0.610826375241159 ...
                -0.135640717373030 4.757741393980497];
            ansEllCenterVec = [0.678847905650305, 0.271345357930677, ...
                0.242812593977658].';
            ansEllVec = self.ellipsoid(ansEllCenterVec, ansEllShape);

            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            self.flexAssert(true, isEq, reportStr);
            self.flexAssert(true, doesContain(resEllVec, testEllVec(1)));
            self.flexAssert(true, doesContain(resEllVec, testEllVec(2)));
            self.flexAssert(true, doesContain(resEllVec, testEllVec(3)));

            clear testEllVec;
            nDim = 15;
            load(strcat(self.testDataRootDir, strcat(filesep, ...
                'testEllunion_inpSimple.mat')), 'testEllCenterVec', ...
                'testEllMat', 'testEllCenter2Vec', 'testEll2Mat');
            testEllVec(1) = self.ellipsoid(testEllCenterVec, testEllMat);
            testEllVec(2) = self.ellipsoid(testEllCenter2Vec, testEll2Mat);
            resEllVec = ellunion_ea(testEllVec);
            load(strcat(self.testDataRootDir, strcat(filesep, ...
                'testEllunion_outSimple.mat')), ...
                'ansEllCenterVec', 'ansEllMat');
            ansEllVec = self.ellipsoid(ansEllCenterVec, ansEllMat);
            self.flexAssert(true, doesContain(resEllVec, testEllVec(1)));
            self.flexAssert(true, doesContain(resEllVec, testEllVec(2)));
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            self.flexAssert(true, isEq, reportStr);
            clear testEllVec;
            nDim = 15;
            load(strcat(self.testDataRootDir, strcat(filesep,...
                'testEllunionEa_inp.mat')), 'testEllCenterVec', ...
                'testEllMat', 'testEllCenter2Vec', 'testEll2Mat');
            testEllVec(1) = self.ellipsoid(testEllCenterVec, testEllMat);
            testEllVec(2) = self.ellipsoid(testEllCenter2Vec, testEll2Mat);
            resEllVec = ellunion_ea(testEllVec);
            load(strcat(self.testDataRootDir, strcat(filesep, ...
                'testEllunionEa_out.mat')), 'ansEllCenterVec', 'ansEllMat');
            ansEllVec = self.ellipsoid(ansEllCenterVec, ansEllMat);
            self.flexAssert(true, doesContain(resEllVec, testEllVec(1)));
            self.flexAssert(true, doesContain(resEllVec, testEllVec(2)));
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            self.flexAssert(false, isEq, reportStr);
        end
        function self = testHpIntersection(self)
            %empty intersection
            nDim = 2;
            testEllVec = self.ellipsoid([100, -100]', eye(nDim));
            testHpVec = self.hyperplane([0 -1]', 1);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = self.ellipsoid;
            self.flexAssert(true, eq(resEllVec, ansEllVec));

            nDim = 2;
            testEllVec = self.ellipsoid(eye(nDim));
            testHpVec = self.hyperplane([1, 0].', 0);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = self.ellipsoid([0, 0; 0, 1]);
            self.flexAssert(true, eq(resEllVec, ansEllVec));

            nDim = 2;
            testEllVec = self.ellipsoid(eye(nDim));
            testHpVec = self.hyperplane([0, 1].', 0);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = self.ellipsoid([1, 0; 0, 0]);
            self.flexAssert(true, eq(resEllVec, ansEllVec));

            nDim = 2;
            testEllVec = self.ellipsoid(eye(nDim));
            testHpVec = self.hyperplane([1, 1].', 0);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = self.ellipsoid([0.5, -0.5; -0.5, 0.5]);
            self.flexAssert(true, eq(resEllVec, ansEllVec));

            nDim = 2;
            testEllVec = self.ellipsoid(eye(nDim));
            testHpVec = self.hyperplane([1, 0].', 1);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = self.ellipsoid([1, 0].', [0, 0; 0, 0]);
            self.flexAssert(true, eq(resEllVec, ansEllVec));

            nDim = 3;
            testEllVec = self.ellipsoid(eye(nDim));
            testHpVec = self.hyperplane([0, 0, 1].', 0);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = self.ellipsoid([1, 0, 0; 0, 1, 0; 0, 0, 0]);
            self.flexAssert(true, eq(resEllVec, ansEllVec));

            nDim = 3;
            testEllVec = self.ellipsoid([3, 0, 0; 0, 2, 0; 0, 0, 4]);
            testHpVec = self.hyperplane([0, 1, 0].', 0);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = self.ellipsoid([3, 0, 0; 0, 0, 0; 0, 0, 4]);
            self.flexAssert(true, eq(resEllVec, ansEllVec));


            nDim = 3;
            testEllVec = self.ellipsoid(eye(3));
            testHpVec = self.hyperplane([1, 1, 1].', 0);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = self.ellipsoid([2/3, -1/3, -1/3; -1/3, 2/3, -1/3; ...
                -1/3, -1/3, 2/3]);
            self.flexAssert(true, eq(resEllVec, ansEllVec));



            nDim = 3;
            testEllVec = self.ellipsoid([1, 0, 0; 0, 1, 0; 0, 0, 4]);
            testHpVec = self.hyperplane([0, 0, 1].', 2);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = self.ellipsoid([0, 0, 2].', ...
                [0, 0, 0; 0, 0, 0; 0, 0, 0]);
            self.flexAssert(true, eq(resEllVec, ansEllVec));

            nDim = 100;
            testEllVec = self.ellipsoid(eye(nDim));
            PlaneNorm = zeros(nDim, 1);
            PlaneNorm(1) = 1;
            testHpVec = self.hyperplane(PlaneNorm, 0);

            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllMat = eye(nDim);
            ansEllMat(1) = 0;
            ansEllVec = self.ellipsoid(zeros(nDim, 1), ansEllMat);
            self.flexAssert(true, eq(resEllVec, ansEllVec));


            %two output arguments
            nDim = 2;
            testEllVec = self.ellipsoid([100, -100].', eye(nDim));
            testHpVec = self.hyperplane([0 -1].', 1);
            [resEllVec, isnIntersected] = hpintersection(testEllVec, ...
                testHpVec);
            ansEllVec = self.ellipsoid;
            self.flexAssert(true, eq(resEllVec, ansEllVec));
            self.flexAssert(true, isnIntersected);

            nDim = 2;
            testEllMat(1, 1) = self.ellipsoid([100, -100].', eye(nDim));
            testHpMat(1, 1) = self.hyperplane([0 -1].', 1);
            testEllMat(2, 2) = self.ellipsoid([100, -100].', eye(nDim));
            testHpMat(2, 2) = self.hyperplane([0 -1].', 1);
            testEllMat(1, 2) = self.ellipsoid(eye(nDim));
            testHpMat(1, 2) = self.hyperplane([0, 1].', 0);
            testEllMat(2, 1) = self.ellipsoid(eye(nDim));
            testHpMat(2, 1) = self.hyperplane([0, 1].', 0);
            [resEllMat, isnIntersected] = hpintersection(testEllMat, ...
                testHpMat);

            clear ansEllMat;
            ansEllMat(1, 1) = self.ellipsoid;
            ansEllMat(2, 2) = self.ellipsoid;
            ansEllMat(1, 2) = self.ellipsoid([1, 0; 0, 0]);
            ansEllMat(2, 1) = self.ellipsoid([1, 0; 0, 0]);
            ansIsnIntersectedMat = [true, false; false, true];
            self.flexAssert([true, true; true, true], eq(resEllMat, ...
                ansEllMat));
            self.flexAssert(ansIsnIntersectedMat, isnIntersected);

            %Arrays
            arrSizeVec=[2,2,2];
            nElem=prod(arrSizeVec);
            testEll1=self.ellipsoid(eye(3));
            testEll2=self.ellipsoid([2/3, -1/3, -1/3; -1/3, 2/3, -1/3; ...
                -1/3, -1/3, 2/3]);
            ellArr(nElem)=self.ellipsoid();
            arrayfun(@(x)fCopyEll(x,testEll1),1:prod(arrSizeVec));
            ellArr=reshape(ellArr,arrSizeVec);

            testHp = self.hyperplane([1, 1, 1].', 0);
            resEllArr = hpintersection(ellArr, testHp);
            ellArr(nElem)=self.ellipsoid();
            ellArr=reshape(ellArr,arrSizeVec);
            arrayfun(@(x)fCopyEll(x,testEll2),1:prod(arrSizeVec));

            isEqArr = eq(resEllArr, ellArr);
            self.flexAssert(true, all(isEqArr(:)));

            testHpArr = repmat(self.hyperplane([0, 0, 1].', 2),[2,2,2]);
            testEll = self.ellipsoid(eye(3));
            [resEllArr, isnIntersecArr] = ...
                hpintersection(testEll, testHpArr);
            self.flexAssert(true([2,2,2]), resEllArr.isEmpty());
            self.flexAssert(true([2,2,2]), isnIntersecArr);
            function fCopyEll(index,ellObj)
                ellArr(index)=ellObj;
            end
        end

        function self = testEllEnclose(self)
            self.setUpCheckSettings()
            pointsVec = [1, 0, -1, 0; 0, 1, 0, -1];
            resEllVec = self.ell_enclose(pointsVec);
            ansEllVec = self.ellipsoid([0, 0].', eye(2));
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            mlunitext.assert_equals(true, isEq, reportStr);


            pointsVec = [2, 0, -2, 0; 0, 1/3, 0, -1/3];
            resEllVec = self.ell_enclose(pointsVec);
            ansEllVec = self.ellipsoid([0, 0].', [4, 0; 0, 1/9]);
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            mlunitext.assert_equals(true, isEq, reportStr);

            pointsVec = [1/2, 0, 0, 0; 0, 0, 0, -3];
            resEllVec = self.ell_enclose(pointsVec);
            ansEllVec = self.ellipsoid([1/6, -1].', [1/9, 1/3; 1/3, 4]);
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            mlunitext.assert_equals(true, isEq, reportStr);

            phiAngleVec = 0:0.1:2*pi;
            psiAngleVec = 0:0.1:pi;
            pointsVec = zeros(3, numel(phiAngleVec)*numel(psiAngleVec));
            for iAngle = 1:numel(phiAngleVec)
                for jAngle = 1:numel(psiAngleVec)
                    pointsVec(1, (iAngle-1)*numel(psiAngleVec) + jAngle)...
                        = cos(phiAngleVec(iAngle))*sin(psiAngleVec(jAngle));
                    pointsVec(2, (iAngle-1)*numel(psiAngleVec) + jAngle)...
                        = sin(phiAngleVec(iAngle))*sin(psiAngleVec(jAngle));
                    pointsVec(3, (iAngle-1)*numel(psiAngleVec) + jAngle)...
                        = cos(psiAngleVec(jAngle));
                end
            end
            resEllVec = self.ell_enclose(pointsVec);
            ansEllVec = self.ellipsoid([0, 0, 0].', eye(3));
            [isEq, reportStr] = isEqual(resEllVec, ansEllVec);
            mlunitext.assert_equals(true, isEq, reportStr);

        end
%
     end

end
