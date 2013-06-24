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
                'dimension:U');
            %
            % incorrect dimension of U when U is a symbolic ellipsoid
            %
            uEllStruct.center = {'1';'1';'1';'1'};
            uEllStruct.shape = eye(3);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),uEllStruct)',...
                'dimension:uBoundsEll:center');
            %
            uEllStruct.center = {'1';'1';'1'};
            uEllStruct.shape = ones(4);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),uEllStruct)',...
                'dimension:uBoundsEll:shape');
            %
            % incorrect dimension of U when U is a constant vector
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),eye(4,1))',...
                'dimension:U');
            %
            % incorrect dimension of U when U is a symbolic vector
            %
            uCVec = {'t';'t';'t';'t'};
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),uCVec)',...
                'dimension:U');
            %
            % incorrect type of U when U is a vector
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),true(3,1))',...
                'type:U');
            %
            % incorrect type of U when U is a all-constant structure
            %
            uEllStruct.center = eye(3,1);
            uEllStruct.shape = eye(3);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),uEllStruct)',...
                'type:uBoundsEll');
            %
            % incorrect value of U when U.shape is non-symmetric cell matrix
            %
            uEllStruct.center = zeros(2,1);
            uEllStruct.shape = {'t','t^2';'t^3','t^4'};
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),uEllStruct)',...
                'value:uBoundsEll:shape');
            %
            % incorrect value of U when U.shape is non-symmetric
            % negative-defined constant matrix
            %
            uEllStruct.center = {'t';'t'};
            uEllStruct.shape = [1 2; 3 4];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),uEllStruct)',...
                'value:uBoundsEll:shape');
            %
            % incorrect value of U when U.shape is non-symmetric
            % positive-defined constant matrix
            %
            uEllStruct.center = {'t';'t'};
            uEllStruct.shape = [2 1; 3 2];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),uEllStruct)',...
                'value:uBoundsEll:shape');
            %
            % incorrect value of U when U.shape is symmetric but
            % negative-defined constant matrix
            %
            uEllStruct.center = {'t';'t'};
            uEllStruct.shape = [1 2; 2 1];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),uEllStruct)',...
                'value:uBoundsEll:shape');
            %
            % incorrect value of U when U.shape is symmetric but
            % non-negative-defined constant matrix
            %
            uEllStruct.center = {'t';'t'};
            uEllStruct.shape = [1 0; 0 0];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),uEllStruct)',...
                'value:uBoundsEll:shape');
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
                'dimension:G');
            %
            % incorrect type of matrix G
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,true(3),ell3d)',...
                'type:G');
            %
            % incorrect dimension of V when V is a constant ellipsoid
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),ell4d)',...
                'dimension:V');
            %
            % incorrect dimension of V when V is a symbolic ellipsoid
            %
            vEllStruct.center = {'1';'1';'1';'1'};
            vEllStruct.shape = ones(3);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),vEllStruct)',...
                'dimension:distBoundsEll:center');
            %
            vEllStruct.center = {'1';'1';'1'};
            vEllStruct.shape = ones(4);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),vEllStruct)',...
                'dimension:distBoundsEll:shape');
            %
            % incorrect dimension of V when V is a constant vector
            %
            vVec = eye(4,1);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),vVec)',...
                'dimension:V');
            %
            % incorrect dimension of V when V is a symbolic vector
            %
            vCVec = {'t';'t';'t';'t'};
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),vCVec)',...
                'dimension:V');
            %
            % incorrect type of V when V is a vector
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),true(3,1))',...
                'type:V');
            %
            % incorrect type of V when V is a all-constant structure
            %
            vEllStruct.center = eye(3,1);
            vEllStruct.shape = eye(3);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),vEllStruct)',...
                'type:distBoundsEll');
            %
            % incorrect value of V when V.shape is non-symmetric cell matrix
            %
            vEllStruct.center = zeros(2,1);
            vEllStruct.shape = {'t','t^2';'t^3','t^4'};
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),vEllStruct)',...
                'value:distBoundsEll:shape');
            %
            % incorrect value of V when V.shape is non-symmetric
            % negative-defined constant matrix
            %
            vEllStruct.center = {'t';'t'};
            vEllStruct.shape = [1 2; 3 4];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),vEllStruct)',...
                'value:distBoundsEll:shape');
            %
            % incorrect value of V when V.shape is non-symmetric
            % positive-defined constant matrix
            %
            vEllStruct.center = {'t';'t'};
            vEllStruct.shape = [2 1; 3 2];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),vEllStruct)',...
                'value:distBoundsEll:shape');
            %
            % incorrect value of V when V.shape is symmetric but
            % negative-defined constant matrix
            %
            vEllStruct.center = {'t';'t'};
            vEllStruct.shape = [1 2; 2 1];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),vEllStruct)',...
                'value:distBoundsEll:shape');
            %
            % incorrect value of V when V.shape is symmetric but
            % non-negative-defined constant matrix
            %
            vEllStruct.center = {'t';'t'};
            vEllStruct.shape = [1 0; 0 0];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),vEllStruct)',...
                'value:distBoundsEll:shape');
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
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,[],[],eye(4))',...
                'dimension:C');
            %
            % incorrect type of matrix C
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,[],[],true(3))',...
                'type:C');
            %
            % incorrect dimension of W when W is a constant ellipsoid
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),ell3d,eye(3),ell4d)',...
                'dimension:W');
            %
            % incorrect dimension of W when W is a symbolic ellipsoid
            %
            wEllStruct.center = {'1';'1';'1';'1'};
            wEllStruct.shape = ones(3);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),ell3d,eye(3),wEllStruct)',...
                'dimension:noiseBoundsEll:center');
            %
            wEllStruct.center = {'1';'1';'1'};
            wEllStruct.shape = ones(4);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),ell3d,eye(3),wEllStruct)',...
                'dimension:noiseBoundsEll:shape');
            %
            % incorrect dimension of W when W is a constant vector
            %
            wVec = eye(4,1);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),ell3d,eye(3),wVec)',...
                'dimension:W');
            %
            % incorrect dimension of W when W is a symbolic vector
            %
            wCVec = {'t';'t';'t';'t'};
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),ell3d,eye(3),wCVec)',...
                'dimension:W');
            %
            % incorrect type of W when W is a vector
            %
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),ell3d,eye(3),true(3,1))',...
                'type:W');
            %
            % incorrect type of W when W is a all-constant structure
            %
            wEllStruct.center = eye(3,1);
            wEllStruct.shape = eye(3);
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),ell3d,eye(3),wEllStruct)',...
                'type:noiseBoundsEll');
            %
            % incorrect value of W when W.shape is non-symmetric cell matrix
            %
            wEllStruct.center = zeros(2,1);
            wEllStruct.shape = {'t','t^2';'t^3','t^4'};
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),ell2d,eye(2),wEllStruct)',...
                'value:noiseBoundsEll:shape');
            %
            % incorrect value of W when W.shape is non-symmetric
            % negative-defined constant matrix
            %
            wEllStruct.center = {'t';'t'};
            wEllStruct.shape = [1 2; 3 4];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),ell2d,eye(2),wEllStruct)',...
                'value:noiseBoundsEll:shape');
            %
            % incorrect value of W when W.shape is non-symmetric
            % positive-defined constant matrix
            %
            wEllStruct.center = {'t';'t'};
            wEllStruct.shape = [2 1; 3 2];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),ell2d,eye(2),wEllStruct)',...
                'value:noiseBoundsEll:shape');
            %
            % incorrect value of W when W.shape is symmetric but
            % negative-defined constant matrix
            %
            wEllStruct.center = {'t';'t'};
            wEllStruct.shape = [1 2; 2 1];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),ell2d,eye(2),wEllStruct)',...
                'value:noiseBoundsEll:shape');
            %
            % incorrect value of W when W.shape is symmetric but
            % non-negative-defined constant matrix
            %
            wEllStruct.center = {'t';'t'};
            wEllStruct.shape = [1 0; 0 0];
            self.runAndCheckError(...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),ell2d,eye(2),wEllStruct)',...
                'value:noiseBoundsEll:shape');
            %
            % correct value of W when W.shape is symmetric and
            % positive-defined constant matrix
            %
            wEllStruct.center = {'t';'t'};
            wEllStruct.shape = [1 0; 0 1];
            elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),ell2d,eye(2),wEllStruct);
            %
        end
        %
        function self = testDimension(self)
            %
            % test empty system
            %
            system = elltool.linsys.LinSysFactory.create([],[],[]);
            [nStates, nInputs, nOutputs, nDistInputs] = system.dimension();
            obtainedVec = [nStates, nInputs, nOutputs, nDistInputs];
            expectedVec = [0 0 0 0];
            mlunitext.assert_equals(all(expectedVec == obtainedVec), true);
            %
            % test simple system without disturbance
            %
            system = elltool.linsys.LinSysFactory.create(eye(2), eye(2,3), ell_unitball(3));
            [nStates, nInputs, nOutputs, nDistInputs] = system.dimension();
            obtainedVec = [nStates, nInputs, nOutputs, nDistInputs];
            expectedVec = [2 3 2 0];
            mlunitext.assert_equals(all(expectedVec == obtainedVec), true);
            %
            % test complex system with disturbance and noise
            %
            system = elltool.linsys.LinSysFactory.create(eye(5),eye(5,10),ell_unitball(10),...
                eye(5,11),ell_unitball(11),zeros(3,5),ell_unitball(3));
            [nStates, nInputs, nOutputs, nDistInputs] = system.dimension();
            obtainedVec = [nStates, nInputs, nOutputs, nDistInputs];
            expectedVec = [5 10 3 11];
            mlunitext.assert_equals(all(expectedVec == obtainedVec), true);
            %
            % test array of systems
            %
            systemMat = [system system; system system];
            [nStatesMat, nInputsMat, nOutputsMat, nDistInputsMat] =...
                systemMat.dimension();
            obtainedMat=[nStatesMat,nInputsMat,nOutputsMat,nDistInputsMat];
            expectedMat=[5*ones(2), 10*ones(2), 3*ones(2), 11*ones(2)];
            resultMat = (expectedMat(:) == obtainedMat(:));
            mlunitext.assert_equals(all(resultMat(:)), true);
            %
        end
        %
        function self = testHasNoise(self)
            aMat = eye(3);
            bMat = eye(3);
            cMat = eye(3);
            gMat = eye(3);
            uEllipsoid = ell_unitball(3);
            vEllipsoid = ell_unitball(3);
            wVec = eye(3,1);
            wCVec = {'t';'t';'t'};
            wEllipsoid = ell_unitball(3);
            wEllStuct.shape = {'t','t','t';'t','t','t';'t','t','t'};
            wEllStuct.center = {'t';'t';'t'};
            %
            % test matrix of systems
            %
            systemMat = [...
                elltool.linsys.LinSysFactory.create([],[],[]),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,...
                gMat,vEllipsoid,cMat,[]),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,...
                gMat,vEllipsoid,cMat,wVec); ...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,...
                gMat,vEllipsoid,cMat,wCVec), ...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,...
                gMat,vEllipsoid,cMat,wEllipsoid),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,...
                gMat,vEllipsoid,cMat,wEllStuct)...
                ];
            obtainedMat = systemMat.hasnoise();
            expectedMat = [false false true; true true true];
            eqMat = (obtainedMat == expectedMat);
            mlunitext.assert_equals(all(eqMat(:)), true);
        end
        %
        function self = testIsDiscrete(self)
            aMat = eye(3);
            bMat = eye(3);
            cMat = eye(3);
            uEllipsoid = ell_unitball(3);
            uVec = {'k';'k';'k'};
            vVec = {'k';'k';'k'};
            wVec = {'k';'k';'k'};
            %
            % test matrix of systems
            %
            systemCMat = {...
                elltool.linsys.LinSysFactory.create([],[],[]),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,[],[],cMat,[]);...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,[],[],cMat,[],'c'),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,[],[],cMat,[],'d'),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uVec,[],vVec,cMat,wVec,'d')...
                }; 
            isDisc = @(linSys) isa(linSys, 'elltool.linsys.LinSysDiscrete');
            obtainedMat = cellfun(isDisc, systemCMat);
            expectedMat = [false false false; false true true];
            eqMat = (obtainedMat == expectedMat);
            mlunitext.assert_equals(all(eqMat(:)), true);
        end
        %
        function self = testIsLti(self)
            aMat = eye(3);
            bMat = eye(3);
            gMat = eye(3);
            cMat = eye(3);
            vEllipsoid = ell_unitball(3);
            uEllipsoid = ell_unitball(3);
            aCMat = {'t','t','t';'t','t','t';'t','t','t'};
            bCMat = {'t','t','t';'t','t','t';'t','t','t'};
            gCMat = {'t','t','t';'t','t','t';'t','t','t'};
            cCMat = {'t','t','t';'t','t','t';'t','t','t'};
            %
            % test matrix of systems
            %
            systemMat = [...
                elltool.linsys.LinSysFactory.create([],[],[]),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,...
                gMat,vEllipsoid,cMat),...
                elltool.linsys.LinSysFactory.create(aCMat,bMat,uEllipsoid,...
                gMat,vEllipsoid,cMat);...
                elltool.linsys.LinSysFactory.create(aMat,bCMat,uEllipsoid,...
                gMat,vEllipsoid,cMat),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,...
                gCMat,vEllipsoid,cMat),...
                elltool.linsys.LinSysFactory.create(aMat,bMat,uEllipsoid,...
                gMat,vEllipsoid,cCMat)...
                ];
            obtainedMat = systemMat.islti();
            expectedMat = [true true false; false false false];
            eqMat = (obtainedMat == expectedMat);
            mlunitext.assert_equals(all(eqMat(:)), true);
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
            obtainedMat = systemMat.isempty();
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
            isOk = ~isempty(strfind(resStr,'Noise bounds')) && isOk;
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
                ellipsoid([0; 0], eye(2)), eye(2), [1; 1], [], [], 'd');
            boundedDistLinSys = elltool.linsys.LinSysFactory.create(eye(2), eye(2),...
                ellipsoid([0; 0], eye(2)), eye(2),...
                ellipsoid([0; 0], eye(2)), [], [], 'd');
            noDistLinSys = elltool.linsys.LinSysFactory.create(eye(2), eye(2),...
                ellipsoid([0; 0], eye(2)), [], [], [], [], 'd');
            %
            % test default behavior
            %
            mlunitext.assert_equals(...
                constantDistLinSys.hasdisturbance(), false);
            mlunitext.assert_equals(boundedDistLinSys.hasdisturbance(), true);
            mlunitext.assert_equals(noDistLinSys.hasdisturbance(), false);
            %
            % test isMeaningful
            %
            mlunitext.assert_equals(...
                boundedDistLinSys.hasdisturbance(true), true);
            mlunitext.assert_equals(...
                boundedDistLinSys.hasdisturbance(false), true);
            mlunitext.assert_equals(...
                constantDistLinSys.hasdisturbance(true), false);
            mlunitext.assert_equals(...
                constantDistLinSys.hasdisturbance(false), true);
            mlunitext.assert_equals(...
                noDistLinSys.hasdisturbance(true), false);
            mlunitext.assert_equals(...
                noDistLinSys.hasdisturbance(false), false);
        end
        %
        function self = testGetCopy(self)
            aMat = eye(3);
            bMat = eye(3);
            uEll = ellipsoid([0; 1; 2], eye(3));
            uStruct = struct();
            uStruct.center = [1; 1; 1];
            uStruct.shape = {'10' 't' '0'; 't' '2' '0'; '0' '0' '3'};
            gMat = eye(3);
            gCMat = {'1' '0' '0'; '0' 'sin(t)' '0'; '0' '0' '2'};
            vEll = ellipsoid(0.5 * eye(3));
            vStruct = struct();
            vStruct.center = [-1; 0; 1];
            vStruct.shape = {'1' '0' '0'; '0' 't' '0'; '0' '0' 't^3'};
            cMat = eye(3);
            cCMat = {'1' '0' '0'; '0' 'cos(t)' '0'; '0' '0' '10'};
            nEll = ellipsoid([1; 2; 3], eye(3));
            nStruct = struct();
            nStruct.center = [0; 0; 0];
            nStruct.shape = {'t' '0' '0'; '0' '1' '0'; '0' '0' 't'};
            lContsysMat(4, 4) = elltool.linsys.LinSysContinuous();
            lContsysMat(1) = create(uEll);
            lContsysMat(2) = create(uStruct);
            lContsysMat(3) = create(uEll, gMat, vEll);
            lContsysMat(4) = create(uEll, gMat, vStruct);
            lContsysMat(5) = create(uStruct, gMat, vEll);
            lContsysMat(6) = create(uStruct, gMat, vStruct);
            lContsysMat(7) = create(uEll, gMat, vEll, cMat, nEll);
            lContsysMat(8) = create(uEll, gMat, vEll, cMat, nStruct);
            lContsysMat(9) = create(uEll, gMat, vStruct, cMat, nEll);
            lContsysMat(10) = create(uEll, gMat, vStruct, cMat, nStruct);
            lContsysMat(11) = create(uStruct, gMat, vEll, cMat, nEll);
            lContsysMat(12) = create(uStruct, gMat, vEll, cMat, nStruct);
            lContsysMat(13) = create(uStruct, gMat, vStruct, cMat, nEll);
            lContsysMat(14) = create(uStruct, gMat, vStruct, cMat, nStruct);
            lContsysMat(15) = create(uEll, gCMat, vStruct, cMat, nStruct);
            lContsysMat(16) = create(uStruct, gCMat, vEll, cCMat, nEll);
            lDiscrsysMat(2, 1) = elltool.linsys.LinSysDiscrete();
            lDiscrsysMat(1) = create(uEll, [], [], [], [], 'd');
            lDiscrsysMat(2) = create(uEll, gMat, vEll, [], [], 'd');
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