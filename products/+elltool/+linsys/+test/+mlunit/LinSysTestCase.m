classdef LinSysTestCase < mlunitext.test_case
    %
    methods
        function self = LinSysTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = testConstructor(self)
            clear uEllStruct;
            clear vEllStruct;
            clear wEllStruct;
            ell2d = ell_unitball(2);
            ell3d = ell_unitball(3);
            ell4d = ell_unitball(4);
            %
            % non-square matrix A
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3,4),eye(3),ell3d)',...
                'dimension:A');
            %
            % wrong type of matrix A
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(true(3),eye(3),ell3d)',...
                'type:A');
            %
            % incorrect dimension of matrix B
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(4,3),ell3d)',...
                'dimension:B');
            %
            % incorrect type of matrix B
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),true(3),ell3d)',...
                'type:B');
            %
            % incorrect dimension of U when U is a constant ellipsoid
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell4d)',...
                'dimension:P');
            %
            % incorrect dimension of U when U is a symbolic ellipsoid
            %
            uEllStruct.center = {'1';'1';'1';'1'};
            uEllStruct.shape = eye(3);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),uEllStruct)',...
                'dimension:P:center');
            %
            uEllStruct.center = {'1';'1';'1'};
            uEllStruct.shape = ones(4);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),uEllStruct)',...
                'dimension:P:shape');
            %
            % incorrect dimension of U when U is a constant vector
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),eye(4,1))',...
                'dimension:P');
            %
            % incorrect dimension of U when U is a symbolic vector
            %
            uCVec = {'t';'t';'t';'t'};
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),uCVec)',...
                'dimension:P');
            %
            % incorrect type of U when U is a vector
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),true(3,1))',...
                'type:P');
            %
            % incorrect type of U when U is a all-constant structure
            %
            uEllStruct.center = eye(3,1);
            uEllStruct.shape = eye(3);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),uEllStruct)',...
                'type:P');
            %
            % incorrect value of U when U.shape is non-symmetric cell matrix
            %
            uEllStruct.center = zeros(2,1);
            uEllStruct.shape = {'t','t^2';'t^3','t^4'};
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),uEllStruct)',...
                'value:P:shape');
            %
            % incorrect value of U when U.shape is non-symmetric
            % negative-defined constant matrix
            %
            uEllStruct.center = {'t';'t'};
            uEllStruct.shape = [1 2; 3 4];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),uEllStruct)',...
                'value:P:shape');
            %
            % incorrect value of U when U.shape is non-symmetric
            % positive-defined constant matrix
            %
            uEllStruct.center = {'t';'t'};
            uEllStruct.shape = [2 1; 3 2];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),uEllStruct)',...
                'value:P:shape');
            %
            % incorrect value of U when U.shape is symmetric but
            % negative-defined constant matrix
            %
            uEllStruct.center = {'t';'t'};
            uEllStruct.shape = [1 2; 2 1];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),uEllStruct)',...
                'value:P:shape');
            %
            % incorrect value of U when U.shape is symmetric but
            % non-negative-defined constant matrix
            %
            uEllStruct.center = {'t';'t'};
            uEllStruct.shape = [1 0; 0 0];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),uEllStruct)',...
                'value:P:shape');
            %
            % correct value of U when U.shape is symmetric and
            % positive-defined constant matrix
            %
            uEllStruct.center = {'t';'t'};
            uEllStruct.shape = [1 0; 0 1];
            elltool.linsys.LinSysFactory.create(eye(2),eye(2),uEllStruct);
            %
            % incorrect dimension of matrix G
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(4),ell4d)',...
                'dimension:C');
            %
            % incorrect type of matrix G
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,true(3),ell3d)',...
                'type:C');
            %
            % incorrect dimension of V when V is a constant ellipsoid
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),ell4d)',...
                'dimension:Q');
            %
            % incorrect dimension of V when V is a symbolic ellipsoid
            %
            vEllStruct.center = {'1';'1';'1';'1'};
            vEllStruct.shape = ones(3);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),vEllStruct)',...
                'dimension:Q:center');
            %
            vEllStruct.center = {'1';'1';'1'};
            vEllStruct.shape = ones(4);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),vEllStruct)',...
                'dimension:Q:shape');
            %
            % incorrect dimension of V when V is a constant vector
            %
            vVec = eye(4,1);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),vVec)',...
                'dimension:Q');
            %
            % incorrect dimension of V when V is a symbolic vector
            %
            vCVec = {'t';'t';'t';'t'};
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),vCVec)',...
                'dimension:Q');
            %
            % incorrect type of V when V is a vector
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),true(3,1))',...
                'type:Q');
            %
            % incorrect type of V when V is a all-constant structure
            %
            vEllStruct.center = eye(3,1);
            vEllStruct.shape = eye(3);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),vEllStruct)',...
                'type:Q');
            %
            % incorrect value of V when V.shape is non-symmetric cell matrix
            %
            vEllStruct.center = zeros(2,1);
            vEllStruct.shape = {'t','t^2';'t^3','t^4'};
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),vEllStruct)',...
                'value:Q:shape');
            %
            % incorrect value of V when V.shape is non-symmetric
            % negative-defined constant matrix
            %
            vEllStruct.center = {'t';'t'};
            vEllStruct.shape = [1 2; 3 4];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),vEllStruct)',...
                'value:Q:shape');
            %
            % incorrect value of V when V.shape is non-symmetric
            % positive-defined constant matrix
            %
            vEllStruct.center = {'t';'t'};
            vEllStruct.shape = [2 1; 3 2];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),vEllStruct)',...
                'value:Q:shape');
            %
            % incorrect value of V when V.shape is symmetric but
            % negative-defined constant matrix
            %
            vEllStruct.center = {'t';'t'};
            vEllStruct.shape = [1 2; 2 1];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),vEllStruct)',...
                'value:Q:shape');
            %
            % incorrect value of V when V.shape is symmetric but
            % non-negative-defined constant matrix
            %
            vEllStruct.center = {'t';'t'};
            vEllStruct.shape = [1 0; 0 0];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),vEllStruct)',...
                'value:Q:shape');
            %
            % correct value of V when V.shape is symmetric and
            % positive-defined constant matrix
            %
            vEllStruct.center = {'t';'t'};
            vEllStruct.shape = [1 0; 0 1];
            elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),vEllStruct);
            %
            % incorrect dimension of matrix C
            %
        end
        %
        function self = testDimension(self)
            %
            % test empty system
            %
            system = elltool.linsys.LinSysFactory.create([],[],[]);
            [nStates, nInputs,  nDistInputs] = system.dimension();
            obtainedVec = [nStates, nInputs,  nDistInputs];
            expectedVec = [0 0 0];
            mlunitext.assert_equals(all(expectedVec == obtainedVec), true);
            %
            % test simple system without disturbance
            %
            system = elltool.linsys.LinSysFactory.create(eye(2), eye(2,3), ell_unitball(3));
            [nStates, nInputs,  nDistInputs] = system.dimension();
            obtainedVec = [nStates, nInputs,  nDistInputs];
            expectedVec = [2 3 0];
            mlunitext.assert_equals(all(expectedVec == obtainedVec), true);
            %
            % test complex system with disturbance and noise
            %
            system = elltool.linsys.LinSysFactory.create(eye(5),eye(5,10),ell_unitball(10),...
                eye(5,11),ell_unitball(11),zeros(3,5),ell_unitball(3));
            [nStates, nInputs,  nDistInputs] = system.dimension();
            obtainedVec = [nStates, nInputs,  nDistInputs];
            expectedVec = [5 10 11];
            mlunitext.assert_equals(all(expectedVec == obtainedVec), true);
            %
            % test array of systems
            %
            systemMat = [system system; system system];
            [nStatesMat, nInputsMat, nDistInputsMat] =...
                systemMat.dimension();
            obtainedMat=[nStatesMat,nInputsMat,nDistInputsMat];
            expectedMat=[5*ones(2), 10*ones(2), 11*ones(2)];
            resultMat = (expectedMat(:) == obtainedMat(:));
            mlunitext.assert_equals(all(resultMat(:)), true);
            %
        end
        %
        function self = testIsDiscrete(self)
            aMat = eye(3);
            bMat = eye(3);
            cMat = eye(3);
            uEllipsoid = ell_unitball(3);
            uVec = {'k';'k';'k'};
            vVec = {'k';'k';'k'};
            %
            % test matrix of systems
            %
            systemCMat = {...
                elltool.linsys.LinSysFactory.create([],[],[]),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,[],[]),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,[],[],'c'),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,[],[],'d'),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uVec,[],vVec,'d'),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uVec,cMat,vVec,'d')}; 
            %
            isDisc = @(linSys) isa(linSys, 'elltool.linsys.LinSysDiscrete');
            obtainedMat = cellfun(isDisc, systemCMat);
            expectedMat = [false false false  false true true true];
            isEqMat = (obtainedMat == expectedMat);
            mlunitext.assert_equals(all(isEqMat(:)), true);
        end
        %
        function self = testIsLti(self)
            aMat = eye(3);
            bMat = eye(3);
            cMat = eye(3);
            vEllipsoid = ell_unitball(3);
            uEllipsoid = ell_unitball(3);
            aCMat = {'t','t','t';'t','t','t';'t','t','t'};
            bCMat = {'t','t','t';'t','t','t';'t','t','t'};
            cCMat = {'t','t','t';'t','t','t';'t','t','t'};
            %
            % test matrix of systems
            %
            systemMat = [...
                elltool.linsys.LinSysFactory.create([],[],[]),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,...
                cMat,vEllipsoid),...
                elltool.linsys.LinSysFactory.create(aCMat,bMat,uEllipsoid,...
                cMat,vEllipsoid);...
                elltool.linsys.LinSysFactory.create(aMat,bCMat,uEllipsoid,...
                cMat,vEllipsoid),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,...
                cCMat,vEllipsoid),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,...
                cMat,vEllipsoid)...
                ];
            obtainedMat = systemMat.isLti();
            expectedMat = [true true false; false false true];
            isEqMat = (obtainedMat == expectedMat);
            mlunitext.assert_equals(all(isEqMat(:)), true);
        end
        %
        function self = testIsEmpty(self)
            aMat = eye(3);
            bMat = eye(3);
            uEllipsoid = ell_unitball(3);
            %
            % test matrix of systems
            %
            systemMat = [...
                elltool.linsys.LinSysFactory.create(),...
                elltool.linsys.LinSysFactory.create([],[],[]);...
                elltool.linsys.LinSysFactory.create(aMat,bMat,[]),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid)...
                ];
            obtainedMat = systemMat.isEmpty();
            expectedMat = [true true; false false];
            eqMat = (obtainedMat == expectedMat);
            mlunitext.assert_equals(all(eqMat(:)), true);
        end
        %
        function self = testDisplay(self)
            uEll = struct();
            uEll.center = {'2 * cos(t)'; '0.5 * sin(t)'};
            uEll.shape = {'4 * t' '0'; '0' 't'};
            
            system = elltool.linsys.LinSysFactory.create(...
                {'t', '1', 'cos(t)'; '1' '0' 't'; 'sin(t)', 't', '2'}, ...
                {'t', 'cos(t)'; 'sin(t)', 't'; 'cos(t)', 'sin(t)'}, ...
                uEll, eye(3,5),ell_unitball(5),eye(2,3),ell_unitball(2));
            evalc('system.display();');
            resStr = evalc('display(system)');
            isOk = ~isempty(strfind(resStr,'A'));
            isOk = ~isempty(strfind(resStr,'B')) && isOk;
            isOk = ~isempty(strfind(resStr,'Control bound')) && isOk;
            isOk = ~isempty(strfind(resStr,'Disturbance bounds')) && isOk;
            mlunitext.assert(isOk);
        end
        %
        function self = testDisplayEmpty(self)
            system = elltool.linsys.LinSysContinuous.empty();
            system.display();
            resStr = evalc('system.display()');
            isOk = ~isempty(strfind(resStr, ...
                'Empty linear system object.'));
            %
            system = elltool.linsys.LinSysDiscrete.empty(2, 0, 5);
            system.display();
            resStr = evalc('system.display()');
            isOk = ~isempty(strfind(resStr, ...
                'Empty linear system objects array.')) && isOk;
            %
            mlunitext.assert(isOk);
        end
        %
        function self = testGetAbsTol(self)
            testAbsTol = 1e-8;
            args = {eye(3),eye(3,4),ell_unitball(4),...
                eye(3,5),ell_unitball(5),eye(2,3),...
                ell_unitball(2),'d','absTol',testAbsTol};
            systemArr = [elltool.linsys.LinSysFactory.create(args{:}),...
                elltool.linsys.LinSysFactory.create(args{:});...
                elltool.linsys.LinSysFactory.create(args{:}),...
                elltool.linsys.LinSysFactory.create(args{:})];
            systemArr(:,:,2) = [elltool.linsys.LinSysFactory.create(args{:}),...
                elltool.linsys.LinSysFactory.create(args{:});...
                elltool.linsys.LinSysFactory.create(args{:}),...
                elltool.linsys.LinSysFactory.create(args{:})];
            sizeArr = size(systemArr);
            testAbsTolArr = repmat(testAbsTol,sizeArr);
            %
            isOkArr = (testAbsTolArr == systemArr.getAbsTol());
            %
            isOk = all(isOkArr(:));
            mlunitext.assert(isOk);
        end
        %
        function self = testHasDisturbance(self)
            constantDistLinSys = elltool.linsys.LinSysFactory.create(eye(2), eye(2),...
                ellipsoid([0; 0], eye(2)), eye(2), [1; 1], 'd');
            boundedDistLinSys = elltool.linsys.LinSysFactory.create(eye(2), eye(2),...
                ellipsoid([0; 0], eye(2)), eye(2),...
                ellipsoid([0; 0], eye(2)), [], [], 'd');
            noDistLinSys = elltool.linsys.LinSysFactory.create(eye(2), eye(2),...
                ellipsoid([0; 0], eye(2)), [], [], 'd');
            %
            % test default behavior
            %
            mlunitext.assert_equals(...
                constantDistLinSys.hasDisturbance(), false);
            mlunitext.assert_equals(boundedDistLinSys.hasDisturbance(), true);
            mlunitext.assert_equals(noDistLinSys.hasDisturbance(), false);
            %
            % test isMeaningful
            %
            mlunitext.assert_equals(...
                boundedDistLinSys.hasDisturbance(true), true);
            mlunitext.assert_equals(...
                boundedDistLinSys.hasDisturbance(false), true);
            mlunitext.assert_equals(...
                constantDistLinSys.hasDisturbance(true), false);
            mlunitext.assert_equals(...
                constantDistLinSys.hasDisturbance(false), true);
            mlunitext.assert_equals(...
                noDistLinSys.hasDisturbance(true), false);
            mlunitext.assert_equals(...
                noDistLinSys.hasDisturbance(false), false);
        end
        %
        function self = testGetCopy(self)
            aMat = eye(3);
            bMat = eye(3);
            uEll = ellipsoid([0; 1; 2], eye(3));
            uStruct = struct();
            uStruct.center = [1; 1; 1];
            uStruct.shape = {'10' 't' '0'; 't' '2' '0'; '0' '0' '3'};
            cMat = eye(3);
            cCMat = {'1' '0' '0'; '0' 'sin(t)' '0'; '0' '0' '2'};
            vEll = ellipsoid(0.5 * eye(3));
            vStruct = struct();
            vStruct.center = [-1; 0; 1];
            vStruct.shape = {'1' '0' '0'; '0' 't' '0'; '0' '0' 't^3'};
            nEll = ellipsoid([1; 2; 3], eye(3));
            nStruct = struct();
            nStruct.center = [0; 0; 0];
            nStruct.shape = {'t' '0' '0'; '0' '1' '0'; '0' '0' 't'};
            lContsysMat(4, 4) = elltool.linsys.LinSysContinuous();
            lContsysMat(1) = create(uEll);
            lContsysMat(2) = create(uStruct);
            lContsysMat(3) = create(uEll, cMat, vEll);
            lContsysMat(4) = create(uEll, cMat, vStruct);
            lContsysMat(5) = create(uStruct, cMat, vEll);
            lContsysMat(6) = create(uStruct, cMat, vStruct);
            lDiscrsysMat(2, 1) = elltool.linsys.LinSysDiscrete();
            lDiscrsysMat(1) = create(uEll, [], [], 'd');
            lDiscrsysMat(2) = create(uEll, cMat, vEll, 'd');
            %
            copiedLContsysMat = lContsysMat.getCopy();
            isEqualMat = copiedLContsysMat.isEqual(lContsysMat);
            isOk = all(isEqualMat(:));
            mlunitext.assert_equals(true, isOk);
            %
            copiedLDiscrsysMat = lDiscrsysMat.getCopy();
            isEqualMat = copiedLDiscrsysMat.isEqual(lDiscrsysMat);
            isOk = all(isEqualMat(:));
            mlunitext.assert_equals(true, isOk);
            %
            firstCutLsysMat = lContsysMat(1 : 2, 1 : 2);
            secondCutLsysMat = lContsysMat(3 : 4, 3 : 4);
            thirdCutLsysMat = lContsysMat([1 3], [1 3]);
            self.runAndCheckError(...
                'copiedLContsysMat.isEqual(firstCutLsysMat)',...
                'wrongInput');
            isEqualMat = firstCutLsysMat.isEqual(secondCutLsysMat);
            isOk = ~any(isEqualMat(:));
            mlunitext.assert_equals(true, isOk);
            isEqualMat = firstCutLsysMat.isEqual(thirdCutLsysMat);
            isOkMat = isEqualMat == [1 0; 0 0];
            isOk = all(isOkMat(:));
            mlunitext.assert_equals(true, isOk);
            %
            function linsysObj = create(varargin)
                linsysObj = elltool.linsys.LinSysFactory.create(...
                    aMat, bMat, varargin{:});
            end
        end

    end
end