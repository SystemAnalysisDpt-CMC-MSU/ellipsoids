classdef LinSysTestCase < mlunitext.test_case
    %
    methods
        function self = LinSysTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = testConstructor(self)
            %
            % non-square matrix A
            %
            aMat = eye(5,2);
            bMat = eye(3);
            uEllipsoid = ell_unitball(3);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid)', ...
                'linsys:dimension:A');
            %
            % wrong type of matrix A
            %
            aMat = true(3);
            bMat = eye(3);
            uEllipsoid = ell_unitball(3);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid)', ...
                'linsys:type:A');          
            %
            % incorrect dimension of matrix B
            %
            aMat = eye(3);
            bMat = eye(4,3);
            uEllipsoid = ell_unitball(3);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid)', ...
                'linsys:dimension:B');
            %
            % incorrect type of matrix B
            %
            aMat = eye(3);
            bMat = true(3,4);
            uEllipsoid = ell_unitball(4);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid)', ...
                'linsys:type:B'); 
            %
            % incorrect dimension of U
            %
            aMat = eye(3);
            bMat = eye(3,4);
            uEllipsoid = ell_unitball(5);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid)', ...
                'linsys:dimension:U');
            %
            clear uEllipsoidStruct;
            uEllipsoidStruct.center = {'1','2','3','4'}';
            uEllipsoidStruct.shape =  ones(5);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoidStruct)', ...
                'linsys:dimension:U:shape');          
            %
            clear uEllipsoidStruct;
            uEllipsoidStruct.center = {'1','2','3'}';
            uEllipsoidStruct.shape =  ones(4);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoidStruct)', ...
                'linsys:dimension:U:center');          
            %            
            uVec = {'t','t','t'}';
            self.runAndCheckError('linsys(aMat, bMat, uVec)', ...
                'linsys:dimension:U');
            %
            uVec = ones(6,1);
            self.runAndCheckError('linsys(aMat, bMat, uVec)', ...
                'linsys:dimension:U'); 
            %
            % incorrect type of U
            %
            aMat = eye(3);
            bMat = eye(3);
            uVec = true(3,1);
            self.runAndCheckError('linsys(aMat, bMat, uVec)', ...
                'linsys:type:U');
            %
            clear uEllipsoidStruct;
            uEllipsoidStruct.center = ones(3,1);
            uEllipsoidStruct.shape =  ones(3);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoidStruct)', ...
                'linsys:type:U');
            %
            % incorrect value of U
            %
            aMat = eye(2);
            bMat = eye(2);
            clear uEllipsoidStruct;
            uEllipsoidStruct.center = zeros(2,1);
            uEllipsoidStruct.shape =  {'t','t^2';'t^3','t^4'};
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoidStruct)', ...
                'linsys:value:U:shape');
            %
            clear uEllipsoidStruct;
            uEllipsoidStruct.center = {'t','t'}';
            uEllipsoidStruct.shape =  [1 2; 3 4];
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoidStruct)', ...
                'linsys:value:U:shape');
            %
            clear uEllipsoidStruct;
            uEllipsoidStruct.center = {'t','t'}';
            uEllipsoidStruct.shape =  [1 2; 2 1];
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoidStruct)', ...
                'linsys:value:U:shape');
            %
            % incorrect dimension of matrix G
            %
            aMat = eye(3);
            bMat = eye(3);
            uEllipsoid = ell_unitball(3);
            gMat = eye(4);
            vEllipsoid = ell_unitball(4);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid)', ...
                'linsys:dimension:G');
            %
            % incorrect type of matrix G
            %
            aMat = eye(3);
            bMat = eye(3);
            uEllipsoid = ell_unitball(3);
            gMat = true(3);
            vEllipsoid = ell_unitball(3);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid)', ...
                'linsys:type:G'); 
            %
            % incorrect dimension of V
            %
            aMat = eye(3);
            bMat = eye(3,4);
            uEllipsoid = ell_unitball(4);
            gMat = eye(3,5);
            vEllipsoid = ell_unitball(4);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid)', ...
                'linsys:dimension:V');
            %
            clear uEllipsoidStruct;
            vEllipsoidStruct.center = {'1','2','3','4'}';
            vEllipsoidStruct.shape =  ones(5);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoidStruct)', ...
                'linsys:dimension:V:center');          
            %
            clear vEllipsoidStruct;
            vEllipsoidStruct.center = {'1','2','3','4','5'}';
            vEllipsoidStruct.shape =  ones(4);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoidStruct)', ...
                'linsys:dimension:V:shape');          
            %            
            vVec = {'t','t','t'}';
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vVec)', ...
                'linsys:dimension:V');
            %
            vVec = ones(6,1);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vVec)', ...
                'linsys:dimension:V'); 
            %
            % incorrect type of V
            %
            aMat = eye(3);
            bMat = eye(3);
            uEllipsoid = ell_unitball(3);
            gMat = eye(3);            
            vVec = true(3,1);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vVec)', ...
                'linsys:type:V');
            %
            clear vEllipsoidStruct;
            vEllipsoidStruct.center = ones(3,1);
            vEllipsoidStruct.shape =  ones(3);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoidStruct)', ...
                'linsys:type:V');
            %
            % incorrect value of V
            %
            aMat = eye(2);
            bMat = eye(2);
            uEllipsoid = ell_unitball(2);
            gMat = eye(2);                       
            clear vEllipsoidStruct;
            vEllipsoidStruct.center = zeros(2,1);
            vEllipsoidStruct.shape =  {'t','t^2';'t^3','t^4'};
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoidStruct)', ...
                'linsys:value:V:shape');
            %
            clear vEllipsoidStruct;
            vEllipsoidStruct.center = {'t','t'}';
            vEllipsoidStruct.shape =  [1 2; 3 4];
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoidStruct)', ...
                'linsys:value:V:shape');
            %
            clear vEllipsoidStruct;
            vEllipsoidStruct.center = {'t','t'}';
            vEllipsoidStruct.shape =  [1 2; 2 1];
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoidStruct)', ...
                'linsys:value:V:shape');            
            %
            % incorrect dimension of matrix C
            %
            aMat = eye(3);
            bMat = eye(3);
            uEllipsoid = ell_unitball(3);
            cMat = eye(3,4);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, [], [], cMat)', ...
                'linsys:dimension:C');
            %
            % incorrect type of matrix C
            %
            aMat = eye(3);
            bMat = eye(3);
            uEllipsoid = ell_unitball(3);
            cMat = true(3);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, [], [], cMat)', ...
                'linsys:type:C');
            %
            % incorrect dimension of W
            %
            aMat = eye(3);
            bMat = eye(3);
            uEllipsoid = ell_unitball(3);
            gMat = eye(3);
            vEllipsoid = ell_unitball(3);
            cMat = eye(3);
            wEllipsoid = ell_unitball(2);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid, cMat, wEllipsoid)', ...
                'linsys:dimension:W');
            %
            clear uEllipsoidStruct;
            wEllipsoidStruct.center = {'1','2','3','4'}';
            wEllipsoidStruct.shape =  ones(3);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid, cMat, wEllipsoidStruct)', ...
                'linsys:dimension:W:center');          
            %
            clear wEllipsoidStruct;
            wEllipsoidStruct.center = {'1','2','3'}';
            wEllipsoidStruct.shape =  ones(4);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid, cMat, wEllipsoidStruct)', ...
                'linsys:dimension:W:shape');          
            %            
            wVec = {'t','t','t','t'}';
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid, cMat, wVec)', ...
                'linsys:dimension:W');
            %
            wVec = ones(6,1);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid, cMat, wVec)', ...
                'linsys:dimension:W'); 
            %
            % incorrect type of W
            %            
            wVec = true(3,1);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid, cMat, wVec)', ...
                'linsys:type:W');
            %
            clear wEllipsoidStruct;
            wEllipsoidStruct.center = ones(3,1);
            wEllipsoidStruct.shape =  ones(3);
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid, cMat, wEllipsoidStruct)', ...
                'linsys:type:W');
            %
            % incorrect value of W
            %
            aMat = eye(2);
            bMat = eye(2);
            uEllipsoid = ell_unitball(2);
            gMat = eye(2);
            vEllipsoid = ell_unitball(2);
            cMat = eye(2);            
            clear wEllipsoidStruct;
            wEllipsoidStruct.center = zeros(2,1);
            wEllipsoidStruct.shape =  {'t','t^2';'t^3','t^4'};
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid, cMat, wEllipsoidStruct)', ...
                'linsys:value:W:shape');
            %
            clear wEllipsoidStruct;
            wEllipsoidStruct.center = {'t','t'}';
            wEllipsoidStruct.shape =  [1 2; 3 4];
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid, cMat, wEllipsoidStruct)', ...
                'linsys:value:W:shape');
            %
            clear wEllipsoidStruct;
            wEllipsoidStruct.center = {'t','t'}';
            wEllipsoidStruct.shape =  [1 2; 2 1];
            self.runAndCheckError('linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid, cMat, wEllipsoidStruct)', ...
                'linsys:value:W:shape');                
        end
        %
        function self = testDimension(self)
            %
            % test empty system
            %
            system = linsys([],[],[]);                        
            [nStates, nInputs, nOutputs, nDistInputs] = dimension(system);
            %
            obtainedVec = [nStates, nInputs, nOutputs, nDistInputs];
            expectedVec = [0 0 0 0];
            %
            mlunit.assert_equals( all(expectedVec == obtainedVec), true );
            %                 
            % test simple system without disturbance
            %
            aMat = eye(2);
            bMat = eye(2,3);
            uEllipsoid = ell_unitball(3);
            %
            system = linsys(aMat,bMat,uEllipsoid);                        
            [nStates, nInputs, nOutputs, nDistInputs] = dimension(system);
            %
            obtainedVec = [nStates, nInputs, nOutputs, nDistInputs];
            expectedVec = [2 3 2 0];
            %
            mlunit.assert_equals( all(expectedVec == obtainedVec), true );   
            %
            % test complex system with disturbance and noise            
            %
            aMat = eye(5);
            bMat = eye(5,10);
            uEllipsoid = ell_unitball(10);
            gMat = eye(5,11);
            vEllipsoid = ell_unitball(11);
            cMat = zeros(3,5);
            wEllipsoid = ell_unitball(3);
            %
            system = linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoid,cMat,...
                wEllipsoid);
            [nStates, nInputs, nOutputs, nDistInputs] = dimension(system);
            %
            obtainedVec = [nStates, nInputs, nOutputs, nDistInputs];
            expectedVec = [5 10 3 11];
            %
            mlunit.assert_equals( all(expectedVec == obtainedVec), true );   
            %            
            % test array of systems       
            %
            systemMat = [system system; system system];
            [nStatesMat, nInputsMat, nOutputsMat, nDistInputsMat] = ...
                dimension(systemMat);
            %
            obtainedMat=[nStatesMat,nInputsMat,nOutputsMat,nDistInputsMat];
            expectedMat=[ 5*ones(2), 10*ones(2), 3*ones(2), 11*ones(2) ];
            %
            resultMat = (expectedMat(:) == obtainedMat(:));
            mlunit.assert_equals( all(resultMat(:)), true ); 
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
            wEllipsoidStruct.shape = {'t','t','t';'t','t','t';'t','t','t'};
            wEllipsoidStruct.center = {'t';'t';'t'};
            %
            % test matrix of systems
            %
            systemMat = [ ...
                linsys([],[],[]), ...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoid,cMat,[]), ...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoid,cMat,wVec); ...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoid,cMat,wCVec), ...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoid,cMat,wEllipsoid),...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoid,cMat,wEllipsoidStruct) ...
            ];
            obtainedMat = hasnoise(systemMat);
            expectedMat = [ false false true; true true true ];
            eqMat = (obtainedMat == expectedMat);
            mlunit.assert_equals( all(eqMat(:)), true );              
        end
        %
        function self = testDisturbance(self)
            aMat = eye(3);
            bMat = eye(3);
            gMat = eye(3);
            uEllipsoid = ell_unitball(3);            
            vVec = eye(3,1);
            vCVec = {'t';'t';'t'};
            vEllipsoid = ell_unitball(3);
            vEllipsoidStruct.shape = {'t','t','t';'t','t','t';'t','t','t'};
            vEllipsoidStruct.center = {'t';'t';'t'};
            %
            % test matrix of systems
            %            
            systemMat = [ ...
                linsys([],[],[]), ...
                linsys(aMat,bMat,uEllipsoid,gMat,vVec), ...
                linsys(aMat,bMat,uEllipsoid,gMat,vCVec); ...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoid), ...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoidStruct), ...
                linsys(aMat,bMat,uEllipsoid,[],vEllipsoidStruct) ...
            ];
            obtainedMat = hasdisturbance(systemMat);
            expectedMat = [ false true true; true true false ];
            eqMat = (obtainedMat == expectedMat);
            mlunit.assert_equals( all(eqMat(:)), true );              
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
            systemMat = [ ...
                linsys([],[],[]), ...
                linsys(aMat,bMat,uEllipsoid), ...
                linsys(aMat,bMat,uEllipsoid,[],[],cMat,[]); ...
                linsys(aMat,bMat,uEllipsoid,[],[],cMat,[],'c'), ...
                linsys(aMat,bMat,uEllipsoid,[],[],cMat,[],'d'), ...
                linsys(aMat,bMat,uVec,[],vVec,cMat,wVec,'d') ...
            ];
            obtainedMat = isdiscrete(systemMat);
            expectedMat = [ false false false; false true true ];
            eqMat = (obtainedMat == expectedMat);
            mlunit.assert_equals( all(eqMat(:)), true );               
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
            systemMat = [ ...
                linsys([],[],[]), ...
                linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid, cMat), ...
                linsys(aCMat, bMat, uEllipsoid, gMat, vEllipsoid, cMat); ...
                linsys(aMat, bCMat, uEllipsoid, gMat, vEllipsoid, cMat), ...
                linsys(aMat, bMat, uEllipsoid, gCMat, vEllipsoid, cMat), ...
                linsys(aMat, bMat, uEllipsoid, gMat, vEllipsoid, cCMat) ...
            ];
            obtainedMat = islti(systemMat);
            expectedMat = [ true true false; false false false ];
            eqMat = (obtainedMat == expectedMat);
            mlunit.assert_equals( all(eqMat(:)), true );                 
        end
        %
        function self = testIsEmpty(self)
            aMat = eye(3);
            bMat = eye(3); 
            uEllipsoid = ell_unitball(3);
            %
            % test matrix of systems
            %
            systemMat = [ ...
                linsys(), ...
                linsys([],[],[]); ...
                linsys(aMat,bMat,[]), ...
                linsys(aMat,bMat,uEllipsoid) ...
            ];
            obtainedMat = isempty(systemMat);
            expectedMat = [ true true; false false];
            eqMat = (obtainedMat == expectedMat);
            mlunit.assert_equals( all(eqMat(:)), true );                 
        end         
    end
end