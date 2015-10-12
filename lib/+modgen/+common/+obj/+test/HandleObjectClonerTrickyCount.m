classdef HandleObjectClonerTrickyCount<modgen.common.obj.test.HandleObjectCloner
    properties
        beta
    end
    %
    methods
        function self=HandleObjectClonerTrickyCount(varargin)
            self=self@modgen.common.obj.test.HandleObjectCloner(varargin{:});
        end
    end
    methods  (Access=protected)
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
            modgen.common.test.aux.EqualCallCounter.incEqCounter(0.001);
        end        
    end
end