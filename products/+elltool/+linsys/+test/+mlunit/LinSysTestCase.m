classdef LinSysTestCase < mlunitext.test_case
    %
    properties (Access=private)
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
    end
    %
    methods
        function self = LinSysTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = testConstructor(self)
            clear UEllStruct;
            clear VEllStruct;
            clear WEllStruct;
            ell2d = ell_unitball(2);
            ell3d = ell_unitball(3);
            ell4d = ell_unitball(4);
            
            firstArgCVec = {@()elltool.linsys.LinSysFactory.create(eye(3,4),eye(3),ell3d),...
                @()elltool.linsys.LinSysFactory.create(true(3),eye(3),ell3d),...
                @()elltool.linsys.LinSysFactory.create(eye(3),eye(4,3),ell3d)...
                @()elltool.linsys.LinSysFactory.create(eye(3),true(3),ell3d),...
                @()elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell4d),...
                @()elltool.linsys.LinSysFactory.create(eye(3),eye(3),eye(4,1)),...
                @()elltool.linsys.LinSysFactory.create(eye(3),eye(3),true(3,1)),...
                @()elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(4),ell4d),...
                @()elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,true(3),ell3d),...
                @()elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),ell4d),...
                @()elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),true(3,1))};
            secondArgCVec = {'dimension:A', 'type:A', 'dimension:B',...
                'type:B', 'dimension:P', 'dimension:P', 'type:P', 'dimension:C',...
                'type:C', 'dimension:Q', 'type:Q'};
            nElems=numel(firstArgCVec);
            for iElem=1:nElems
                self.runAndCheckError(firstArgCVec{iElem}, secondArgCVec{iElem});
            end
            %
            UOrVEllStructCenterCMat = {{'1';'1';'1';'1'}, {'1';'1';'1'},...
                eye(3, 1), zeros(2, 1), {'t';'t'}, {'t';'t'}, {'t';'t'},...
                {'t';'t'}, {'1';'1';'1';'1'}, {'1';'1';'1'},eye(3, 1),...
                zeros(2, 1), {'t';'t'}, {'t';'t'}, {'t';'t'}, {'t';'t'}};
            UOrVEllStructShapeCMat = {eye(3), ones(4), eye(3),...
                {'t','t^2';'t^3','t^4'}, [1 2; 3 4], [2 1; 3 2], [1 2; 2 1],...
                [1 0; 0 0], ones(3), ones(4), eye(3), {'t','t^2';'t^3','t^4'},...
                [1 2; 3 4], [2 1; 3 2], [1 2; 2 1], [1 0; 0 0]};
            flagCVec = {1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2};
            firstArgCVec = {'elltool.linsys.LinSysFactory.create(eye(3),eye(3),UEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),UEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),UEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),UEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),UEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),UEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),UEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),UEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),VEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),VEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),VEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),VEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),VEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),VEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),VEllStruct)',...
                'elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),VEllStruct)'};
            secondArgCVec = {'dimension:P:center', 'dimension:P:shape', 'type:P',...
                'value:P:shape', 'value:P:shape', 'value:P:shape',...
                'value:P:shape', 'value:P:shape', 'dimension:Q:center', ...
                'dimension:Q:shape', 'type:Q', 'value:Q:shape',...
                'value:Q:shape', 'value:Q:shape', 'value:Q:shape', 'value:Q:shape'};
            cellfun(@(x, y, z, w, v)UOrVEllStructTest(x, y, z, w, self, v),...
                UOrVEllStructCenterCMat, UOrVEllStructShapeCMat,...
                firstArgCVec, secondArgCVec, flagCVec,...
                'UniformOutput', false);
            
            firstArgCVec = {'elltool.linsys.LinSysFactory.create(eye(3),eye(3),uCVec)',...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),vCVec)',...
                'elltool.linsys.LinSysFactory.create(eye(3),eye(3),ell3d,eye(3),vCVec)'};
            secondArgCVec = {'dimension:P', 'dimension:Q', 'dimension:Q'};
            UOrVCMat = {{'t';'t';'t';'t'}, eye(4,1), {'t';'t';'t';'t'}};
            UOrVEllStructCenterCMat = {};
            UOrVEllStructShapeCMat = {};
            flagCVec = {3, 4, 4};
            cellfun(@(x, y, z, w)UOrVEllStructTest({}, {}, x, y, self, z, w),...
                firstArgCVec, secondArgCVec, flagCVec, UOrVCMat,...
                'UniformOutput', false);
            
            UEllStruct.center = {'t';'t'};
            UEllStruct.shape = [1 0; 0 1];
            elltool.linsys.LinSysFactory.create(eye(2),eye(2),UEllStruct);
            
            
            VEllStruct.center = {'t';'t'};
            VEllStruct.shape = [1 0; 0 1];
            elltool.linsys.LinSysFactory.create(eye(2),eye(2),ell2d,eye(2),VEllStruct);
        end
        %
        function self = testDimension(self)
            flagCVec = {1, 2, 3};
            expectedCVec = {[0 0 0], [2 3 0], [5 10 11]};
            cellfun(@(x, y)compareTestDim(x, y), flagCVec, expectedCVec,...
                'UniformOutput', false);        
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
            UEll = struct();
            UEll.center = {'2 * cos(t)'; '0.5 * sin(t)'};
            UEll.shape = {'4 * t' '0'; '0' 't'};
            
            system = elltool.linsys.LinSysFactory.create(...
                {'t', '1', 'cos(t)'; '1' '0' 't'; 'sin(t)', 't', '2'}, ...
                {'t', 'cos(t)'; 'sin(t)', 't'; 'cos(t)', 'sin(t)'}, ...
                UEll, eye(3,5),ell_unitball(5),eye(2,3),ell_unitball(2));
            resStr = evalc('display(system)');
            isOk = ~isempty(strfind(resStr,'A'));
            isOk = ~isempty(strfind(resStr,'B')) && isOk;
            isOk = ~isempty(strfind(resStr,'Control bound')) && isOk;
            isOk = ~isempty(strfind(resStr,'Disturbance bounds')) && isOk;
            mlunitext.assert(isOk);
        end
        %
        function self = testDisplayEmpty(self)
            flagCVec = {1, 2};
            isOk = cellfun(@(x)compareTestDispEmp(x), flagCVec,...
                'UniformOutput', false); 
            mlunitext.assert(isOk{1, 1} && ~isOk{1, 2});
        end
        %
        function self = testGetAbsTol(self)
            TEST_ABS_TOL = 1e-8;
            args = {eye(3),eye(3,4),ell_unitball(4),...
                eye(3,5),ell_unitball(5),eye(2,3),...
                ell_unitball(2),'d','absTol',TEST_ABS_TOL};
            systemArr = [elltool.linsys.LinSysFactory.create(args{:}),...
                elltool.linsys.LinSysFactory.create(args{:});...
                elltool.linsys.LinSysFactory.create(args{:}),...
                elltool.linsys.LinSysFactory.create(args{:})];
            systemArr(:,:,2) = [elltool.linsys.LinSysFactory.create(args{:}),...
                elltool.linsys.LinSysFactory.create(args{:});...
                elltool.linsys.LinSysFactory.create(args{:}),...
                elltool.linsys.LinSysFactory.create(args{:})];
            sizeArr = size(systemArr);
            testAbsTolArr = repmat(TEST_ABS_TOL,sizeArr);
            %
            isOkArr = (testAbsTolArr == systemArr.getAbsTol());
            %
            isOk = all(isOkArr(:));
            mlunitext.assert(isOk);
        end
        %
        function self = testHasDisturbance(self)
            constantDistLinSys = elltool.linsys.LinSysFactory.create(eye(2), eye(2),...
                self.ellipsoid([0; 0], eye(2)), eye(2), [1; 1], 'd');
            boundedDistLinSys = elltool.linsys.LinSysFactory.create(eye(2), eye(2),...
                self.ellipsoid([0; 0], eye(2)), eye(2),...
                self.ellipsoid([0; 0], eye(2)), [], [], 'd');
            noDistLinSys = elltool.linsys.LinSysFactory.create(eye(2), eye(2),...
                self.ellipsoid([0; 0], eye(2)), [], [], 'd');
            flagCVec = {1, 1, 2, 2, 3, 3, 4, 5, 6};
            isFlagFirstArgCVec = {true, false, true, false, true, false, '', '', ''};
            isFlagSecondArgCVec = {true, true, false, true, false, false,...
                false, true, false};
            
            cellfun(@(x, y, z)compareTestHasDistr(x, y, z,...
                constantDistLinSys, boundedDistLinSys, noDistLinSys),...
                flagCVec, isFlagFirstArgCVec, isFlagSecondArgCVec,...
                'UniformOutput', false);
            
        end
        %
        function self = testGetCopy(self)
            aMat = eye(3);
            bMat = eye(3);
            uEll = self.ellipsoid([0; 1; 2], eye(3));
            uStruct = struct();
            uStruct.center = [1; 1; 1];
            uStruct.shape = {'10' 't' '0'; 't' '2' '0'; '0' '0' '3'};
            cMat = eye(3);
            cCMat = {'1' '0' '0'; '0' 'sin(t)' '0'; '0' '0' '2'};
            vEll = self.ellipsoid(0.5 * eye(3));
            vStruct = struct();
            vStruct.center = [-1; 0; 1];
            vStruct.shape = {'1' '0' '0'; '0' 't' '0'; '0' '0' 't^3'};
            nEll = self.ellipsoid([1; 2; 3], eye(3));
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


function UOrVEllStructTest(centerMat, shapeMat, fArg, sArg,...
    self, flag, VOrUMat)
    ell2d = ell_unitball(2); %#ok<*NASGU>
    ell3d = ell_unitball(3);
    if(flag == 1)
        UEllStruct.center = centerMat;
        UEllStruct.shape = shapeMat; %#ok<*STRNU>
        self.runAndCheckError(fArg, sArg);
    elseif(flag == 2)
        VEllStruct.center = centerMat;
        VEllStruct.shape = shapeMat;
        self.runAndCheckError(fArg, sArg);
    elseif(flag == 3)
        uCVec = VOrUMat;
        self.runAndCheckError(fArg, sArg);
    elseif(flag == 4)
        vCVec = VOrUMat;
        self.runAndCheckError(fArg, sArg);
    end
end


function compareTestDim(flag, expectedVec)
    if flag == 1
        system = elltool.linsys.LinSysFactory.create([],[],[]);
    elseif flag == 2
        system = elltool.linsys.LinSysFactory.create(eye(2), eye(2,3), ell_unitball(3));
    elseif flag == 3
        system = elltool.linsys.LinSysFactory.create(eye(5),eye(5,10),ell_unitball(10),...
            eye(5,11),ell_unitball(11),zeros(3,5),ell_unitball(3));
        systemMat = [system system; system system];
    end
    [nStates, nInputs,  nDistInputs] = system.dimension();
    obtainedVec = [nStates, nInputs,  nDistInputs];
    mlunitext.assert_equals(all(expectedVec == obtainedVec), true);
    if flag == 3
        [nStatesMat, nInputsMat, nDistInputsMat] =...
            systemMat.dimension();
        obtainedMat=[nStatesMat,nInputsMat,nDistInputsMat];
        expectedMat=[5*ones(2), 10*ones(2), 11*ones(2)];
        resultMat = (expectedMat(:) == obtainedMat(:));
        mlunitext.assert_equals(all(resultMat(:)), true);
    end
end
function isOk = compareTestDispEmp(flag)
    if flag ==1
        system = elltool.linsys.LinSysContinuous.empty();
    else
        system = elltool.linsys.LinSysDiscrete.empty(2, 0, 5);
    end
    resStr = evalc('system.display()');
    isOk = ~isempty(strfind(resStr, ...
        'Empty linear system object.'));
end
function compareTestHasDistr(flag, isFlagFirst, isFlagSecond,...
    constantDistLinSys, boundedDistLinSys, noDistLinSys)
    if flag == 1
        mlunitext.assert_equals(...
            boundedDistLinSys.hasDisturbance(isFlagFirst), isFlagSecond);
    elseif flag == 2
        mlunitext.assert_equals(...
            constantDistLinSys.hasDisturbance(isFlagFirst), isFlagSecond);
    elseif flag == 3
        mlunitext.assert_equals(...
            noDistLinSys.hasDisturbance(isFlagFirst), isFlagSecond);
    elseif flag == 4
        mlunitext.assert_equals(...
            constantDistLinSys.hasDisturbance(), isFlagSecond);
    elseif flag ==5
        mlunitext.assert_equals(boundedDistLinSys.hasDisturbance(),...
            isFlagSecond);
    else
        mlunitext.assert_equals(noDistLinSys.hasDisturbance(),...
            isFlagSecond);
    end
end