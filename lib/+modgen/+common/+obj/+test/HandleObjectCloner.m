classdef HandleObjectCloner<modgen.common.obj.HandleObjectCloner
    properties
        alpha
    end
    methods
        function self=HandleObjectCloner(alpha)
            if nargin>0
                self.alpha=alpha;
            end
        end
    end
    methods (Access=protected)
        function blobComparisonHook(~)
            modgen.common.test.aux.EqualCallCounter.incEqCounter(1);
        end
        function [isOk,reportStr,signOfDiff]=isEqualScalarInternal(self,...
                otherObj,varargin)
            %
            reportStr='';
            if nargout>2
                signOfDiff=nan;
            end
            isOk=isequal(self.alpha,otherObj.alpha);
            if ~isOk
                reportStr='alpha is different';
            end
            modgen.common.test.aux.EqualCallCounter.incEqCounter(1);
        end
    end
    methods 
        function self=disp(self)
            S.alpha=arrayfun(@(x)x.alpha,self);
            modgen.struct.strucdisp(S);
        end
    end
    methods (Static)
        function objVec=create(nObj)
            %
            for iObj=nObj:-1:1
                objVec(iObj)=...
                    modgen.common.obj.test.HandleObjectCloner(iObj);
            end
        end
    end
end