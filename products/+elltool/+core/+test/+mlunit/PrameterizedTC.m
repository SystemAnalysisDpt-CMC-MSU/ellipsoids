classdef PrameterizedTC < mlunitext.test_case
    properties (Access=private)
        fCreateObj;
    end
    methods (Access=private)
        function objCVec = createObjCVec(self,centCVec,varargin)
            matCVec=repmat(num2cell(eye(numel(centCVec{1})),...
                [1,2]),1,numel(centCVec));
            if numel(varargin)==0
                fCrObVec = @(cent,mat,tol) self.fCreateObj(cent,mat);
                objCVec=cellfun(fCrObVec,centCVec,matCVec,...
                    'UniformOutput',false);
            else
                fCrObVec = @(cent,mat,tol) self.fCreateObj(cent,mat,...
                    'absTol',tol(1),'relTol',tol(2));
                objCVec=cellfun(fCrObVec,centCVec,matCVec,varargin{:},...
                    'UniformOutput',false);
            end
        end
    end
    methods
        function self = PrameterizedTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function set_up_param(self, varargin)
            import modgen.common.throwerror;
            nArgs = numel(varargin);
            if nArgs == 1
                self.fCreateObj=varargin{1};
            elseif nArgs > 1
                throwerror('wrongInput','Too many parameters');
            end
        end
        
        function testIsEqualSymProp(self)
            % test symmetry property
            defTol=min(getDefTol());
            tolCVec=num2cell([10*defTol,defTol;10*defTol,defTol],1);
            centCVec=num2cell([0,tolCVec{1}(1);1,1],1);
            testObjCVec=self.createObjCVec(centCVec,tolCVec);
            checkForIsEqual(testObjCVec{2},testObjCVec{1},...
                isEqual(testObjCVec{1},testObjCVec{2}));
        end
        
        function testIsEqualTransProp(self)
            % test transitive property
            defTol=min(getDefTol());
            tolCVec=num2cell([10*defTol,100*defTol,defTol;10*defTol,...
                100*defTol,defTol],1);
            centCVec=num2cell([0,tolCVec{1}(1),tolCVec{2}(1);1,1,1],1);
            testObjCVec=self.createObjCVec(centCVec,tolCVec);
            checkForIsEqual(testObjCVec{1},testObjCVec{3},...
                isEqual(testObjCVec{1},testObjCVec{2})&&...
                isEqual(testObjCVec{2},testObjCVec{3}))
        end
        
        function testIsEqualAbsTolRepByRelTol(self)
            %test captures that absTol replaced by relTol
            defTolVec=getDefTol();
            if defTolVec(1)~=defTolVec(2)
                if defTolVec(1)<defTolVec(2)
                    centCVec=num2cell([0,defTolVec(2);1,1],1);
                    expResIsEqual=false;
                else
                    centCVec=num2cell([0,defTolVec(1);1,1],1);
                    expResIsEqual=true;
                end
                testObjCVec=createObjCVec(self,centCVec);
            else
                defTol=min(getDefTol());
                tolCVec=num2cell([defTol,defTol;...
                    10*defTol,10*defTol],1);
                centCVec=num2cell([0,10*defTol;1,1],1);
                testObjCVec=self.createObjCVec(centCVec,tolCVec);
                expResIsEqual=false;
            end
            checkForIsEqual(testObjCVec{1},testObjCVec{2},expResIsEqual)
        end
    end
end

function defTolVec = getDefTol()
defTolVec = [elltool.conf.Properties.getAbsTol();elltool.conf.Properties.getRelTol()];
end

function checkForIsEqual(testEll1Vec,testEll2Vec,expectResult)
[isOkArr, reportStr]=isEqual(testEll1Vec,testEll2Vec);
isOk=all(isOkArr(:)==expectResult(:));
mlunitext.assert(isOk,reportStr);
end
