classdef CompEntityRedirected<...
        modgen.common.test.aux.CompareRedirectAppliance&...
        modgen.common.test.aux.CompEntity
    methods
        function self=CompEntityRedirected(varargin)
            self=self@modgen.common.test.aux.CompEntity(varargin{:});
        end
    end
end