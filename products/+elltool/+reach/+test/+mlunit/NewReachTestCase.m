classdef NewReachTestCase < mlunitext.test_case
    methods
        function self = NewReachTestCase(varargin)
           self=self@mlunitext.test_case(varargin{:});
        end
        %
        function self=testConstructor(self)
            import reach;
            timeVec=[0 0.1];
            fMethod=@(lSys) reach(lSys,ellipsoid(eye(2)),...
                [1 0]', timeVec);
            %
            checkUVW2(self,'U',fMethod);
            checkUVW2(self,'V',fMethod);
            checkUVW2(self,'W',fMethod);
        end
        %
        function self = testEvolve(self)
            import reach;
            lSys=linsys(eye(2),eye(2),ellipsoid(eye(2)));
            rSet=reach(lSys,ellipsoid(eye(2)),[1 0]', [0 0.1]);
            timeVec=[0.2 0.5];
            fMethod=@(lSys) evolve(rSet,timeVec,lSys);
            %
            checkUVW2(self,'V',fMethod);
            checkUVW2(self,'U',fMethod);
            checkUVW2(self,'W',fMethod);
        end
        %
        function checkUVW2(self,typeUVW,fMethod)
                import reach;
                % U - control, V - disturbance, W - noise
                % Center of ellipsoid is of type double
                lSysRight=formVLinSys(typeUVW,1,false,false);
                lSysWrong=formVLinSys(typeUVW,2,false,false);
                fMethod(lSysRight);       
                self.runAndCheckError(@check,...
                     'wrongMat');
                %
                % Center of ellipsoid is of type cell
                lSysRight=formVLinSys(typeUVW,1,false,true);
                lSysWrong=formVLinSys(typeUVW,2,false,true);
                fMethod(lSysRight);       
                self.runAndCheckError(@check,...
                     'wrongMat');
                %
                if typeUVW~='W'
                    % Matrix is of type cell
                    lSysRight=formVLinSys(typeUVW,1,true,true);
                    lSysWrong=formVLinSys(typeUVW,2,true,true);
                    fMethod(lSysRight);       
                    self.runAndCheckError(@check,...
                          'wrongMat');  
                end
                function check()
                    fMethod(lSysWrong);
                end
                    function lSys=formVLinSys(typeUVW,typeMatShape,isGCell,isCenterCell)
                if isCenterCell
                    testStruct.center={'0';'0'};
                else
                    testStruct.center=[0,0]';
                end
                if typeMatShape==1
                    shapeCMat={'1' ,'0'; '0', '1'};
                else
                    shapeCMat={'0.1-t', 't'; 't', 't'};
                end
                if ~isGCell
                    testMat=eye(2);
                else
                    testMat={'1', '0'; '0', '1'};
                end
                testStruct.shape=shapeCMat;
                if typeUVW=='V'
                    lSys=linsys(eye(2),eye(2),ellipsoid(eye(2)),testMat,...
                        testStruct);
                elseif typeUVW=='U'
                    lSys=linsys(eye(2),testMat,testStruct);
                elseif typeUVW=='W'
                    lSys=linsys(eye(2),eye(2),ellipsoid(eye(2)),...
                        eye(2),ellipsoid(eye(2)),eye(2),testStruct);
                end
            end 
            end
            %          
    end    
end