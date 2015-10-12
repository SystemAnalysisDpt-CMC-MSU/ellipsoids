classdef HandleObjectClonerAdv<modgen.common.obj.test.HandleObjectCloner
    properties
        beta
    end
    %
    methods
        function self=HandleObjectClonerAdv(beta,varargin)
            self=self@modgen.common.obj.test.HandleObjectCloner(varargin{:});
            if nargin>0
                self.beta=beta;
            end
        end
    end
    %
    methods
        function setCompMode(self,compMode)
            switch compMode
                case 'blob',
                    self.setComparisonMode(...
                        modgen.common.obj.ObjectComparisonMode.Blob);
                case 'user',
                    self.setComparisonMode(...
                        modgen.common.obj.ObjectComparisonMode.UserDefined);
            end
        end
        function self=disp(self)
            S.alpha=arrayfun(@(x)x.alpha,self);
            S.beta=arrayfun(@(x)x.beta,self);
            modgen.struct.strucdisp(S);
        end
    end
    %
    methods (Static)
        function objVec=create(alphaVec,betaVec)
            nObj=numel(alphaVec);
            for iObj=nObj:-1:1
                alpha=alphaVec(iObj);
                beta=betaVec(iObj);
                objVec(iObj)=...
                    modgen.common.obj.test.HandleObjectClonerAdv(beta,alpha);
            end
        end
    end
end