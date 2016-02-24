classdef PrameterizedTC < mlunitext.test_case
    properties (Access=private)
        fCreateObj;
    end
    methods (Access=private)
        function objCVec = createObjCVec(self,centCVec,varargin)
            matCVec=repmat({eye(numel(centCVec{1}))},1,numel(centCVec));
            if numel(varargin)==0
                fCrObVec=@(centVec,shapeMat)...
                    self.fCreateObj(centVec,shapeMat);
            else
                fCrObVec=@(centVec,shapeMat,absTol,relTol)...
                    self.fCreateObj(centVec,shapeMat,...
                    'absTol',absTol,'relTol',relTol);
            end
            objCVec=cellfun(fCrObVec,centCVec,matCVec,varargin{:},...
                    'UniformOutput',false);
        end
    end
    methods
        function self = PrameterizedTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function set_up_param(self, varargin)
            import modgen.common.throwerror;
            if nargin == 2
                self.fCreateObj=varargin{1};
            elseif nArgs > 1
                throwerror('wrongInput','Too many parameters');
            end
        end
        
        function testIsEqualSymProp(self)
            %test symmetry property
            defTol=min(getDefTol());
            tolVec={10*defTol,defTol}; %absTolVec=relTolVec=tolVec
            centCVec={[0;1],[tolVec{1};1]};
            testObjCVec=self.createObjCVec(centCVec,tolVec,tolVec);
            checkForIsEqual(testObjCVec{2},testObjCVec{1},...
                isEqual(testObjCVec{1},testObjCVec{2}));
        end
        
        function testIsEqualTransProp(self)
            %test transitive property
            defTol=min(getDefTol());
            %absTolVec=relTolVec=tolVec
            tolVec={10*defTol,100*defTol,defTol};
            centCVec={[0;1],[tolVec{1};1],[tolVec{2};1]};
            testObjCVec=self.createObjCVec(centCVec,tolVec,tolVec);
            checkForIsEqual(testObjCVec{1},testObjCVec{3},...
                isEqual(testObjCVec{1},testObjCVec{2})&&...
                isEqual(testObjCVec{2},testObjCVec{3}))
        end
        
        function testIsEqualAbsTolRepByRelTol(self)
            %test captures that absTol replaced by relTol
            [defAbsTol,defRelTol]=getDefTol();
            if defAbsTol~=defRelTol
                if defAbsTol<defRelTol
                    centCVec={[0;1],[defRelTol;1]};
                    isExpResIsEqual=false;
                else
                    centCVec={[0;1],[defAbsTol;1]};
                    isExpResIsEqual=true;
                end
                testObjCVec=createObjCVec(self,centCVec);
            else
                absTolVec={defAbsTol,defAbsTol};
                relTolVec={10*defAbsTol,10*defAbsTol};
                centCVec={[0;1],[relTolVec{1};1]};
                testObjCVec=self.createObjCVec...
                    (centCVec,absTolVec,relTolVec);
                isExpResIsEqual=false;
            end
            checkForIsEqual(testObjCVec{1},testObjCVec{2},isExpResIsEqual)
        end
    end
end

function [defAbsTol,defRelTol] = getDefTol()
defAbsTol=elltool.conf.Properties.getAbsTol();
defRelTol=elltool.conf.Properties.getRelTol();
end

function checkForIsEqual(testEll1Vec,testEll2Vec,isExpResIsEqual)
[isOkArr, reportStr]=isEqual(testEll1Vec,testEll2Vec);
isOk=all(isOkArr(:)==isExpResIsEqual(:));
mlunitext.assert(isOk,reportStr);
end
