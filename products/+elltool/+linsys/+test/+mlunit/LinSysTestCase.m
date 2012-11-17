classdef LinSysTestCase < mlunitext.test_case
    %
    methods
        function self = LinSysTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = testConstructor(self)
            clear uEllStuct;
            clear vEllStuct;
            clear wEllStuct;
            ell2d = ell_unitball(2);
            ell3d = ell_unitball(3);
            ell4d = ell_unitball(4);
            %
            % non-square matrix A
            %            
            self.runAndCheckError(...
                'linsys(eye(3,4), eye(3), ell3d)', ...
                'linsys:dimension:A');
            %
            % wrong type of matrix A
            %
            self.runAndCheckError(...
                'linsys(true(3), eye(3),  ell3d)', ...
                'linsys:type:A');          
            %
            % incorrect dimension of matrix B
            %
            self.runAndCheckError(...
                'linsys(eye(3), eye(4,3), ell3d)', ...
                'linsys:dimension:B');
            %
            % incorrect type of matrix B
            %
            self.runAndCheckError(...
                'linsys(eye(3), true(3), ell3d)', ...
                'linsys:type:B'); 
            %
            % incorrect dimension of U when U is a constant ellipsoid
            %
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell4d)', ...
                'linsys:dimension:U');
            %
            % incorrect dimension of U when U is a symbolic ellipsoid
            %
            uEllStuct.center = {'1';'1';'1';'1'};
            uEllStuct.shape =  eye(3);
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), uEllStuct)', ...
                'linsys:dimension:U:center');          
            %
            uEllStuct.center = {'1';'1';'1'};
            uEllStuct.shape =  ones(4);
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), uEllStuct)', ...
                'linsys:dimension:U:shape');          
            %
            % incorrect dimension of U when U is a constant vector
            %
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), eye(4,1))', ...
                'linsys:dimension:U'); 
            %
            % incorrect dimension of U when U is a symbolic vector
            %   
            uCVec = {'t';'t';'t';'t'};
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), uCVec)', ...
                'linsys:dimension:U');
            %
            % incorrect type of U when U is a vector
            %
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), true(3,1))', ...
                'linsys:type:U');
            %
            % incorrect type of U when U is a all-constant structure
            %         
            uEllStuct.center = eye(3,1);
            uEllStuct.shape =  eye(3);
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), uEllStuct)', ...
                'linsys:type:U');
            %
            % incorrect value of U when U.shape is non-symmetric cell matrix
            %
            uEllStuct.center = zeros(2,1);
            uEllStuct.shape =  {'t','t^2';'t^3','t^4'};
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), uEllStuct)', ...
                'linsys:value:U:shape');
            %
            % incorrect value of U when U.shape is non-symmetric 
            % negative-defined constant matrix
            %
            uEllStuct.center = {'t';'t'};
            uEllStuct.shape =  [1 2; 3 4];
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), uEllStuct)', ...
                'linsys:value:U:shape');
            %
            % incorrect value of U when U.shape is non-symmetric 
            % positive-defined constant matrix
            %
            uEllStuct.center = {'t';'t'};
            uEllStuct.shape =  [2 1; 3 2];
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), uEllStuct)', ...
                'linsys:value:U:shape');            
            %
            % incorrect value of U when U.shape is symmetric but 
            % negative-defined constant matrix
            %
            uEllStuct.center = {'t';'t'};
            uEllStuct.shape =  [1 2; 2 1];
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), uEllStuct)', ...
                'linsys:value:U:shape');
            %
            % incorrect value of U when U.shape is symmetric but 
            % non-negative-defined constant matrix
            %
            uEllStuct.center = {'t';'t'};
            uEllStuct.shape =  [1 0; 0 0];
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), uEllStuct)', ...
                'linsys:value:U:shape');
            %
            % correct value of U when U.shape is symmetric and 
            % positive-defined constant matrix
            %         
            uEllStuct.center = {'t';'t'};
            uEllStuct.shape =  [1 0; 0 1];
            linsys(eye(2), eye(2), uEllStuct);
            %
            % incorrect dimension of matrix G
            %
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(4), ell4d)', ...
                'linsys:dimension:G');
            %
            % incorrect type of matrix G
            %
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, true(3), ell3d)', ...
                'linsys:type:G'); 
            %
            % incorrect dimension of V when V is a constant ellipsoid
            %
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3), ell4d)', ...
                'linsys:dimension:V');
            %
            % incorrect dimension of V when V is a symbolic ellipsoid
            %
            vEllStuct.center = {'1';'1';'1';'1'};
            vEllStuct.shape =  ones(3);
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3), vEllStuct)', ...
                'linsys:dimension:V:center');          
            %
            vEllStuct.center = {'1';'1';'1'};
            vEllStuct.shape =  ones(4);
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3), vEllStuct)', ...
                'linsys:dimension:V:shape');          
            %
            % incorrect dimension of V when V is a constant vector
            %         
            vVec = eye(4,1);
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3),  vVec)', ...
                'linsys:dimension:V');
            %
            % incorrect dimension of V when V is a symbolic vector
            %
            vCVec = {'t';'t';'t';'t'};
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3), vCVec)', ...
                'linsys:dimension:V'); 
            %
            % incorrect type of V when V is a vector
            %
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3), true(3,1))', ...
                'linsys:type:V');
            %
            % incorrect type of V when V is a all-constant structure
            %
            vEllStuct.center = eye(3,1);
            vEllStuct.shape =  eye(3);
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3), vEllStuct)', ...
                'linsys:type:V');
            %
            % incorrect value of V when V.shape is non-symmetric cell matrix
            %                         
            vEllStuct.center = zeros(2,1);
            vEllStuct.shape =  {'t','t^2';'t^3','t^4'};
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), ell2d, eye(2), vEllStuct)', ...
                'linsys:value:V:shape');
            %
            % incorrect value of V when V.shape is non-symmetric 
            % negative-defined constant matrix
            %
            vEllStuct.center = {'t';'t'};
            vEllStuct.shape =  [1 2; 3 4];
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), ell2d, eye(2), vEllStuct)', ...
                'linsys:value:V:shape');
            %
            % incorrect value of V when V.shape is non-symmetric 
            % positive-defined constant matrix
            %
            vEllStuct.center = {'t';'t'};
            vEllStuct.shape =  [2 1; 3 2];
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), ell2d, eye(2), vEllStuct)', ...
                'linsys:value:V:shape');            
            %
            % incorrect value of V when V.shape is symmetric but
            % negative-defined constant matrix
            %
            vEllStuct.center = {'t';'t'};
            vEllStuct.shape =  [1 2; 2 1];
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), ell2d, eye(2), vEllStuct)', ...
                'linsys:value:V:shape');
            %
            % incorrect value of V when V.shape is symmetric but 
            % non-negative-defined constant matrix
            %
            vEllStuct.center = {'t';'t'};
            vEllStuct.shape =  [1 0; 0 0];
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), ell2d, eye(2), vEllStuct)', ...
                'linsys:value:V:shape');
            %
            % correct value of V when V.shape is symmetric and 
            % positive-defined constant matrix
            %          
            vEllStuct.center = {'t';'t'};
            vEllStuct.shape =  [1 0; 0 1];  
            linsys(eye(2), eye(2), ell2d, eye(2), vEllStuct);
            %
            % incorrect dimension of matrix C
            %
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, [], [], eye(4))', ...
                'linsys:dimension:C');
            %
            % incorrect type of matrix C
            %
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, [], [], true(3))', ...
                'linsys:type:C');
            %
            % incorrect dimension of W when W is a constant ellipsoid
            %
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3), ell3d, eye(3), ell4d)', ...
                'linsys:dimension:W');
            %
            % incorrect dimension of W when W is a symbolic ellipsoid
            %
            wEllStuct.center = {'1';'1';'1';'1'};
            wEllStuct.shape =  ones(3);
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3), ell3d, eye(3), wEllStuct)', ...
                'linsys:dimension:W:center');          
            %
            wEllStuct.center = {'1';'1';'1'};
            wEllStuct.shape =  ones(4);
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3), ell3d, eye(3), wEllStuct)', ...
                'linsys:dimension:W:shape');          
            %
            % incorrect dimension of W when W is a constant vector
            %         
            wVec = eye(4,1);
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3), ell3d, eye(3), wVec)', ...
                'linsys:dimension:W');
            %
            % incorrect dimension of W when W is a symbolic vector
            %
            wCVec = {'t';'t';'t';'t'};
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3), ell3d, eye(3), wCVec)', ...
                'linsys:dimension:W'); 
            %
            % incorrect type of W when W is a vector
            %
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3), ell3d, eye(3), true(3,1))', ...
                'linsys:type:W');
            %
            % incorrect type of W when W is a all-constant structure
            %
            wEllStuct.center = eye(3,1);
            wEllStuct.shape =  eye(3);
            self.runAndCheckError(...
                'linsys(eye(3), eye(3), ell3d, eye(3), ell3d, eye(3), wEllStuct)', ...
                'linsys:type:W');
            %
            % incorrect value of W when W.shape is non-symmetric cell matrix
            %                         
            wEllStuct.center = zeros(2,1);
            wEllStuct.shape =  {'t','t^2';'t^3','t^4'};
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), ell2d, eye(2), ell2d, eye(2), wEllStuct)', ...
                'linsys:value:W:shape');
            %
            % incorrect value of W when W.shape is non-symmetric 
            % negative-defined constant matrix
            %
            wEllStuct.center = {'t';'t'};
            wEllStuct.shape =  [1 2; 3 4];
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), ell2d, eye(2), ell2d, eye(2), wEllStuct)', ...
                'linsys:value:W:shape');
            %
            % incorrect value of W when W.shape is non-symmetric 
            % positive-defined constant matrix
            %
            wEllStuct.center = {'t';'t'};
            wEllStuct.shape =  [2 1; 3 2];
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), ell2d, eye(2), ell2d, eye(2), wEllStuct)', ...
                'linsys:value:W:shape');            
            %
            % incorrect value of W when W.shape is symmetric but 
            % negative-defined constant matrix
            %
            wEllStuct.center = {'t';'t'};
            wEllStuct.shape =  [1 2; 2 1];
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), ell2d, eye(2), ell2d, eye(2), wEllStuct)', ...
                'linsys:value:W:shape');
            %
            % incorrect value of W when W.shape is symmetric but 
            % non-negative-defined constant matrix
            %
            wEllStuct.center = {'t';'t'};
            wEllStuct.shape =  [1 0; 0 0];
            self.runAndCheckError(...
                'linsys(eye(2), eye(2), ell2d, eye(2), ell2d, eye(2), wEllStuct)', ...
                'linsys:value:W:shape');
            %
            % correct value of W when W.shape is symmetric and 
            % positive-defined constant matrix
            %          
            wEllStuct.center = {'t';'t'};
            wEllStuct.shape =  [1 0; 0 1];  
            linsys(eye(2), eye(2), ell2d, eye(2), ell2d, eye(2), wEllStuct);         
            %
        end
        %
        function self = testDimension(self)
            %
            % test empty system
            %
            system = linsys([],[],[]);                        
            [nStates, nInputs, nOutputs, nDistInputs] = dimension(system);
            obtainedVec = [nStates, nInputs, nOutputs, nDistInputs];
            expectedVec = [0 0 0 0];
            mlunit.assert_equals( all(expectedVec == obtainedVec), true );
            %                 
            % test simple system without disturbance
            %
            system = linsys(eye(2), eye(2,3), ell_unitball(3));                        
            [nStates, nInputs, nOutputs, nDistInputs] = dimension(system);
            obtainedVec = [nStates, nInputs, nOutputs, nDistInputs];
            expectedVec = [2 3 2 0];
            mlunit.assert_equals( all(expectedVec == obtainedVec), true );   
            %
            % test complex system with disturbance and noise            
            %
            system = linsys(eye(5),eye(5,10),ell_unitball(10), ...
                eye(5,11),ell_unitball(11),zeros(3,5),ell_unitball(3));
            [nStates, nInputs, nOutputs, nDistInputs] = dimension(system);
            obtainedVec = [nStates, nInputs, nOutputs, nDistInputs];
            expectedVec = [5 10 3 11];
            mlunit.assert_equals( all(expectedVec == obtainedVec), true );   
            %            
            % test array of systems       
            %
            systemMat = [system system; system system];
            [nStatesMat, nInputsMat, nOutputsMat, nDistInputsMat] = dimension(systemMat);
            obtainedMat=[nStatesMat,nInputsMat,nOutputsMat,nDistInputsMat];
            expectedMat=[ 5*ones(2), 10*ones(2), 3*ones(2), 11*ones(2) ];
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
            wEllStuct.shape = {'t','t','t';'t','t','t';'t','t','t'};
            wEllStuct.center = {'t';'t';'t'};
            %
            % test matrix of systems
            %
            systemMat = [ ...
                linsys([],[],[]), ...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoid,cMat,[]), ...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoid,cMat,wVec); ...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoid,cMat,wCVec), ...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoid,cMat,wEllipsoid),...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoid,cMat,wEllStuct) ...
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
            vEllStuct.shape = {'t','t','t';'t','t','t';'t','t','t'};
            vEllStuct.center = {'t';'t';'t'};
            %
            % test matrix of systems
            %            
            systemMat = [ ...
                linsys([],[],[]), ...
                linsys(aMat,bMat,uEllipsoid,gMat,vVec), ...
                linsys(aMat,bMat,uEllipsoid,gMat,vCVec); ...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllipsoid), ...
                linsys(aMat,bMat,uEllipsoid,gMat,vEllStuct), ...
                linsys(aMat,bMat,uEllipsoid,[],vEllStuct) ...
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
        %
        function self = testDisplay(self)
            system = linsys( eye(3), eye(3,4), ell_unitball(4), ...
                eye(3,5), ell_unitball(5), eye(2,3), ell_unitball(2), 'd');
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
            absTolVal = 1e-8;
            system = linsys( eye(3), eye(3,4), ell_unitball(4), ...
                eye(3,5), ell_unitball(5), eye(2,3), ell_unitball(2), 'd','absTol',absTolVal);
            isOk = absTolVal == system.getAbsTol;
            mlunit.assert(isOk);
        end
    end
end